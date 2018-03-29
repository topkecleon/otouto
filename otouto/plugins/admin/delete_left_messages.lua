local bindings = require('otouto.bindings')

local P = {}

function P:init(_bot)
    self.triggers = { '^$' }
    self.administration = true
end

function P:action(_bot, msg, _group, _user)
    if msg.left_chat_member and msg.from.id == msg.left_chat_member.id then
        bindings.deleteMessage{
            chat_id = msg.chat.id,
            message_id = msg.message_id
        }
    else
        return true
    end
end

return P
