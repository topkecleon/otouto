local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local cleverbot = {}

function cleverbot:init()
    cleverbot.name = '^' .. self.info.first_name:lower() .. ', '
    cleverbot.username = '^@' .. self.info.username:lower() .. ', '
    cleverbot.triggers = {
        '^' .. self.info.first_name:lower() .. ', ',
        '^@' .. self.info.username:lower() .. ', '
    }
    cleverbot.url = self.config.cleverbot.cleverbot_api
    cleverbot.error = false
end

function cleverbot:action(msg)
    bindings.sendChatAction{chat_id = msg.chat.id, action = 'typing'}
    local input = msg.text_lower:gsub(cleverbot.name, ''):gsub(cleverbot.name, '')
    local jstr, code = HTTPS.request(cleverbot.url .. URL.escape(input))
    if code ~= 200 then
        utilities.send_message(msg.chat.id, self.config.cleverbot.connection)
        return
    end
    local data = JSON.decode(jstr)
    if not data.clever then
        utilities.send_message(msg.chat.id, self.config.cleverbot.response)
        return
    end
    utilities.send_message(msg.chat.id, data.clever)
end

return cleverbot
