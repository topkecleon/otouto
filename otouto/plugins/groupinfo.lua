 -- Keep the group name and username in the db up to date.
 -- Also, log changes to the group title.

local autils = require('otouto.administration')

local P = {}

function P:init()
    P.triggers = {''}
    P.internal = true
    P.privilege = 2
end

function P:action(msg, group)
    group.username = msg.chat.username
    -- Log when the chat title has been changed.
    if msg.chat.title ~= group.name then
        autils.log(self, {
            chat_id = msg.chat.id,
            action = 'Title changed',
            reason = msg.chat.title,
            -- If this message isn't the message that changed it (the bot didn't
            -- notice the name change), the source will be unknown.
            source_id = msg.new_chat_title and msg.from.id or nil
        })
        group.name = msg.chat.title
    end
    return true
end

return P
