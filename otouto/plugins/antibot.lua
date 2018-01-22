local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    self.named_plugins.flags.flags[P.name] = 'Only moderators may add bots.'
    P.triggers = { '' }
    P.internal = true
end

function P:action(msg, group, user)
    if
        group.flags.antibot and
        msg.new_chat_member and
        msg.new_chat_member.is_bot and
        user.rank < 2
    then
        if bindings.kickChatMember{
            chat_id = msg.chat.id,
            user_id = msg.new_chat_member.id
        } then
            autils.log(self, msg.chat.title, msg.new_chat_member.id,
                'Bot removed.', 'antibot',
                self.named_plugins.flags.flags.antibot)
        end
    else
        return true
    end
end

return P
