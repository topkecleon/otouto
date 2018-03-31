local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('demod', true).table
    self.command = 'demod'
    self.doc = 'Demotes a moderator.'
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, errors = autils.targets(bot, msg)
    local output = {}

    if targets then
        for target in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            local admin = group.data.admin
            if autils.rank(bot, target, msg.chat.id) < 3 then
                autils.demote_admin(msg.chat.id, target)
            end
            if admin.moderators[target] then
                admin.moderators[target] = nil
                table.insert(output, name .. ' is no longer a moderator.')
            else
                table.insert(output, name .. ' is not a moderator.')
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end
    utilities.merge_arrs(output, errors)
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
