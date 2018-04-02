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
    local targets, output = autils.targets(bot, msg, {unknown_ids_err = true})
    for target in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        if autils.rank(bot, target) > 3 then
            table.insert(output, name .. ' is already an administrator.')
        else
            bot.database.userdata.administrators[tostring(target)] = true
            table.insert(output, name .. ' is now an administrator.')
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
