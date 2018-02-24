local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('unhammer', true).table
    P.command = 'unhammer'
    P.privilege = 4
    P.targeting = true
end

function P:action(msg, group)
    local targets = autils.targets(self, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(self, id)
                local id_str = tostring(id)
                if self.database.administration.hammers[id_str] then
                    self.database.administration.hammers[id_str] = nil
                    table.insert(output, name..' is no longer globally banned.')
                else
                    table.insert(output, name .. ' is not globally banned.')
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
