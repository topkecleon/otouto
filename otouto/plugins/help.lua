local utilities = require('otouto.utilities')

local help = {}

function help:init(config)
    help.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('help', true):t('h', true).table
    help.command = 'help [command]'
    help.doc = config.cmd_pat .. 'help [command] \nReturns usage information for a given command.'
end

function help:action(msg, config)
    local input = utilities.input(msg.text_lower)
    if input then
        if not help.help_word then
            for _, plugin in ipairs(self.plugins) do
                if plugin.command and plugin.doc and not plugin.help_word then
                    plugin.help_word = utilities.get_word(plugin.command, 1)
                end
            end
        end
        for _,plugin in ipairs(self.plugins) do
            if plugin.help_word == input:gsub('^/', '') then
                local output = '*Help for* _' .. plugin.help_word .. '_*:*\n' .. plugin.doc
                utilities.send_message(self, msg.chat.id, output, true, nil, true)
                return
            end
        end
        utilities.send_reply(self, msg, 'Sorry, there is no help for that command.')
    else
        -- Generate the help message on first run.
        if not help.text then
            local commandlist = {}
            for _, plugin in ipairs(self.plugins) do
                if plugin.command then
                    table.insert(commandlist, plugin.command)
                end
            end
            table.sort(commandlist)
            help.text = '*Available commands:*\n• ' .. config.cmd_pat .. table.concat(commandlist, '\n• '..config.cmd_pat) .. '\nArguments: <required> [optional]'
            help.text = help.text:gsub('%[', '\\[')
        end
        -- Attempt to send the help message via PM.
        -- If msg is from a group, tell the group whether the PM was successful.
        local res = utilities.send_message(self, msg.from.id, help.text, true, nil, true)
        if not res then
            utilities.send_reply(self, msg, 'Please [message me privately](http://telegram.me/' .. self.info.username .. '?start=help) for a list of commands.', true)
        elseif msg.chat.type ~= 'private' then
            utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
        end
    end
end

return help
