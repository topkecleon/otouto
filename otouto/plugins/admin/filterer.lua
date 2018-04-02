local bindings = require('otouto.bindings')
local autils = require('otouto.autils')
local utilities = require('otouto.utilities')
local rot13 = require('otouto.rot13')

local P = {}

function P:init(_bot)
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, group, user)
    if user:rank(bot) > 1 then return 'continue' end
    if msg.forward_from and (
        (msg.forward_from.id == bot.info.id) or
        (msg.forward_from.id == bot.config.log_chat) or
        (msg.forward_from.id == bot.config.administration.log_chat)
    ) then
        return 'continue'
    end
    local admin = group.data.admin
    for i = 1, #admin.filter do
        if msg.text_lower:match(admin.filter[i]) then
            bindings.deleteMessage{
                message_id = msg.message_id,
                chat_id = msg.chat.id
            }
            autils.log(bot, {
                chat_id = msg.chat.id,
                target = msg.from.id,
                action = 'Message deleted',
                source = self.name,
                reason = utilities.html_escape(rot13.cipher(admin.filter[i]))
            })
            return
        end
    end
    return 'continue'
end

P.edit_action = P.action

return P
