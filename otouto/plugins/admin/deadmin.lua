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
    local targets = autils.targets(bot, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                if bot.database.userdata.administrators[tostring(id)] then
                    bot.database.userdata.administrators[tostring(id)] =
                        nil
                    for chat_id in pairs(bot.database.administration.groups) do
                        if autils.rank(bot, id, chat_id) < 2 then
                            autils.demote_admin(chat_id, id)
                        end
                    end
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' is no longer an administrator.')
                else
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' is not an administrator.')
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
