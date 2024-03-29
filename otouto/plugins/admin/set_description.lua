--[[
    set_description.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('set_?description', true):t('set_?desc', true).table
    self.command = 'setdesc <text>'
    self.doc = 'Set a group description. Passing "--" will delete the current one.'
    self.privilege = 3
    self.administration = true
end

function P:action(_bot, msg, group)
    local admin = group.data.admin
    local input = utilities.input_from_msg(msg)
    if not input then
        if admin.description then
            utilities.send_reply(msg, '</b>Current description:</b>\n' ..
                admin.description, 'html')
        else
            utilities.send_reply(msg, 'This group has no description.')
        end
    elseif input == '--' or input == utilities.char.em_dash then
        admin.description = nil
        utilities.send_reply(msg, 'The group description has been cleared.')
    else
        admin.description = input
        utilities.send_reply(msg, '<b>Description updated:</b>\n' ..
            admin.description, 'html')
    end
end

return P
