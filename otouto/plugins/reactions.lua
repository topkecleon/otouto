 -- Never change this plugin. It was not meant to be changed.
 -- You may add reactions. You must never remove reactions.
 -- You must never restructure. You must never disable this plugin.
 -- - Drew, creator, a year later.

 -- Nevermind, Brayden changed it.
 -- - Drew, just now.

local reactions = {}

local utilities = require('otouto.utilities')

reactions.command = 'reactions'
reactions.doc = 'Returns a list of "reaction" emoticon commands.'

local help

function reactions:init(config)
    -- Generate a "help" message triggered by "/reactions".
    help = 'Reactions:\n'
    reactions.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('reactions').table
    local username = self.info.username:lower()
    for trigger,reaction in pairs(config.reactions) do
        help = help .. '• ' .. config.cmd_pat .. trigger .. ': ' .. reaction .. '\n'
        table.insert(reactions.triggers, '^'..config.cmd_pat..trigger)
        table.insert(reactions.triggers, '^'..config.cmd_pat..trigger..'@'..username)
        table.insert(reactions.triggers, config.cmd_pat..trigger..'$')
        table.insert(reactions.triggers, config.cmd_pat..trigger..'@'..username..'$')
        table.insert(reactions.triggers, '\n'..config.cmd_pat..trigger)
        table.insert(reactions.triggers, '\n'..config.cmd_pat..trigger..'@'..username)
        table.insert(reactions.triggers, config.cmd_pat..trigger..'\n')
        table.insert(reactions.triggers, config.cmd_pat..trigger..'@'..username..'\n')
    end
end

function reactions:action(msg, config)
    if string.match(msg.text_lower, config.cmd_pat..'reactions') then
        utilities.send_message(self, msg.chat.id, help)
        return
    end
    for trigger,reaction in pairs(config.reactions) do
        if string.match(msg.text_lower, config.cmd_pat..trigger) then
            utilities.send_message(self, msg.chat.id, reaction)
            return
        end
    end
end

return reactions
