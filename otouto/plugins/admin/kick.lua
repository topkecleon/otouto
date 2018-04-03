local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('kick', true).table
    self.command = 'kick'
    self.doc = "Removes a user or users from the group. A reason can be given \z
on a new line. Example:\
    /kick @examplus 5554321\
    Bad jokes."
    self.privilege = 2
    self.administration = true
    self.targeting = true
    self.duration = true
end

function P:action(bot, msg, _group, _user)
    local targets, output, reason = autils.targets(bot, msg)
    local kicked_users = utilities.new_set()

    for target in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        if autils.rank(bot, target, msg.chat.id) > 2 then
            table.insert(output, name .. ' is too privileged to be kicked.')
        else
            -- It isn't documented, but unbanChatMember also kicks.
            local a, b = bindings.unbanChatMember{
                chat_id = msg.chat.id,
                user_id = target
            }
            if a then
                table.insert(output, name .. ' has been kicked.')
            else
                table.insert(output, 'Error kicking ' .. name .. ': ' ..
                    b.result.description)
            end
            kicked_users:add(target)
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #kicked_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = kicked_users,
            action = 'Kicked',
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
