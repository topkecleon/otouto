local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('fortune.COMMAND') .. '\n' .. I18N('fortune.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('fortune.COMMAND'),
	'^' .. config.COMMAND_START .. 'f$'
}

function PLUGIN.action(msg)
	local output = io.popen('fortune')
	message = ''
	for l in output:lines() do
		message = message .. l .. '\n'
	end
	send_msg(msg, message)
end

return PLUGIN
