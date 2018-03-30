local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('mod', true):t('addmod', true):t('op', true).table
    self.command = 'addmod'
    self.doc = 'Promotes a user to a moderator.'
    self.privilege = 3
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets = autils.targets(bot, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local id_str = tostring(id)
                local name = utilities.lookup_name(bot, id)
                local rank = autils.rank(bot, id, msg.chat.id)

                if rank > 2 then
                    autils.promote_admin(msg.chat.id, id, true)
                    table.insert(output, name ..
                        ' is greater than a moderator.')
                else
                    autils.promote_admin(msg.chat.id, id)
                    local admin = group.data.admin
                    if admin.moderators[id_str] then
                        table.insert(output, name .. ' is already a moderator.')
                    else
                        admin.moderators[id_str] = true
                        admin.bans[id_str] = nil
                        table.insert(output, name .. ' is now a moderator.')
                    end
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
