--[[
    druasay.lua
    This plugin causes the bot to respond to certain triggers over the owner's
    account, via drua-tg.
    It's basically the greetings plugin with drua instead of bot output.
    It will also uppercase the output if the input is entirely uppercase.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local drua = require('otouto.drua-tg')

local druasay = {}

function druasay:init()
    druasay.triggers = {}
    for _, triggers in pairs(self.config.druasay) do
        for i = 1, #triggers do
            table.insert(druasay.triggers, triggers[i])
        end
    end
    druasay.error = false
end

function druasay:action(msg)
    if msg.from.id == self.config.admin or msg.chat.type == 'private' then
        return
    end
    for response, triggers in pairs(self.config.druasay) do
        for _, trigger in ipairs(triggers) do
            if msg.text_lower:match(trigger) then
                local output
                if msg.text == msg.text:upper() then
                    output = response:upper()
                else
                    output = response
                end
                drua.message(msg.chat.id, output)
                return
            end
        end
    end
end

return druasay
