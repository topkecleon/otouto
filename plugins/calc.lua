local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('calc.COMMAND').. ' <' .. I18N('ARG_EXPRESSION') .. '>' .. '\n' .. I18N('calc.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('calc.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://api.mathjs.org/v1/?expr=' .. URL.escape(input)
	local message, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, I18N('CONNECTION_ERROR'))
	end

	send_msg(msg, message)
end

return PLUGIN

