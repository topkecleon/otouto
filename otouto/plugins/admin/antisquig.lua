--[[
    antisquig.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'antisquig'
    flags_plugin.flags[self.flag] =
        'Arabic script is not allowed in messages.'
    self.triggers = {
        utilities.char.arabic,
        utilities.char.rtl_override,
        utilities.char.rtl_mark
    }
    self.administration = true
end

function P:action(bot, msg, group, user)
    if not group.data.admin.flags[self.flag] then return 'continue' end
    if user:rank(bot, msg.chat.id) > 1 then return 'continue' end
    if msg.forward_from and (
        msg.forward_from.id == bot.info.id or
        msg.forward_from.id == bot.config.log_chat or
        msg.forward_from.id == bot.config.administration.log_chat
    ) then
        return 'continue'
    end

    autils.strike(bot, msg, self.flag)
end

P.edit_action = P.action

return P
