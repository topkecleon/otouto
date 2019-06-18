--[[
    ban_remover.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init(_bot)
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, _group, user)
    if user:rank(bot, msg.chat.id) == 0 then
        bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id
        }
        bindings.deleteMessage{
            chat_id = msg.chat.id,
            message_id = msg.message_id
        }
        autils.log(bot, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Kicked and message deleted',
            source = self.name,
            reason = 'User is banned.'
        })
        if msg.new_chat_member then
            bindings.kickChatMember {
                chat_id = msg.chat.id,
                user_id = msg.new_chat_member.id
            }
        end
    elseif msg.new_chat_member then
        if autils.rank(bot, msg.new_chat_member.id, msg.chat.id) == 0 then
            bindings.kickChatMember{
                chat_id = msg.chat.id,
                user_id = msg.new_chat_member.id
            }
            bindings.deleteMessage{
                chat_id = msg.chat.id,
                message_id = msg.message_id
            }
            autils.log(bot, {
                chat_id = msg.chat.id,
                target = msg.new_chat_member.id,
                action = 'Kicked',
                source = self.name,
                reason = 'User is banned.'
            })
        else
            return 'continue'
        end
    else
        return 'continue'
    end
end

return P
