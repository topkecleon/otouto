local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[hex <number>
	This function converts a number to or from hexadecimal.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'hex '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	if string.sub(input, 1, 2) == '0x' then
		send_msg(msg, tonumber(input))

	elseif tonumber(input) then
		send_msg(msg, string.format('%x', input))

	else
		send_msg(msg, 'Invalid number.')

	end

end

return PLUGIN
