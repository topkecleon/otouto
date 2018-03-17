local bindings = require('otouto.bindings')
local autils = require('otouto.administration')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    self.named_plugins.flags.flags[P.name] = 'Stickers are filtered.'
    P.triggers = {''}
    P.internal = true
end

function P:action(msg, group, user)
    if group.flags.nostickers and msg.sticker then
        bindings.deleteMessage{
            message_id = msg.message_id,
            chat_id = msg.chat.id
        }
        autils.log(self, msg.chat.id,
            msg.from.id, 'Sticker deleted.', P.name)
    else
        return true
    end
end

return P
