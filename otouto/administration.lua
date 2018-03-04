local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local autils = {}

function autils:rank(user_id, chat_id)
    local user_id_str = tostring(user_id)
    user_id = tonumber(user_id)
    local group = self.database.administration.groups[tostring(chat_id)]

    if user_id == self.config.admin then
        return 5 -- Owner

    elseif user_id == self.info.id then
        return 5 -- Bot

    elseif self.database.administration.administrators[user_id_str] then
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

    if self.database.administration.hammers[user_id_str] then
        if not group or not group.antihammer[user_id_str] then
            return 0 -- Hammered
        end
    end

    return 1
end

function autils:targets(msg)
    local input = utilities.input(msg.text)

    -- Reply messages target the replied-to message's sender, or the added/
    -- removed user. The reason is always the text given after the command.
    if msg.reply_to_message then
        return {
            (msg.reply_to_message.new_chat_member
            or msg.reply_to_message.left_chat_member
            or msg.reply_to_message.from).id
        }, input

    elseif input then
        -- output
        local user_ids = {}

        -- Iterate over entities for text mentions.
        if msg.entities then
            for _, entity in ipairs(msg.entities) do
                if entity.type == 'text_mention' then
                    table.insert(user_ids, entity.user.id)
                end
            end
        end

        -- In a non-reply command, the text following a newline is the reason.
        local reason
        if input:match('\n') then
            input, reason = input:match('(.-)\n+(.+)')
        end

        for word in input:gmatch('%g+') do
            if tonumber(word) then
                table.insert(user_ids, tonumber(word))

            elseif word:match('^@.') then
                local user = utilities.resolve_username(self, word)
                table.insert(user_ids, user and user.id or
                    'Unrecognized username (' .. word .. ').')

            else
                table.insert(user_ids, 'Invalid username or ID (' ..word.. ').')
            end
        end

        return user_ids, reason
    end
end

 -- source eg "antisquig", "filter", etc
 -- Returns true if action was taken.
function autils:strike(msg, source)
    bindings.deleteMessage{
        chat_id = msg.chat.id,
        message_id = msg.message_id
    }

    self.database.administration.automoderation[tostring(msg.chat.id)] =
        self.database.administration.automoderation[tostring(msg.chat.id)] or {}
    local chat =
        self.database.administration.automoderation[tostring(msg.chat.id)]
    local user_id_str = tostring(msg.from.id)
    chat[user_id_str] = (chat[user_id_str] or 0) + 1

    local action_taken

    if chat[user_id_str] == 1 then
        action_taken = 'Message deleted'

        -- Let's send a concise warning to the group for first-strikers.
        local warning = '<b>' .. source .. ':</b> Deleted message by ' ..
            utilities.format_name(self, msg.from.id) ..
            '. The next automoderation trigger will result in a five-minute tempban.'
        if self.config.administration.log_chat_username then
            warning = warning .. '\n<b>View the logs:</b> ' ..
                self.config.administration.log_chat_username .. '.'
        end

        -- Successfully-sent warnings get their IDs stored to be deleted about
        -- five minutes later by automoderation.lua.
        local m =utilities.send_message(msg.chat.id, warning, true, nil, 'html')
        if m then
            table.insert(self.named_plugins.automoderation.store, {
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
            action_taken = 'Kicked for five minutes'
        else
            action_taken = b.description
        end

    elseif chat[user_id_str] == 3 then
        local a, b = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id,
        }
        if a then
            action_taken = 'Banned'
        else
            action_taken = b.description
        end
        chat[user_id_str] = 0
    end

    autils.log(self, msg.chat.id, msg.from.id, action_taken, source,
        self.named_plugins.flags.flags[source])

    return rv
end

function autils:log(chat_id, targets, action_taken, source, etc)
    local group = self.database.administration.groups[tostring(chat_id)]

    local target_names = {}
    if tonumber(targets) then
        table.insert(target_names, utilities.format_name(self, targets))
    else
        for _, id in ipairs(targets) do
            table.insert(target_names, utilities.format_name(self, id))
        end
    end

    local output = string.format(
        '<code>%s</code>\n<b>%s</b> <code>[%s]</code>\n%s\n%s by %s',
        os.date('%F %T'),
        utilities.html_escape(group.name),
        utilities.normalize_id(chat_id),
        table.concat(target_names, '\n'),
        action_taken,
        source
    )
    if etc then
        output = output .. ':\n<i>' .. utilities.html_escape(etc) .. '</i>'
    else
        output = output .. '.'
    end

    local log_chat = self.config.log_chat
    if not group.flags.private then
        log_chat = self.config.administration.log_chat or log_chat
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

return autils
