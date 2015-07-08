local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'shrug',
	config.COMMAND_START .. 'shrug'
}

function PLUGIN.action(msg)
	send_msg(msg, '¯\\_(ツ)_/¯')
end

return PLUGIN
