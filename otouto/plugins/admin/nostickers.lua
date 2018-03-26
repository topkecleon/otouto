local bindings = require('otouto.bindings')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'nostickers'
    self.flag_desc = 'Stickers are filtered.'
    flags_plugin.flags[self.flag] = self.flag_desc
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, group, _user)
    if group.flags[self.flag] and msg.sticker then
        bindings.deleteMessage{
            message_id = msg.message_id,
            chat_id = msg.chat.id
        }
        autils.log(bot, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Sticker deleted',
            source = self.flag,
            reason = self.flag_desc
        })
    else
        return true
    end
end

return P
