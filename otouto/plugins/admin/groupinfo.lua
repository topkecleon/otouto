 -- Keep the group name and username in the db up to date.
 -- Also, log changes to the group title.

local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = {''}
    self.administration = true
    self.privilege = 2
    bot.database.groupdata.info = bot.database.groupdata.info or {}
end

function P:action(bot, msg, group, _user)
    local info = group.data.info

    if not info then
        group.data.info = msg.chat

    else
        if info.title ~= msg.chat.title then
            autils.log(bot, {
                chat_id = msg.chat.id,
                action = 'Title changed',
                reason = msg.chat.title,
                -- If this message isn't the message that changed it (the bot
                -- didn't notice the name change), the source will be unknown.
                source_id = msg.new_chat_title and msg.from.id or nil
            })
            info.title = msg.chat.title
        end

        if info.username ~= msg.chat.username then
            info.username = msg.chat.username
        end
    end

    return 'continue'
end

return P
