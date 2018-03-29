local bindings = require('otouto.bindings')
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

    elseif bot.database.userdata.administrators[user_id_str] then
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

    if bot.database.userdata.hammers[user_id_str] then
        if not group or not group.antihammer[user_id_str] then
            return 0 -- Hammered
        end
    end

    return 1
end

function autils.duration_from_reason(text)
    local reason = text
    local duration
    local first = utilities.get_word(text, 1)
    if first then
        if tonumber(first) then
            duration = first * 60
            reason = utilities.input(text)
        elseif first:match('^%d[%dywdhms]*%l$') then
            local n = utilities.tiem.deformat(first)
            if n then
                duration = n
                reason = utilities.input(text)
            end
        end
    end
    return reason, duration
end

function autils.targets(bot, msg)
    local input = utilities.input(msg.text)

    -- Reply messages target the replied-to message's sender, or the added/
    -- removed user. The reason is always the text given after the command.
    if msg.reply_to_message then
        return {
            (msg.reply_to_message.new_chat_member
            or msg.reply_to_message.left_chat_member
            or msg.reply_to_message.from).id
        }, autils.duration_from_reason(input)

    elseif input then
        local user_ids = {}
        local reason, duration
        local text = msg.text

         -- The text following a newline is the reason. If the first word is a
         -- number or time string (eg 6h45m30s), it will be the duration.
        if text:match('\n') then
            text, reason = text:match('^(.-)\n+(.+)$')
            if reason then
                reason, duration = autils.duration_from_reason(reason)
            end
        end

        -- Iterate over entities for text mentions, add mentioned users to
        -- user_ids and remove the text of the mentions from the string.
        if msg.entities then
            for i = #msg.entities, 1, -1 do
                local entity = msg.entities[i]
                if entity.type == 'text_mention' then
                    table.insert(user_ids, 1, entity.user.id)

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
                    table.insert(user_ids, tonumber(word))

                -- Usernames.
                elseif word:match('^@.') then
                    local user = utilities.resolve_username(bot, word)
                    table.insert(user_ids, user and user.id or
                        'Unrecognized username (' .. word .. ').')

                else
                    table.insert(user_ids,
                        'Invalid username or ID (' .. word .. ').')
                end
            end
        end

        return user_ids, reason, duration
    end
end

 -- source eg "antisquig", "filter", etc
 -- Returns true if action was taken.
function autils.strike(bot, msg, source)
    bindings.deleteMessage{
        chat_id = msg.chat.id,
        message_id = msg.message_id
    }

    bot.database.groupdata.automoderation[tostring(msg.chat.id)] =
        bot.database.groupdata.automoderation[tostring(msg.chat.id)] or {}
    local chat =
        bot.database.groupdata.automoderation[tostring(msg.chat.id)]
    local user_id_str = tostring(msg.from.id)
    chat[user_id_str] = (chat[user_id_str] or 0) + 1

    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, 'autils.strike requires flags')

    local logstuff = {
        source = source,
        reason = flags_plugin.flags[source],
        target = msg.from.id,
        chat_id = msg.chat.id
    }

    if chat[user_id_str] == 1 then
        logstuff.action = 'Message deleted'

        -- Let's send a concise warning to the group for first-strikers.
        local warning = '<b>' .. source .. ':</b> Deleted message by ' ..
            utilities.format_name(bot, msg.from.id) ..
            '. The next automoderation trigger will result in a five-minute tempban.'
            .. '\n<i>' .. flags_plugin.flags[source] ..'</i>'
        if bot.config.administration.log_chat_username then
            warning = warning .. '\n<b>View the logs:</b> ' ..
                bot.config.administration.log_chat_username .. '.'
        end

        -- Successfully-sent warnings get their IDs stored to be deleted about
        -- five minutes later by automoderation.lua.
        local m = utilities.send_message(msg.chat.id, warning, true, nil, 'html')
        if m then
            local automoderation_plugin = bot.named_plugins['admin.automoderation']
            assert(automoderation_plugin, 'autils.strike requires automoderation')

            table.insert(automoderation_plugin.store, {
                message_id = m.result.message_id,
                chat_id = m.result.chat.id,
                date = m.result.date
            })
        end

    elseif chat[user_id_str] == 2 then
        local a, b = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id,
            until_date = msg.date + 300
        }
        if a then
            logstuff.action = 'Banned for five minutes'
        else
            logstuff.action = b.description
        end

    elseif chat[user_id_str] == 3 then
        local a, b = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id,
        }
        if a then
            logstuff.action = 'Banned'
        else
            logstuff.action = b.description
        end
        chat[user_id_str] = 0
    end

    autils.log(bot, logstuff)
end

--[[
    params = {
        target = 55994550, -- OR
        targets = {
            55994550,
            117099167
        },
        chat_id = -100987654321,
        action = "Kicked",
        source = "antisquig" -- OR
        source_id = 151278060,
        reason = "Spamming pony stickers", -- could be a flag desc
    }
]]
function autils.log(bot, params)
    local output = '<code>' .. os.date('%F %T') .. '</code>\n'

    local log_chat = bot.config.administration.log_chat or bot.config.log_chat
    if params.chat_id then
        local group =
            bot.database.groupdata.admin[tostring(params.chat_id)]
        output = output .. string.format(
            '<b>%s</b> <code>[%s]</code> <i>%s</i>\n',
            utilities.html_escape(group.name),
            utilities.normalize_id(params.chat_id),
            group.username and '@' .. group.username or ''
        )

        if group.flags.private then
            log_chat = bot.config.log_chat
        end
    end

    local target_names = {}
    if params.targets then
        for _, id in ipairs(params.targets) do
            table.insert(target_names, utilities.format_name(bot, id))
        end
    elseif params.target then
        table.insert(target_names, utilities.format_name(bot, params.target))
    end

    if #target_names > 0 then
        output = output .. table.concat(target_names, '\n') .. '\n'
    end

    output = string.format(
        '%s%s by %s',
        output,
        params.action,
        params.source_id and utilities.format_name(bot, params.source_id)
            or params.source or utilities.format_name(bot, 0)
    )

    if params.reason then
        output = output ..':\n<i>'..utilities.html_escape(params.reason)..'</i>'
    end

    utilities.send_message(log_chat, output, true, nil, 'html')
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
Some commands accept an optional duration, specified at the beginning of the \z
reason. The duration can be a number of minutes, or a time interval in the \z
format 1y12w28d12h45m30s. Read more on time formatting with /help tiem."

autils.glossary.tiem = "\z
Some commands, such as /mute and /tempban, accept an optional duration. The \z
duration can be specified before or in place of the reason. If a number is \z
given, the interval will be that number of minutes. An interval can also be \z
a tiem string, eg 3d12h30m. \
The tiem format handles intervals in the following units: \
• year (y): 365.25 days or 31557600 seconds. \
• week (w): 10080 minutes or 604800 seconds. \
• day (d): 1440 minutes or 86400 seconds. \
• hour (h) \
• minute (m) \
• seconds (s) \
Units can be repeated and do not need to be in order of size. Their amounts \z
can exceed the size of a larger unit. Invalid tiem strings are overlooked and \z
included in the reason. \
Be aware that most (or all) Telegram bot API calls limit intervals to one year."


return autils
