local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.echo.command .. '\n' .. locale.echo.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.echo.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	send_msg(msg, latcyr(input))

end

return PLUGIN
