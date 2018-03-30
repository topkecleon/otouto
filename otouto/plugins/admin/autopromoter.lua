 -- Promotes mods & admins when they join a group.
local autils = require('otouto.autils')

local P = {}

function P:init(_bot)
    self.triggers = {'^$'}
    self.administration = true
end

function P:action(bot, msg, _group, _user)
    if msg.new_chat_member then
        local rank = autils.rank(bot, msg.new_chat_member.id, msg.chat.id)
        if rank > 1 then
            autils.promote_admin(msg.chat.id, msg.new_chat_member.id, rank > 2)
        end
    end
    return 'continue'
end

return P
