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
    local targets = autils.targets(bot, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if not tonumber(id) then
                table.insert(output, id)

            else
                local id_str = tostring(id)
                local name = utilities.format_name(bot, id)
                local admin = group.data.admin
                if autils.rank(bot, id, msg.chat.id) < 3 then
                    autils.demote_admin(msg.chat.id, id)
                end
                if admin.moderators[id_str] then
                    admin.moderators[id_str] = nil
                    table.insert(output, name .. ' is no longer a moderator.')
                else
                    table.insert(output, name .. ' is not a moderator.')
                end
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
