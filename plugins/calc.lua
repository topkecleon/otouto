local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.calc.command .. '\n' .. locale.calc.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.calc.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://api.mathjs.org/v1/?expr=' .. URL.escape(input)
	local message, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, locale.conn_err)
	end

	send_msg(msg, message)
end

return PLUGIN

