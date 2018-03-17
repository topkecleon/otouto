local bindings = require('otouto.bindings')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = {''}
    P.internal = true
    P.privilege = 0
end

function P:action(msg, group, user)
    if user.rank == 0 then
        bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.from.id
        }
        bindings.deleteMessage{
            chat_id = msg.chat.id,
            message_id = msg.message_id
        }
        autils.log(self, msg.chat.id, msg.from.id,
            'Kicked and message deleted', P.name, 'User is banned.')
    elseif msg.new_chat_member then
        if autils.rank(self, msg.new_chat_member.id, msg.chat.id) == 0 then
            bindings.kickChatMember{
                chat_id = msg.chat.id,
                user_id = msg.new_chat_member.id
            }
            bindings.deleteMessage{
                chat_id = msg.chat.id,
                message_id = msg.message_id
            }
            autils.log(self, msg.chat.id, msg.new_chat_member.id,
                'Kicked', P.name, 'User is banned.')
        else
            return true
        end
    else
        return true
    end
end

return P
