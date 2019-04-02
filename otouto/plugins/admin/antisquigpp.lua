--[[
    antisquigpp.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')
local bindings = require('otouto.bindings')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag_desc = 'Arabic script is not allowed in names.'
    self.flag = 'antisquigpp'
    flags_plugin.flags[self.flag] = self.flag_desc
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, group, user)
    if not group.data.admin.flags[self.flag] then return 'continue' end
    if user:rank(bot, msg.chat.id) > 1 then return 'continue' end
    local name = utilities.build_name(user.data.info.first_name, user.data.info.last_name)
    if name:match(utilities.char.arabic) or
        name:match(utilities.char.rtl_override) or
        name:match(utilities.char.rtl_mark)
    then
        bindings.deleteMessage{
            chat_id = msg.chat.id,
            message_id = msg.message_id
        }

        local success, result = bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id
        }

        autils.log(bot, {
            source = self.flag,
            reason = self.flag_desc,
            target = msg.from.id,
            chat_id = msg.chat.id,
            action = success and 'Kicked' or result.description
        })
    else
        return 'continue'
    end
end

return P
