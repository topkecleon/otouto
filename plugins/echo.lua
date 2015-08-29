local PLUGIN = {}

PLUGIN.doc = [[
	/echo <text>
	Repeat a string.
]]

PLUGIN.triggers = {
	'^/echo'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	send_message(msg.chat.id, latcyr(input))

end

return PLUGIN
