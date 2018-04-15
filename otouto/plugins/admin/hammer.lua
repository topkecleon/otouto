local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('hammer', true).table
    self.command = 'hammer'
    self.doc = "Globally bans a user or users. Targets can be unbanned with \z
/unhammer. A reason can be given on a new line. Example:\
    /hammer @examplus 5556789\
    Really bad jokes."
    self.privilege = 4
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output, reason = autils.targets(bot, msg)
    local hammered_users = utilities.new_set()

    for target in pairs(targets) do
        local name = utilities.lookup_name(bot, target)

        if autils.rank(bot, target, msg.chat.id) >= 4 then
            table.insert(output, name .. ' is an administrator.')
        elseif bot.database.userdata.hammered[target] then
            table.insert(output, name .. ' is already globally banned.')
        else
            bindings.kickChatMember{
                chat_id = msg.chat.id,
                user_id = target
            }
            bot.database.userdata.hammered[target] = true
            table.insert(output, name .. ' has been globally banned.')
            hammered_users:add(target)
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #hammered_users > 0 then
        autils.log(bot, {
            -- Do not send the chat ID from PMs or private groups.
            chat_id = group and group.data.admin
                and not group.data.admin.flags.private and msg.chat.id,
            targets = hammered_users,
            action = 'Globally banned',
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
