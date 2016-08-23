--[[
    This plugin causes the bot to respond to certain triggers over the owner's
    account, via drua-tg.
    It's basically the greetings plugin with drua instead of bot output.
    It will also uppercase the output if the input is entirely uppercase.
]]

local drua = require('otouto.drua-tg')

local druasay = {}

function druasay:init(config)
    druasay.triggers = {}
    for _, triggers in pairs(config.druasay) do
        for i = 1, #triggers do
            table.insert(druasay.triggers, triggers[i])
        end
    end
    druasay.error = false
end

function druasay:action(msg, config)
    if msg.from.id == config.admin or msg.chat.type == 'private' then return end
    local s = drua.sopen()
    for response, triggers in pairs(config.druasay) do
        for _, trigger in ipairs(triggers) do
            if msg.text_lower:match(trigger) then
                local output
                if msg.text == msg.text:upper() then
                    output = response:upper()
                else
                    output = response
                end
                drua.message(s, msg.chat.id, output)
                return
            end
        end
    end
    drua.sclose(s)
end

return druasay
