local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('kickme').table
    P.command = 'kickme'
    P.doc = 'Removes the user from the group.'
    P.administration = true
end

function P:action(msg)
    bindings.deleteMessage{
        chat_id = msg.chat.id,
        message_id = msg.message_id
    }
    if bindings.kickChatMember{
        chat_id = msg.chat.id,
        user_id = msg.from.id,
        until_date = msg.date + 60
    } then
        autils.log(self, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Kicked for one minute',
            source = 'kickme'
        })
    end
end

return P
