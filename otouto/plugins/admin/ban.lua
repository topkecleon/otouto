local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('ban', true).table
    self.command = 'ban'
    self.doc = "Bans a user or users from the group. Targets can be unbanned \z
with /unban. A reason can be given on a new line. Example:\
    /ban @examplus 5551234\
    Bad jokes."

    self.privilege = 2
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    local targets, errors, reason = autils.targets(bot, msg)
    local output = {}
    local banned_users = {}

    if targets then
        for id_str in pairs(targets) do
            local id = tonumber(id_str)
            local name = utilities.lookup_name(bot, id)
            if autils.rank(bot, id, msg.chat.id) > 2 then
                table.insert(output, name .. ' is too privileged to be banned.')
            elseif admin.bans[id_str] then
                table.insert(output, name .. ' is already banned.')
            else
                admin.bans[id_str] = true
                bindings.kickChatMember{
                    chat_id = msg.chat.id,
                    user_id = id
                }
                table.insert(output, name .. ' has been banned.')
                banned_users[id_str] = true
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end

    utilities.merge_arrs(output, errors)
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if utilities.table_size(banned_users) > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = banned_users,
            action = 'Banned',
            source_id = msg.from.id,
            reason = reason
        })
    end
end

return P
