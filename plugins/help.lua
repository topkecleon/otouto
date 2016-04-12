 -- This plugin should go at the end of your plugin list in
 -- config.lua, but not after greetings.lua.

local help = {}

local bindings = require('bindings')
local utilities = require('utilities')

local help_text = '*Available commands:*'

function help:init()
	for _,plugin in ipairs(self.plugins) do
		if plugin.command then
			help_text = help_text .. '\n• /' .. plugin.command:gsub('%[', '\\[')
		end
	end

	help.triggers = utilities.triggers(self.info.username):t('help', true):t('h', true).table
end

help_text = help_text .. [[

• /help <command>
Arguments: <required> \[optional]
]]

function help:action(msg)

	local input = utilities.input(msg.text_lower)

	-- Attempts to send the help message via PM.
	-- If msg is from a group, it tells the group whether the PM was successful.
	if not input then
		local res = bindings.sendMessage(self, msg.from.id, help_text, true, nil, true)
		if not res then
			bindings.sendReply(self, msg, 'Please message me privately for a list of commands.')
		elseif msg.chat.type ~= 'private' then
			bindings.sendReply(self, msg, 'I have sent you the requested information in a private message.')
		end
		return
	end

	for _,plugin in ipairs(self.plugins) do
		if plugin.command and utilities.get_word(plugin.command, 1) == input and plugin.doc then
			local output = '*Help for* _' .. utilities.get_word(plugin.command, 1) .. '_ *:*\n' .. plugin.doc
			bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			return
		end
	end

	bindings.sendReply(self, msg, 'Sorry, there is no help for that command.')

end

return help
