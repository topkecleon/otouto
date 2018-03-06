 -- Allow group administrators to clear reminders.

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local P = {}

function P:init()
    assert(self.named_plugins.remind,
        'clear_reminders.lua requires remind.lua to be loaded first.')
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('clear_reminders').table
    P.command = 'clear_reminders'
    P.doc = 'Removes all reminders for the current group. Only an administrator can use this command.'
end

function P:action(msg)
    local res = bindings.getChatMember{chat_id = msg.chat.id,
        user_id = msg.from.id}
    local output
    if res then
        if res.result.status == 'creator' or res.result.status == 'administrator' then
            self.database.remind[tostring(msg.chat.id)] = {}
            output = 'Reminders for this group have been cleared.'
        else
            output = 'You must be an administrator to use this command.'
        end
    else
        output = self.config.errors.connection
    end
    utilities.send_reply(msg, output)
end

return P
