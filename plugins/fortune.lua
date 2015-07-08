local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[fortune
	Get a random fortune from the UNIX fortune program.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'fortune',
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
