local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('governor', true):t('gov', true).table
    P.command = 'governor <user>'
    P.doc = 'Set the group\'s governor.'
    P.privilege = 3
    P.internal = true
end

function P:action(msg, group)
    local targets = autils.targets(self, msg)
    local target = targets and targets[1]
    local output
    if tonumber(target) then
        local name = utilities.format_name(self, target)
        autils.promote_admin(msg.chat.id, target, true)
        if target == group.governor then
            output = name .. ' is already governor.'
        else
            -- Demote the old governor if he's not an admin.
            if autils.rank(self, group.governor, msg.chat.id) < 4 then
                autils.demote_admin(msg.chat.id, group.governor)
            end

            group.moderators[tostring(target)] = nil
            group.bans[tostring(target)] = nil
            group.governor = target
            output = name .. ' is now governor.'
        end
    elseif not target then
        output = self.config.errors.specify_target
    else
        output = target
    end
    utilities.send_reply(msg, output, 'html')
end

return P
