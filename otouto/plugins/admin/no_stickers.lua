--[[
    nostickers.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'no_stickers'
    self.flag_desc = 'Stickers are filtered.'
    flags_plugin.flags[self.flag] = self.flag_desc
    self.triggers = {'^$'}
    self.administration = true
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    if admin.flags[self.flag] and msg.sticker then
        bindings.deleteMessage{
            message_id = msg.message_id,
            chat_id = msg.chat.id
        }

        if msg.date >= (admin.last_nosticker_msg or -3600) + 3600 then -- 1h
            local success, result =
                utilities.send_message(msg.chat.id, 'Stickers are filtered.')
            if success then
                bot:do_later('core.delete_messages', os.time() + 5, {
                    chat_id = msg.chat.id,
                    message_id = result.result.message_id
                })
                admin.last_nosticker_msg = result.result.date
            end
        end

        autils.log(bot, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Sticker deleted',
            source = self.flag,
            reason = self.flag_desc
        })
    else
        return 'continue'
    end
end

return P
