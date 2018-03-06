--[[
    greetings.lua
    Gives the bot owner-configured responses to owner-configured greetings.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local greetings = {}

function greetings:init()
    greetings.triggers = {}
    for _, triggers in pairs(self.config.greetings) do
        for i = 1, #triggers do
            local s = '^' .. triggers[i] .. ',? ' .. self.info.first_name:lower() .. '%p*$'
            table.insert(greetings.triggers, s)
        end
    end
end

function greetings:action(msg)
    local nick
    if self.database.userdata.nick[tostring(msg.from.id)] then
        nick = self.database.userdata.nick[tostring(msg.from.id)]
    end
    nick = nick or utilities.build_name(msg.from.first_name, msg.from.last_name)

    for response, triggers in pairs(self.config.greetings) do
        for _, trigger in pairs(triggers) do
            if string.match(msg.text_lower, trigger) then
                local n = nick:gsub('%%','%%%%')
                utilities.send_message(msg.chat.id,
                    response:gsub('#NAME', n))
                return
            end
        end
    end
end

return greetings
