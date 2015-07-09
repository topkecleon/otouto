local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('echo.COMMAND') .. ' <' .. I18N('ARG_TEXT') .. '>\n' .. I18N('echo.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('echo.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	send_msg(msg, latcyr(input))

end

return PLUGIN
