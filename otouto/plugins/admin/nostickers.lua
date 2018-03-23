local bindings = require('otouto.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    P.flag_desc = 'Stickers are filtered.'
    self.named_plugins.flags.flags[P.name] = P.flag_desc
    P.triggers = {''}
    P.administration = true
end

function P:action(msg, group, _user)
    if group.flags.nostickers and msg.sticker then
        bindings.deleteMessage{
            message_id = msg.message_id,
            chat_id = msg.chat.id
        }
        autils.log(self, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Sticker deleted',
            source = P.name,
            reason = P.flag_desc
        })
    else
        return true
    end
end

return P
