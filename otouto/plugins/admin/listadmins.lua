local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('admins').table
    P.command = 'admins'
    P.doc = 'Returns a list of global administrators.'
    P.privilege = 2
end

function P:action(msg, _group, _user)
    local admin_list = {
        utilities.format_name(self, self.config.admin) .. ' ★'
    }
    for id_str in pairs(self.database.administration.administrators) do
        table.insert(admin_list, utilities.format_name(self, id_str))
    end
    local output = '<b>Global administrators:</b>\n• ' ..
        table.concat(admin_list, '\n• ')
    utilities.send_reply(msg, output, 'html')
end

return P
