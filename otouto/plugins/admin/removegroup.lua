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
    local input = utilities.get_word(msg.text, 2)
    local output

    if input then
        local id = tostring(tonumber(input))
        if id then
            local admin = bot.database.groupdata.admin
            if admin[id] then
                output = 'I am no longer administrating ' ..  admin[id].name .. '.'
                admin[id] = nil
            elseif admin['-100'..id] then
                output = 'I am no longer administrating ' ..  admin['-100'..id].name .. '.'
                admin['-100'..id] = nil
            else
                output = 'Group not found (' .. id .. ').'
            end
        else
            output = 'Input must be a group ID.'
        end

    elseif group and group.data.admin then
        output = 'I am no longer administrating ' .. msg.chat.title .. '.'
        group.data.admin = nil
    else
        output = 'Run in an administrated group or pass one\'s ID.'
    end

    utilities.send_reply(msg, output)

end

return P
