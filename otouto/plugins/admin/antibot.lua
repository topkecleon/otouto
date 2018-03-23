local bindings = require('otouto.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    P.flag_desc = 'Only moderators may add bots.'
    self.named_plugins.flags.flags[P.name] = P.flag_desc
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
            autils.log(self, {
                chat_id = msg.chat.id,
                target = msg.new_chat_member.id,
                action = 'Bot removed',
                source = P.name,
                reason = P.flag_desc
            })
        end
    else
        return true
    end
end

return P
