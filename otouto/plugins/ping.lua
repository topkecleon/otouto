--[[
    ping.lua
    Sends a response, then updates it with the time it took to send.

    I added marco/polo because a cute girl asked and I'm a sellout.
    Brayden is not a cute girl, but he bought me a book.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local socket = require('socket')

local ping = {}

function ping:init()
    ping.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('ping'):t('marco'):t('annyong').table
    ping.command = 'ping'
    ping.doc = self.config.cmd_pat .. [[ping
Pong!
Updates the message with the time used, in seconds, to send the response.]]
end

function ping:action(msg)
    local a = socket.gettime()
    local answer = msg.text_lower:match('ping') and 'Pong!' or (msg.text_lower:match('marco') and 'Marco!' or 'Annyong.')
    local message = utilities.send_reply(msg, answer)
    local b = socket.gettime()-a
    b = string.format('%.3f', b)
    if message then
        bindings.editMessageText{
            chat_id = msg.chat.id,
            message_id = message.result.message_id,
            text = answer .. '\n`' .. b .. '`',
            parse_mode = 'Markdown'
        }
    end
end

return ping
