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
    if user:rank(bot, msg.chat.id) > 1 then return 'continue' end
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

            if msg.date >= (admin.last_filter_msg or -3600) + 3600 then -- 1h
                local success, result = utilities.send_message(msg.chat.id,
                    'Deleted a filtered term.')
                if success then
                    bot:do_later('core.delete_messages', os.time() + 5, {
                        chat_id = msg.chat.id,
                        message_id = result.result.message_id
                    })
                    admin.last_filter_msg = result.result.date
                end
            end

            autils.log(bot, {
                chat_id = msg.chat.id,
                target = msg.from.id,
                action = 'Message deleted',
                source = self.name,
                reason = 'ROT13: ' ..
                    utilities.html_escape(rot13.cipher(admin.filter[i]))
            })
            return
        end
    end

    return 'continue'
end

P.edit_action = P.action

return P
