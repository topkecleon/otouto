local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('kickme').table
    self.command = 'kickme'
    self.doc = 'Removes the user from the group.'
    self.administration = true
end

function P:action(bot, msg)
    bindings.deleteMessage{
        chat_id = msg.chat.id,
        message_id = msg.message_id
    }
    if bindings.kickChatMember{
        chat_id = msg.chat.id,
        user_id = msg.from.id,
        until_date = msg.date + 60
    } then
        autils.log(bot, {
            chat_id = msg.chat.id,
            target = msg.from.id,
            action = 'Kicked for one minute',
            source = 'kickme'
        })
    end
end

return P
