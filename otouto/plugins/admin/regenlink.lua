local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('regenlink').table
    self.command = 'regenlink'
    self.doc = 'Regenerates the group link.'
    self.administration = true
    self.privilege = 2
end

function P:action(_bot, msg, group)
    group.link = bindings.exportChatInviteLink{
        chat_id = msg.chat.id
    }.result
    utilities.send_reply(msg, 'The link has been regenerated.')
end

return P
