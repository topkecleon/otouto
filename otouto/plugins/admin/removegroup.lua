local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('removegroup', true):t('remgroup').table
    self.command = 'removegroup [chat ID]'
    self.doc = "/removegroup [chat ID]\
Removes the current or specified group from the administrative system."
    self.privilege = 4
end

function P:action(bot, msg, group)
    local input = utilities.input_from_msg(msg)
    local output

    if input then
        local id = tostring(tonumber(input))
        if id then
            if bot.database.administration.groups[id] then
                output = 'I am no longer administrating ' ..
                    bot.database.administration.groups[id].name .. '.'
                bot.database.administration.groups[id] = nil
            else
                output = 'Group not found (' .. id .. ').'
            end
        else
            output = 'Input must be a group ID.'
        end

    else
        if group then
            output = 'I am no longer administrating ' .. msg.chat.title .. '.'
            bot.database.administration.groups[tostring(msg.chat.id)] = nil
        else
            output = 'Run in an administrated group or pass one\'s ID.'
        end
    end

    utilities.send_reply(msg, output)

end

return P
