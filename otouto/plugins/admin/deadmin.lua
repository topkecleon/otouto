local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('deadmin', true).table
    self.privilege = 5
    self.command = 'deadmin'
    self.doc = 'Demotes an administrator or administrators.'
    self.targeting = true
end

function P:action(bot, msg, _group, _user)
    local targets, output = autils.targets(bot, msg)
    if targets then
        for target in pairs(targets) do
            local name = utilities.lookup_name(bot, target)
            if bot.database.userdata.administrators[target] then
                bot.database.userdata.administrators[target] = nil
                for chat_id in pairs(bot.database.groupdata.admin) do
                    if autils.rank(bot, target, chat_id) < 2 then
                        autils.demote_admin(chat_id, target)
                    end
                end
                table.insert(output, name .. ' is no longer an administrator.')
            else
                table.insert(output, name .. ' is not an administrator.')
            end
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
