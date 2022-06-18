local utilities = require('otouto.utilities')
local bindings = require('extern.bindings')
local json = require('dkjson')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('dump').table
    self.command = 'dump'
    self.doc = 'Dumps JSON of the replied-to message or the command.'
end

function P:action(bot, msg)
    if msg.reply_to_message then
        bindings.sendMessage{
            chat_id = msg.chat.id,
            reply_to_message_id = msg.message_id,
            text = '<code>' .. utilities.html_escape(
                json.encode(msg.reply_to_message, { indent = true })
            ) .. '</code>',
            parse_mode = 'HTML'
        }
    else
        bindings.sendMessage{
            chat_id = msg.chat.id,
            reply_to_message_id = msg.message_id,
            text = '<code>' .. utilities.html_escape(
                json.encode(msg, { indent = true })
            ) .. '</code>',
            parse_mode = 'HTML'
        }
    end
end

return P
