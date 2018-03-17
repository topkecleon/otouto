local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('mod', true):t('addmod', true):t('op', true).table
    P.command = 'addmod'
    P.doc = 'Promotes a user to a moderator.'
    P.privilege = 3
    P.internal = true
    P.targeting = true
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
                local rank = autils.rank(self, id, msg.chat.id)

                if rank > 2 then
                    autils.promote_admin(msg.chat.id, id, true)
                    table.insert(output, name ..
                        ' is greater than a moderator.')
                else
                    autils.promote_admin(msg.chat.id, id)
                    if group.moderators[id_str] then
                        table.insert(output, name .. ' is already a moderator.')
                    else
                        group.moderators[id_str] = true
                        group.bans[id_str] = nil
                        table.insert(output, name .. ' is now a moderator.')
                    end
                end
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
