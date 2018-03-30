local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('admins').table
    self.command = 'admins'
    self.doc = 'Returns a list of global administrators.'
    self.privilege = 2
end

function P:action(bot, msg, _group, _user)
    local admin_list = { utilities.lookup_name(bot, bot.config.admin) .. ' ★' }
    for id_str in pairs(bot.database.userdata.administrators) do
        table.insert(admin_list, utilities.lookup_name(bot, id_str))
    end
    local output = '<b>Global administrators:</b>\n• ' ..
        table.concat(admin_list, '\n• ')
    utilities.send_reply(msg, output, 'html')
end

return P
