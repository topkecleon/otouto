local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('fixperms', true).table
    self.command = 'fixperms'
    self.doc = 'Fixes local permissions for the user or specified target.'
    self.privilege = 2
    self.targeting = true
end

function P:action(bot, msg)
    local targets, output = autils.targets(bot, msg, {self_targeting = true})
    for target in pairs(targets) do
        local rank = autils.rank(bot, msg.chat.id, target)
        local name = utilities.lookup_name(bot, target)
        local res, err
        if rank >= 3 then
            res, err = autils.promote_admin(msg.chat.id, target, true)
        elseif rank == 2 then
            res, err = autils.promote_admin(msg.chat.id, target)
        else
            res, err = autils.demote_admin(msg.chat.id, target)
        end
        if res then
            table.insert(output,
                'Permissions have been corrected for ' .. name .. '.')
        else
            table.insert(output, 'Error correcting permissions for ' ..
                name .. ': ' .. err.description)
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
