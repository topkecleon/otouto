 -- This plugin should go at the end of your plugin list in
 -- config.lua, but not after greetings.lua.

local help = {}

local utilities = require('utilities')

local help_text

function help:init()

	local commandlist = {}
	help_text = '*Available commands:*\n• /'

	for _,plugin in ipairs(self.plugins) do
		if plugin.command then
			table.insert(commandlist, plugin.command)
			--help_text = help_text .. '\n• /' .. plugin.command:gsub('%[', '\\[')
		end
	end

	table.insert(commandlist, 'help [command]')
	table.sort(commandlist)

	help_text = help_text .. table.concat(commandlist, '\n• /') .. '\nArguments: <required> [optional]'

	help_text = help_text:gsub('%[', '\\[')

	help.triggers = utilities.triggers(self.info.username):t('help', true):t('h', true).table

end

function help:action(msg)

	local input = utilities.input(msg.text_lower)

	-- Attempts to send the help message via PM.
	-- If msg is from a group, it tells the group whether the PM was successful.
	if not input then
		local res = utilities.send_message(self, msg.from.id, help_text, true, nil, true)
		if not res then
			utilities.send_reply(self, msg, 'Please message me privately for a list of commands.')
		elseif msg.chat.type ~= 'private' then
			utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
		end
		return
	end

	for _,plugin in ipairs(self.plugins) do
		if plugin.command and utilities.get_word(plugin.command, 1) == input and plugin.doc then
			local output = '*Help for* _' .. utilities.get_word(plugin.command, 1) .. '_ *:*\n' .. plugin.doc
			utilities.send_message(self, msg.chat.id, output, true, nil, true)
			return
		end
	end

	utilities.send_reply(self, msg, 'Sorry, there is no help for that command.')

end

return help
