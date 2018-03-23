local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('antihammer', true).table
    P.command = 'antihammer'
    P.doc = 'Returns a list of users whoo are antihammered (unaffected by a \z
hammer inside this group), or toggles the whitelist status of the specified users.'
    P.privilege = 3
    P.administration = true
    P.targeting = true
end

function P:action(msg, group)
    local targets = autils.targets(self, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local id_str = tostring(id)
                local name = utilities.format_name(self, id)
                if group.antihammer[id_str] then
                    group.antihammer[id_str] = nil
                    table.insert(output, name ..
                        ' has been removed from the antihammer whitelist.')
                else
                    group.antihammer[id_str] = true
                    table.insert(output, name ..
                        ' has been added to the antihammer whitelist.')
                end
            else
                table.insert(output, id)
            end
        end

    elseif next(group.antihammer) ~= nil then
        table.insert(output, '<b>Antihammered users:</b>')
        for id in pairs(group.antihammer) do
            table.insert(output, '• ' .. utilities.format_name(self, id))
        end

    else
        table.insert(output, 'There are no antihammer-whitelisted users.')
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
