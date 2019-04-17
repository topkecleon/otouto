--[[
    addadmin.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

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
    for target, _ in pairs(targets) do
        local user = utilities.user(bot, target)
        if user:rank(bot, msg.chat.id) > 3 then
            table.insert(output, user:name() .. ' is already an administrator.')
        else
            user.data.administrator = true
            table.insert(output, user:name() .. ' is now an administrator.')
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

P.list = {
    name = 'admins',
    title = 'Global Administrators',
    type = 'userdata',
    key = 'administrator'
}

return P
