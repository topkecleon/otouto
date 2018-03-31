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

function P:action(bot, msg, _group)
    local targets, errors, reason = autils.targets(bot, msg)
    local output, unhammered_users = {}, {}

    if targets then
        for target in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            if bot.database.userdata.hammers[target] then
                bot.database.userdata.hammers[target] = nil
                table.insert(output, name..' is no longer globally banned.')
                unhammered_users[target] = true
            else
                table.insert(output, name .. ' is not globally banned.')
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end

    utilities.merge_arrs(output, errors)
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
    if #unhammered_users > 0 then
        autils.log(bot, {
            chat_id = msg.chat.id,
            targets = unhammered_users,
            action = "Unhammered",
            source_id = msg.from.id,
            reason = reason
        })
    end
end

return P
