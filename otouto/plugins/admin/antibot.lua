--[[
    antibot.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'antibot'
    self.flag_desc = 'Only moderators may add bots.'
    flags_plugin.flags[self.flag] = self.flag_desc
    self.triggers = { '^$' }
    self.administration = true
end

function P:action(bot, msg, group, user)
    if
        group.data.admin.flags[self.flag]
        and msg.new_chat_member
        and msg.new_chat_member.is_bot
        and user:rank(bot, msg.chat.id) < 2
    then
        if bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.new_chat_member.id
        } then
            autils.log(bot, {
                chat_id = msg.chat.id,
                target = msg.new_chat_member.id,
                action = 'Bot removed',
                source = self.flag,
                reason = self.flag_desc
            })
        end
    else
        return 'continue'
    end
end

return P
