local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('regenlink').table
    P.command = 'regenlink'
    P.doc = 'Regenerates the group link.'
    P.internal = true
    P.privilege = 2
end

function P:action(msg, group)
    group.link = bindings.exportChatInviteLink{
        chat_id = msg.chat.id
    }.result
    utilities.send_reply(msg, 'The link has been regenerated.')
end

return P
