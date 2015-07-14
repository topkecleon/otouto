local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.about.command .. '\n' .. locale.about.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.about.command,
	'^' .. config.COMMAND_START ..'info'
}

function PLUGIN.action(msg)
	local description = locale.about.description
	description = description:gsub('#BOTNAME', bot.first_name)
	description = description:gsub('#C_START', config.COMMAND_START)
	description = description:gsub('#COMMAND', locale.about.command)
	local version = locale.about.version
	version = version:gsub('#VERSION', VERSION)

	local message = description .. '\n\n' .. version

	send_msg(msg, message)

end

return PLUGIN
