--[[
    help.lua
    Returns a list of commands, or command-specific help.

    Load this after every plugin you want to appear in the command list.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local help = {}

function help:init()
    help.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('help', true):t('h', true).table
    help.command = 'help [command]'
    help.doc = self.config.cmd_pat .. 'help [command] \nReturns usage information for a given command.'
    local commandlist = {}
    for _, plugin in pairs(self.plugins) do
        if plugin.command then
            table.insert(commandlist, plugin.command)
            if plugin.doc and not plugin.help_word then
                plugin.help_word = utilities.get_word(plugin.command, 1)
            end
        end
    end
    table.sort(commandlist)
    local comlist = '\n• ' .. self.config.cmd_pat
        .. table.concat(commandlist, '\n• ' .. self.config.cmd_pat) .. '\nArguments: <required> [optional]'
    help.text = '<b>Available commands:</b>' .. utilities.html_escape(comlist)
end

function help:action(msg)
    local input = utilities.input(msg.text_lower)
    if input then
        for _,plugin in ipairs(self.plugins) do
            if plugin.help_word == input:gsub('^'..self.config.cmd_pat, '') then
                local output = '<b>Help for</b> <i>' .. plugin.help_word .. '</i><b>:</b>\n' .. plugin.doc
                utilities.send_message(msg.chat.id, output, true, nil, 'html')
                return
            end
        end
        utilities.send_reply(msg, 'Sorry, there is no help for that command.')
    else
        -- Attempt to send the help message via PM.
        -- If msg is from a group, tell the group whether the PM was successful.
        local res = utilities.send_message(msg.from.id, help.text, true, nil, 'html')
        if not res then
            utilities.send_reply(msg,
                'Please <a href="http://t.me/' .. self.info.username
                .. '?start=help">message me privately</a> for a list of commands.',
                'html')
        elseif msg.chat.type ~= 'private' then
            utilities.send_reply(msg, 'I have sent you the requested information in a private message.')
        end
    end
end

return help
