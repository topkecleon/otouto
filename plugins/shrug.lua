local PLUGIN = {}

PLUGIN.triggers = {
	config.COMMAND_START .. I18N('shrug.COMMAND')
}

function PLUGIN.action(msg)
	send_msg(msg, '¯\\_(ツ)_/¯')
end

return PLUGIN
