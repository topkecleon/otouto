local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = {''}
    P.internal = true
end

function P:action(msg, group, user)
    if user.rank > 1 then return true end
    if msg.forward_from and (
        (msg.forward_from.id == self.info.id) or
        (msg.forward_from.id == self.config.log_chat) or
        (msg.forward_from.id == self.config.administration.log_chat)
    ) then
        return true
    end
    for i = 1, #group.filter do
        if msg.text_lower:match(group.filter[i]) then
            bindings.deleteMessage{
                message_id = msg.message_id,
                chat_id = msg.chat.id
            }
            autils.log(self, msg.chat.title,
                msg.from.id, 'Message deleted.', 'filter')
            return
        end
    end
    return true
end

P.edit_action = P.action

return P
