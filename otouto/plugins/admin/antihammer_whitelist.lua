local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('antihammer', true).table
    self.command = 'antihammer'
    self.doc = 'Returns a list of users whoo are antihammered (unaffected by a \z
hammer inside this group), or toggles the whitelist status of the specified users.'
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output = autils.targets(bot, msg)
    local admin = group.data.admin

    if targets or #output > 0 then
        if targets then
            for target in pairs(targets) do
                local name = utilities.lookup_name(bot, target)
                if admin.antihammer[target] then
                    admin.antihammer[target] = nil
                    table.insert(output, name ..
                        ' has been removed from the antihammer whitelist.')
                else
                    admin.antihammer[target] = true
                    table.insert(output, name ..
                        ' has been added to the antihammer whitelist.')
                end
            end
        end
    elseif next(admin.antihammer) ~= nil then
        table.insert(output, '<b>Antihammered users:</b>')
        for id in pairs(admin.antihammer) do
            table.insert(output, '• ' .. utilities.lookup_name(bot, id))
        end

    else
        table.insert(output, 'There are no antihammer-whitelisted users.')
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
