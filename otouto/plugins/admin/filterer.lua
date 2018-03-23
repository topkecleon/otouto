local bindings = require('otouto.bindings')
local autils = require('otouto.autils')
local utilities = require('otouto.utilities')
local rot13 = require('otouto.rot13')

local P = {}

function P:init() -- luacheck: ignore self
    P.triggers = {''}
    P.administration = true
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
            autils.log(self, {
                chat_id = msg.chat.id,
                target = msg.from.id,
                action = 'Message deleted',
                source = P.name,
                reason = utilities.html_escape(rot13.cipher(group.filter[i]))
            })
            return
        end
    end
    return true
end

P.edit_action = P.action

return P
