local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('fixperms', true).table
    self.command = 'fixperms'
    self.doc = 'Fixes local permissions for the user or specified target.'
    self.privilege = 1
    self.targeting = true
end

function P:action(bot, msg, _group, _user)
    local targets = autils.targets(bot, msg)
    local target = targets and tonumber(targets[1]) or msg.from.id
    local rank = autils.rank(bot, target, msg.chat.id)
    if rank >= 3 then
        autils.promote_admin(msg.chat.id, target, true)
    elseif rank == 2 then
        autils.promote_admin(msg.chat.id, target)
    else
        autils.demote_admin(msg.chat.id, target)
    end
    utilities.send_reply(msg, 'Permissions have been corrected for ' ..
        utilities.format_name(bot, target) .. '.', 'html')
end

return P
