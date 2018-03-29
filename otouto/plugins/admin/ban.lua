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
    local targets, reason = autils.targets(bot, msg)
    local output = {}
    local banned_users = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(bot, id)
                local admin = group.data.admin
                if autils.rank(bot, id, msg.chat.id) > 2 then
                    table.insert(output, name .. ' is too privileged to be banned.')
                elseif admin.bans[tostring(id)] then
                    table.insert(output, name .. ' is already banned.')
                else
                    admin.bans[tostring(id)] = true
                    bindings.kickChatMember{
                        chat_id = msg.chat.id,
                        user_id = id
                    }
                    table.insert(output, name .. ' has been banned.')
                    table.insert(banned_users, id)
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #banned_users > 0 then
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
