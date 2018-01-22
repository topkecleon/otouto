local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('hammer', true).table
    P.command = 'hammer*'
    P.privilege = 4
end

function P:action(msg, group)
    local targets, reason = autils.target(self, msg)
    local output = {}
    local hammered_users = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(self, id)
                local id_str = tostring(id)

                if autils.rank(self, id, msg.chat.id) >= 4 then
                    table.insert(output, name .. ' is an administrator.')
                elseif self.database.administration.hammers[id_str] then
                    table.insert(output, name .. ' is already globally banned.')
                else
                    self.database.administration.hammers[id_str] = true
                    table.insert(output, name .. ' has been globally banned.')
                    table.insert(hammered_users, id)
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #hammered_users > 0 then
        autils.log(self, msg.chat.title, hammered_users, 'Globally banned.',
            utilities.format_name(self, msg.from.id))
    end
end

return P
