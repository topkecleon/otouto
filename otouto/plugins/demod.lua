local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('demod', true).table
    P.command = 'demod*'
    P.doc = 'Demotes a moderator.'
    P.privilege = 3
    P.internal = true
end

function P:action(msg, group)
    local targets = autils.targets(self, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if not tonumber(id) then
                table.insert(output, id)

            else
                local id_str = tostring(id)
                local name = utilities.format_name(self, id)
                if autils.rank(self, id, msg.chat.id) < 3 then
                    autils.demote_admin(msg.chat.id, id)
                end
                if group.moderators[id_str] then
                    group.moderators[id_str] = nil
                    table.insert(output, name .. ' is no longer a moderator.')
                else
                    table.insert(output, name .. ' is not a moderator.')
                end
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
