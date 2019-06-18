--[[
    list_mods.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('mods'):t('ops'):t('list_?mods').table
    self.command = 'mods'
    self.doc = 'Returns a list of group moderators.'
    self.administration = true
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    local mod_list = utilities.list_names(bot, admin.moderators)
    table.insert(mod_list, 1, '\n\n<b>Moderators:</b>')
    local output = '<b>Governor:</b> ' .. utilities.lookup_name(bot,
        admin.governor) .. table.concat(mod_list, '\n• ')
    utilities.send_reply(msg, output, 'html')
end

return P
