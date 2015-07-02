local PLUGIN = {}

PLUGIN.doc = [[
	!example
	Info about the command.
]]

PLUGIN.triggers = {
	'^!example',
	'^!e$'
}

function PLUGIN.action(msg)

	local message = 'Example output.'
	send_msg(msg, message)

end

return PLUGIN
