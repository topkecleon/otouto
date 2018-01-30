local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('admin', true):t('addadmin', true).table
    P.privilege = 5
    P.command = 'admin'
    P.doc = 'Promotes a user or users to administrator(s).'
    P.targeting = true
end

function P:action(msg, group, user)
    local targets = autils.targets(self, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                if autils.rank(self, id) > 3 then
                    table.insert(output, utilities.format_name(self, id) ..
                        ' is already an administrator.')
                else
                    self.database.administration.administrators[tostring(id)] =
                        true
                    table.insert(output, utilities.format_name(self, id) ..
                        ' is now an administrator.')
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
