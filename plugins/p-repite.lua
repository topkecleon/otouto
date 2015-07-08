local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[di <texto>
	Repite una frase.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'di',
	'^di ',
	'^repite '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end
	
	input = input:gsub("%a", string.upper, 1)
	send_msg(msg, latcyr(input))

end

return PLUGIN
