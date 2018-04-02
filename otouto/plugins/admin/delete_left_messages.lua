local bindings = require('otouto.bindings')

local P = {}

function P:init(_bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'delete_left_messages'
    flags_plugin.flags[self.flag] =
        'Deletes left_chat_member messages. These deletions are not logged.'
    self.triggers = { '^$' }
    self.administration = true
end

function P:action(_bot, msg, _group, _user)
    if not group.data.admin.flags[self.flag] then return 'continue' end
    if msg.left_chat_member and msg.from.id == msg.left_chat_member.id then
        bindings.deleteMessage{
            chat_id = msg.chat.id,
            message_id = msg.message_id
        }
    else
        return 'continue'
    end
end

return P
