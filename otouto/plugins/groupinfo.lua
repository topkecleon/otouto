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
    if msg.new_chat_title then
        autils.log(self, {
            chat_id = msg.chat.id,
            source_id = msg.from.id,
            action_taken = 'Group name changed',
            reason = msg.new_chat_title
        })
    end

    group.name = msg.chat.title
    group.user = msg.chat.username

    return true
end

return P
