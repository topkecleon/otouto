local reactions = {}

local utilities = require('otouto.utilities')

reactions.command = 'reactions'
reactions.doc = 'Returns a list of "reaction" emoticon commands.'

function reactions:init(config)
    -- Generate a command list message triggered by "/reactions".
    reactions.help = 'Reactions:\n'
    reactions.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('reactions').table
    local username = self.info.username:lower()
    for trigger, reaction in pairs(config.reactions) do
        reactions.help = reactions.help .. '• ' .. config.cmd_pat .. trigger .. ': ' .. reaction .. '\n'
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
        utilities.send_message(self, msg.chat.id, reactions.help, true, nil, 'html')
        return
    end
    for trigger,reaction in pairs(config.reactions) do
        if string.match(msg.text_lower, config.cmd_pat..trigger) then
            utilities.send_message(self, msg.chat.id, reaction, true, nil, 'html')
            return
        end
    end
end

return reactions
