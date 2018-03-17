local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('fixperms', true).table
    P.command = 'fixperms'
    P.doc = 'Fixes local permissions for the user or specified target.'
    P.privilege = 1
    P.targeting = true
end

function P:action(msg, group, user)
    local targets = autils.targets(self, msg)
    local target = targets and tonumber(targets[1]) or msg.from.id
    local rank = autils.rank(self, target, msg.chat.id)
    if rank >= 3 then
        autils.promote_admin(msg.chat.id, target, true)
    elseif rank == 2 then
        autils.promote_admin(msg.chat.id, target)
    else
        autils.demote_admin(msg.chat.id, target)
    end
    utilities.send_reply(msg, 'Permissions have been corrected for ' ..
        utilities.format_name(self, target) .. '.', 'html')
end

return P
