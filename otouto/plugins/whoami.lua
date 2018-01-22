--[[
    whoami.lua
    Returns the user's or replied-to user's display name, username, and ID, in
    addition to the group's display name, username, and ID.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local who = {}

function who:init()
    who.command = 'who'
    who.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('who'):t('whoami').table
    who.doc = 'Returns user and chat info for you or the replied-to message.'
end

function who.format_name(user)
    if type(user) == 'string' then
        return 'a channel <code>[' .. utilities.normalize_id(user) .. ']</code>'
    end
    local name = user.title and utilities.html_escape(user.title) or utilities.
        html_escape(utilities.build_name(user.first_name, user.last_name))
    local id = utilities.normalize_id(user.id)
    if user.username then
        return string.format(
            '<b>%s</b> (@%s) <code>[%s]</code>',
            name,
            user.username,
            id
        )
    else
        return string.format(
            '<b>%s</b> <code>[%s]</code>',
            name,
            id
        )
    end
end

function who:action(msg)
    -- Operate on the replied-to message, if there is one.
    msg = msg.reply_to_message or msg
    -- If it's a private conversation, bot is chat, unless bot is from.
    local chat = (msg.from.id == msg.chat.id) and self.info or msg.chat
    local output
    if msg.new_chat_member or msg.left_chat_member then
        local thing = msg.new_chat_member or msg.left_chat_member
        output = string.format(
            '%s %s %s %s %s.',
            who.format_name(msg.from),
            msg.new_chat_member and 'added' or 'removed',
            who.format_name(thing),
            msg.new_chat_member and 'to' or 'from',
            who.format_name(chat)
        )
    --elseif msg.forward_from and msg.forward_from_chat then
        --output = string.format(
            --'%s forwarded a message sent by %s to %s to %s.',
            --who.format_name(msg.from),
            --who.format_name(msg.forward_from),
            --who.format_name(msg.forward_from_chat),
            --who.format_name(chat)
        --)
    else
        output = string.format(
            'You are %s, and you are messaging %s.',
            who.format_name(msg.from),
            who.format_name(chat)
        )
    end
    utilities.send_message(msg.chat.id, output, true, msg.message_id, 'html')
end

return who
