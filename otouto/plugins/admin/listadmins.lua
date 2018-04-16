--[[
    listadmins.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('admins'):t('listadmins').table
    self.command = 'admins'
    self.doc = 'Returns a list of global administrators.'
    self.privilege = 2
end

function P:action(bot, msg, _group, _user)
    local admin_list =
        utilities.list_names(bot, bot.database.userdata.administrator)
    table.insert(admin_list, 1,
        utilities.lookup_name(bot, bot.config.admin) .. ' ★')
    table.insert(admin_list, 1, '<b>Global administrators:</b>')
    utilities.send_reply(msg, table.concat(admin_list, '\n• '), 'html')
end

return P
