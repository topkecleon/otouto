--[[
    autils.lua
    Utilities for administrative plugins.

    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local anise = require('anise')
local bindings = require('extern.bindings')
local utilities = require('otouto.utilities')

local autils = {}

function autils.rank(bot, user_id, chat_id)
    local user_id_str = tostring(user_id)
    user_id = tonumber(user_id)
    local group = bot.database.groupdata.admin[tostring(chat_id)]

    if user_id == bot.config.admin then
        return 5 -- Owner

    elseif user_id == bot.info.id then
        return 5 -- Bot

    elseif bot.database.userdata.administrator[user_id_str] then
        return 4 -- Administrator

    elseif group then
        if user_id == group.governor then
            return 3 -- Governor

        elseif user_id == group.owner then
            return 3 -- Creator

        elseif group.moderators[user_id_str] then
            return 2 -- Moderator

        elseif group.bans[user_id_str] then
            return 0 -- Banned
        end
    end

    if bot.database.userdata.hammered[user_id_str] then
        if not group or not group.antihammer[user_id_str] then
            return 0 -- Hammered
        end
    end

    return 1
end

 -- If the reason matches "rule 3" or "r3" then it will be expanded to the
 -- appropriate group rule.
function autils.rule_from_reason(bot, text, chat_id)
    if text:match('^rule%s*%d+$') or text:match('^r%s*%d+$') then
        local rule_no = tonumber(text:match('%d+'))
        local group = bot.database.groupdata.admin[tostring(chat_id)]
        if group.rules[rule_no] then
            return group.rules[rule_no]
        else
            return text
        end
    else
        return text
    end
end

 -- If the first "word" of a reason is a number or a valid tiem string, it
 -- becomes the duration.
function autils.duration_from_reason(text)
    local reason = text
    local duration
    local first = utilities.get_word(text, 1)
    if first and utilities.tiem.deformat(first) then
        reason = utilities.input(text)
        duration = utilities.tiem.deformat(first)
    end
    return reason, duration
end

 -- Returns a set of targets, a list of errors, a reason, and a duration (sec).
 -- Options are get_duration, unknown_ids_err, and self_targeting (which uses
 -- the sender as target if there are no others).
function autils.targets(bot, msg, options)
    local input = utilities.input(msg.text)
    options = options or {}
    local user_ids = anise.set()
    local errors = {}
    local reason, duration

    -- Reply messages target the replied-to message's sender, or the added/
    -- removed user. The reason is always the text given after the command.
    if msg.reply_to_message then
        user_ids:add(tostring((
        msg.reply_to_message.new_chat_member
        or msg.reply_to_message.left_chat_member
        or msg.reply_to_message.from).id))

        reason = input

    elseif input then
        local text = msg.text

         -- The text following a newline is the reason. If the first word is a
         -- number or time string (eg 6h45m30s), it will be the duration.
        if text:match('\n') then
            text, reason = text:match('^(.-)\n+(.+)$')
        end

        -- Iterate over entities for text mentions, add mentioned users to
        -- user_ids and remove the text of the mentions from the string.
        if msg.entities then
            for i = #msg.entities, 1, -1 do
                local entity = msg.entities[i]
                if entity.type == 'text_mention' then
                    user_ids:add(tostring(entity.user.id))
                    text = text:sub(1, entity.offset) ..
                        text:sub(entity.offset + entity.length + 2)
                end
            end
        end

        text = utilities.input(text)
        -- text may be empty after removing text mentions
        if text then
            for word in text:gmatch('%g+') do
                -- User IDs.
                if tonumber(word) then
                    if options.unknown_ids_err and (
                        not bot.database.userdata.info
                        or not bot.database.userdata.info[word]
                    ) then
                        table.insert(errors, 'Unknown ID: ' .. word .. '.')
                    else
                        user_ids:add(word)
                    end

                -- Usernames.
                elseif word:match('^@.') then
                    local user = utilities.resolve_username(bot, word)
                    if user then
                        user_ids:add(tostring(user.id))
                    else
                        table.insert(errors,
                            'Unrecognized username: ' .. word .. '.')
                    end

                else
                    table.insert(errors,
                        'Invalid username, mention, or ID: ' .. word .. '.')
                end
            end
        end

    elseif options.self_targeting then
        user_ids:add(tostring(msg.from.id))

    else
        errors = { bot.config.errors.specify_targets }
    end

    if reason then
        -- Get the duration from the reason, if applicable.
        if options.get_duration then
            reason, duration = autils.duration_from_reason(reason)
        end

        -- If the reason matches "rule n" or "rn" then expand it to that rule.
        reason = autils.rule_from_reason(bot, reason, msg.chat.id)
    end

    return user_ids, errors, reason, duration
end

 -- Returns true if action was taken.
function autils.strike(bot, msg, source)
    bindings.deleteMessage{
        chat_id = msg.chat.id,
        message_id = msg.message_id
    }

    local user = utilities.user(bot, msg.from.id)
    local id_str = tostring(msg.from.id)
    local log_action

    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, 'autils.strike requires flags')

    local strikes = bot.database.groupdata.admin[tostring(msg.chat.id)].strikes
    strikes[id_str] = (strikes[id_str] or 0) + 1

    local score = strikes[id_str]
    if score == 1 then
        log_action = 'Message deleted'

        -- Send a warning on the first strike, detailing the flag's job.
        local warning = string.format("<b>%s:</b> Deleted message by %s. The \z
            next automoderation trigger will result in a five-minute tempban. \z
            \n<i>%s</i>", source, user:name(), flags_plugin.flags[source])
        -- todo: the bot should just store admin.log_chat's info
        if bot.config.administration.log_chat_username then
            warning = warning .. '\n<b>View the logs:</b> ' ..
                bot.config.administration.log_chat_username .. '.'
        end
        local success, res =
            utilities.send_message(msg.chat.id, warning, true, nil, 'html')

        -- If the warning sent, expire it later.
        if success and bot.named_plugins['core.delete_messages'] then
            bot:do_later(
                'core.delete_messages',
                os.time() + bot.config.administration.warning_expiration,
                {chat_id = res.result.chat.id, message_id = res.result.message_id}
            )
        end

        -- Decrement the user's strikes in 24h.
        bot:do_later('admin.flags', os.time() + 86400,
            {chat_id = msg.chat.id, user_id = msg.from.id})

    elseif score == 2 then
        local success, result = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id,
            until_date = msg.date + 300
        }
        if success then
            log_action = 'Banned for five minutes'
        else
            log_action = result.description
        end

        -- Decrement the user's strikes in 24h.
        bot:do_later('admin.flags', os.time() + 86400,
            {chat_id = msg.chat.id, user_id = msg.from.id})

    elseif score == 3 then
        local success, result = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id,
        }
        if success then
            log_action = 'Banned'
        else
            log_action = result.description
        end
        strikes[id_str] = nil
    end

    autils.log(bot, {
        source = source,
        reason = flags_plugin.flags[source],
        target = msg.from.id,
        chat_id = msg.chat.id,
        action = log_action
    })
