 -- This plugin should go at the end of your plugin list in
 -- config.lua, but not after greetings.lua.

local help = {}

local utilities = require('otouto.utilities')

local help_text

function help:init(config)
	local commandlist = {}
	help_text = '*Available commands:*\n• '..config.cmd_pat
	for _,plugin in ipairs(self.plugins) do
		if plugin.command then
			table.insert(commandlist, plugin.command)
			if plugin.doc then
				plugin.help_word = utilities.get_word(plugin.command, 1)
			end
		end
	end
	table.insert(commandlist, 'help [command]')
	table.sort(commandlist)
	help_text = help_text .. table.concat(commandlist, '\n• '..config.cmd_pat) .. '\nArguments: <required> [optional]'
	help_text = help_text:gsub('%[', '\\[')
	help.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('help', true):t('h', true).table
	help.doc = config.cmd_pat .. 'help [command] \nReturns usage information for a given command.'
end

function help:action(msg)
	local input = utilities.input(msg.text_lower)
	if input then
		for _,plugin in ipairs(self.plugins) do
			if plugin.help_word == input:gsub('^/', '') then
				local output = '*Help for* _' .. plugin.help_word .. '_ *:*\n' .. plugin.doc
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
				return
			end
		end
		utilities.send_reply(self, msg, 'Sorry, there is no help for that command.')
	else
		-- Attempt to send the help message via PM.
		-- If msg is from a group, tell the group whether the PM was successful.
		local res = utilities.send_message(self, msg.from.id, help_text, true, nil, true)
		if not res then
			utilities.send_reply(self, msg, 'Please [message me privately](http://telegram.me/' .. self.info.username .. '?start=help) for a list of commands.', true)
		elseif msg.chat.type ~= 'private' then
			utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
		end
	end
end

return help
