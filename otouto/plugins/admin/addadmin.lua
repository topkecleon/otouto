local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('admin', true):t('addadmin', true).table
    self.privilege = 5
    self.command = 'admin'
    self.doc = 'Promotes a user or users to administrator(s).'
    self.targeting = true
end

function P:action(bot, msg, _group, _user)
    local targets = autils.targets(bot, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                if autils.rank(bot, id) > 3 then
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' is already an administrator.')
                else
                    bot.database.administration.administrators[tostring(id)] =
                        true
                    table.insert(output, utilities.format_name(bot, id) ..
                        ' is now an administrator.')
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