end

--[[
    params = {
        target = 55994550, -- OR
        targets = {
            ['55994550'] = true,
            ['117099167'] = true
        },
        chat_id = -100987654321,
        action = "Kicked",
        source = "antisquig" -- OR
        source_user = {
            first_name 'Hayao',
            last_name = 'Miyazaki',
            id = 151278060
        },
        reason = "Spamming pony stickers", -- could be a flag desc
    }
]]
function autils.log(bot, params)
    local output = { '<code>' .. os.date('%F %T') .. '</code>' }

    local log_chat = bot.config.administration.log_chat or bot.config.log_chat
    if params.chat_id then
        table.insert(output, utilities.lookup_name(bot, params.chat_id))

        if bot.database.groupdata.admin[tostring(params.chat_id)].flags.private
        then
            log_chat = bot.config.log_chat
        end
    end

    if params.targets then
        anise.pushcat(output, utilities.list_names(bot, params.targets))
    elseif params.target then
        table.insert(output, utilities.lookup_name(bot, params.target))
    end

    table.insert(output, string.format(
        '%s by %s.',
        params.action,
        params.source_user and utilities.format_name(params.source_user)
            or params.source or 'Unknown'
    ))

    if params.reason then
        table.insert(output,
            '<i>' .. utilities.html_escape(params.reason) .. '</i>')
    end

    utilities.send_message(log_chat, table.concat(output, '\n'),
        true, nil, 'html')
end

-- Shortcut to promote admins. Passing true as all_perms enables the
-- can_change_info and can_promote_members options.
function autils.promote_admin(chat_id, user_id, all_perms)
    return bindings.promoteChatMember{
        chat_id = chat_id,
        user_id = user_id,
        can_delete_messages = true,
        can_invite_users = true,
        can_restrict_members = true,
        can_pin_messages = true,
        can_change_info = all_perms,
        can_promote_members = all_perms
    }
end

function autils.demote_admin(chat_id, user_id)
    return bindings.promoteChatMember{
        chat_id = chat_id,
        user_id = user_id,
        can_delete_messages = false,
        can_invite_users = false,
        can_restrict_members = false,
        can_pin_messages = false,
        can_change_info = false,
        can_promote_members = false
    }
end

 -- Command non-specific information, such as on the syntax of targetting and
 -- the formatting of intervals.
autils.glossary = {}

autils.glossary.targets = "\z
Targets are specified in a list of usernames, text mentions, and/or user IDs. \z
Most commands accept multiple targets. In a reply command, the sender of the \z
replied-to message is the target. \
A reason can usually be specified. In reply commands, the reason is the text \z
after the command. In normal commands, the reason is specified on a new line. \
Some commands expect a duration, specified at the beginning of the \z
reason. The duration can be a number of minutes, or a time interval in the \z
format 1y12w28d12h45m30s. Read more on time formatting with /help tiem."

autils.glossary.tiem = "\z
Some commands, such as /mute and /tempban, expect duration. The \z
duration can be specified before or in place of the reason. If a number is \z
given, the interval will be that number of seconds. An interval can also be \z
a tiem string, eg 3d12h30m. \
The tiem format handles intervals in the following units: \
• year (y): 365.25 days or 31557600 seconds. \
• week (w): 10080 minutes or 604800 seconds. \
• day (d): 1440 minutes or 86400 seconds. \
• hour (h) \
• minute (m) \
• seconds (s) \
Units can be repeated and do not need to be in order of size. Their amounts \z
can exceed the size of a larger unit. \z
Be aware that most (or all) Telegram bot API calls limit intervals to one year."

autils.glossary.automoderation = "\z
The automoderation system provides a unified three-strike system in each \z
group. When a first strike is issued, the offending message is deleted and a \z
warning is posted. The warning is deleted after a configurable interval \z
seconds. When the second strike is issued, the offending message is again \z
deleted and the user is banned for five minutes. On the third strike, the \z
message is deleted and the user is banned. \
A user's local strikes can be reset with /unrestrict. Available \z
automoderation policies can be viewed with /flags (see /help flags)."


return autils
