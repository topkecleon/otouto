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
    local targets = autils.targets(bot, msg)
    local admin = group.data.admin
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local id_str = tostring(id)
                local name = utilities.lookup_name(bot, id)
                if admin.antihammer[id_str] then
                    admin.antihammer[id_str] = nil
                    table.insert(output, name ..
                        ' has been removed from the antihammer whitelist.')
                else
                    admin.antihammer[id_str] = true
                    table.insert(output, name ..
                        ' has been added to the antihammer whitelist.')
                end
            else
                table.insert(output, id)
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
