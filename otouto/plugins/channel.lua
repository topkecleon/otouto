--[[
    channel.lua
    Let users send markdown-formatted messages to their channels.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local channel = {}

function channel:init()
    channel.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('ch', true).table
    channel.command = 'ch <channel> \\n <message>'
    channel.doc = self.config.cmd_pat .. [[ch <channel>
<message>

Sends a message to a channel. Channel may be specified via ID or username. Messages are markdown-enabled. Users may only send messages to channels for which they are the owner or an administrator.

The following markdown syntax is supported:
 *bold text*
 _italic text_
 [text](URL)
 `inline fixed-width code`
 ```pre-formatted fixed-width code block```]]
end

function channel:action(msg)
    local input = utilities.input(msg.text)
    if not input then
        utilities.send_reply(msg, channel.doc, 'html')
        return
    end

    local chat_id = utilities.get_word(input, 1)
    local chat, t = bindings.getChat{chat_id = chat_id}
    if not chat then
        utilities.send_reply(msg, 'Sorry, I was unable to retrieve information for that channel.\n`' .. t.description .. '`', true)
        return
    elseif chat.result.type ~= 'channel' then
        utilities.send_reply(msg, 'Sorry, that group does not appear to be a channel.')
        return
    end

    local admin_list, t = bindings.getChatAdministrators{chat_id = chat_id}
    if not admin_list then
        utilities.send_reply(msg, 'Sorry, I was unable to retrieve a list of administrators for that channel.\n`' .. t.description .. '`', true)
        return
    end

    local is_admin = false
    for _, admin in ipairs(admin_list.result) do
        if admin.user.id == msg.from.id then
            is_admin = true
        end
    end
    if not is_admin then
        utilities.send_reply(msg, 'Sorry, you do not appear to be an administrator for that channel.')
        return
    end

    local text = input:match('\n(.+)')
    if not text then
        utilities.send_reply(msg, 'Please enter a message to be sent on a new line. Markdown is supported.')
        return
    end

    local success, result = utilities.send_message(chat_id, text, true, nil, true)
    if success then
        utilities.send_reply(msg, 'Your message has been sent!')
    else
        utilities.send_reply(msg, 'Sorry, I was unable to send your message.\n`' .. result.description .. '`', true)
    end
end

return channel
