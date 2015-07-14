local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.hex.command .. '\n' .. locale.hex.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.hex.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	if string.sub(input, 1, 2) == '0x' then
		send_msg(msg, tonumber(input))

	elseif tonumber(input) then
		send_msg(msg, string.format('%x', input))

	else
		send_msg(msg, locale.inv_arg)

	end

end

return PLUGIN
