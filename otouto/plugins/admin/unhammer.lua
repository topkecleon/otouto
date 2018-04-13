local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('unhammer', true).table
    self.command = 'unhammer'
    self.privilege = 4
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output, reason = autils.targets(bot, msg)
    local admin = group.data.admin
    local unhammered_users = utilities.new_set()

    for target in pairs(targets) do
        local user = utilities.user(bot, target)
        if user.data.hammered then
            user.data.hammered = nil
            unhammered_users:add(target)
            table.insert(output, user:name() .. ' is no longer globally banned.')
        else
            table.insert(output, user:name() .. ' is not globally banned.')
        end
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #unhammered_users > 0 then
        autils.log(bot, {
            -- Do not send the chat ID from PMs or private groups.
            chat_id = admin and (not admin.flags.private) and msg.chat.id,
            targets = unhammered_users,
            action = "Unhammered",
            source_user = msg.from,
            reason = reason
        })
    end
end

return P
