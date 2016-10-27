--[[
    reactions.lua
    Provides a list of callable emoticons for the poor souls who don't have a
    compose key.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local reactions = {}

function reactions:init()
    reactions.command = 'reactions'
    reactions.doc = 'Returns a list of "reaction" emoticon commands.'
    -- Generate a command list message triggered by "/reactions".
    reactions.help = 'Reactions:\n'
    reactions.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('reactions').table
    local username = self.info.username:lower()
    for trigger, reaction in pairs(self.config.reactions) do
        reactions.help = reactions.help .. '• ' .. self.config.cmd_pat .. trigger .. ': ' .. reaction .. '\n'
        table.insert(reactions.triggers, '^'..self.config.cmd_pat..trigger)
        table.insert(reactions.triggers, '^'..self.config.cmd_pat..trigger..'@'..username)
        table.insert(reactions.triggers, self.config.cmd_pat..trigger..'$')
        table.insert(reactions.triggers, self.config.cmd_pat..trigger..'@'..username..'$')
        table.insert(reactions.triggers, '\n'..self.config.cmd_pat..trigger)
        table.insert(reactions.triggers, '\n'..self.config.cmd_pat..trigger..'@'..username)
        table.insert(reactions.triggers, self.config.cmd_pat..trigger..'\n')
        table.insert(reactions.triggers, self.config.cmd_pat..trigger..'@'..username..'\n')
    end
end

function reactions:action(msg)
    if string.match(msg.text_lower, self.config.cmd_pat..'reactions') then
        utilities.send_message(msg.chat.id, reactions.help, true, nil, 'html')
        return
    end
    for trigger,reaction in pairs(self.config.reactions) do
        if string.match(msg.text_lower, self.config.cmd_pat..trigger) then
            utilities.send_message(msg.chat.id, reaction, true, nil, 'html')
            return
        end
    end
end

return reactions
