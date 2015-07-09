local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('hex.COMMAND') .. ' <' .. I18N('ARG_NUMBER') .. '>\n' .. I18N('hex.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('hex.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	if string.sub(input, 1, 2) == '0x' then
		send_msg(msg, tonumber(input))

	elseif tonumber(input) then
		send_msg(msg, string.format('%x', input))

	else
		send_msg(msg, I18N('hex.INVALID_NUMBER'))

	end

end

return PLUGIN
