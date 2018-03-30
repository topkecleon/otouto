 -- Keep the group name and username in the db up to date.
 -- Also, log changes to the group title.

local autils = require('otouto.autils')

local P = {}

function P:init(_bot)
    self.triggers = {''}
    self.administration = true
    self.privilege = 2
end

function P:action(bot, msg, group)
    local admin = group.data.admin
    admin.username = msg.chat.username
    -- Log when the chat title has been changed.
    if msg.chat.title ~= admin.name then
        autils.log(bot, {
            chat_id = msg.chat.id,
            action = 'Title changed',
            reason = msg.chat.title,
            -- If this message isn't the message that changed it (the bot didn't
            -- notice the name change), the source will be unknown.
            source_id = msg.new_chat_title and msg.from.id or nil
        })
        admin.name = msg.chat.title
    end
    return true
end

return P
