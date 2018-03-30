--[[
    help.lua
    Returns a list of commands, or command-specific help.

    Load this after every plugin you want to appear in the command list.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local help = {}

function help:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat):t('help', true):t('h', true).table
    self.command = 'help [command]'
    self.doc = bot.config.cmd_pat .. 'help [command] \nReturns usage information for a given command.'

    self.glossaries = {}
    for name, glossary in pairs({
        autils = autils and autils.glossary,
    }) do
        if glossary then self.glossaries[name] = glossary end
    end

    self.commandlist = {}
    self:generate_text(bot.config.cmd_pat)
end

function help:action(bot, msg)
    local input = utilities.input(msg.text_lower)
    if input then
        input = input:lower():gsub('^' .. bot.config.cmd_pat, '')
        for _, plugin in ipairs(bot.plugins) do
            if plugin.help_word and input:match(plugin.help_word) then
                utilities.send_plugin_help(msg.chat.id, nil, bot.config.cmd_pat, plugin)
                return
            end
        end
        -- If there are no plugin matches, check the glossaries.
        for _glossary_name, glossary in pairs(self.glossaries) do
            for name, entry in pairs(glossary) do
                if input:match(name) then
                    utilities.send_help_for(msg.chat.id, nil, name, entry)
                    return
                end
            end
        end
        utilities.send_reply(msg, 'Sorry, there is no help for that command.')
    else
        -- Attempt to send the help message via PM.
        -- If msg is from a group, tell the group whether the PM was successful.
        local res = utilities.send_message(msg.from.id, self.text, true, nil, 'html')
        if not res then
            utilities.send_reply(
                msg,
                'Please <a href="http://t.me/' .. bot.info.username ..
                    '?start=help">message me privately</a> for a list of commands.',
                'html'
            )
        elseif msg.chat.type ~= 'private' then
            utilities.send_reply(msg, 'I have sent you the requested information in a private message.')
        end
    end
end

function help:on_plugins_load(bot, plugins)
    for _, plugin in pairs(plugins) do
        if plugin.command then
            local s = plugin.command
            if plugin.targeting then
                s = s .. '*'
                if plugin.duration then
                    s = s .. '†'
                end
            end
            table.insert(self.commandlist, {plugin.name, s})
            if plugin.doc and not plugin.help_word then
                plugin.help_word = utilities.get_word(plugin.command, 1)
            end
        end
    end
    table.sort(self.commandlist, function (a, b) return a[2] < b[2] end)
    self:generate_text(bot.config.cmd_pat)
end

function help:on_plugins_unload(bot, plugins)
    for _, plugin in pairs(plugins) do
        for i, pair in ipairs(self.commandlist) do
            if pair[1] == plugin.name then
                table.remove(self.commandlist, i)
                break
            end
        end
    end
    self:generate_text(bot.config.cmd_pat)
end

function help:generate_text(cmd_pat)
    local comlist = '\n'
    for _, pair in ipairs(self.commandlist) do
        comlist = comlist .. '• ' .. cmd_pat .. pair[2] .. '\n'
    end
    comlist = comlist ..
"Arguments: <required> [optional]\
* Targets may be specified via reply, username, mention, or ID. \z
  In a reply command, a reason can be given after the command. Otherwise, it must be on a new line.\
† A duration may be specified before the reason, in minutes or in the format 5d12h30m15s."
    self.text = '<b>Available commands:</b>' .. utilities.html_escape(comlist)
end

return help
