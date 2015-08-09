local PLUGIN = {}

PLUGIN.doc = [[
	/calc <expression>
	This command solves math expressions and does conversion between common units. See mathjs.org/docs/expressions/syntax for a list of accepted syntax.
]]

PLUGIN.triggers = {
	'^/calc'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://api.mathjs.org/v1/?expr=' .. URL.escape(input)
	local message, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, config.locale.errors.syntax)
	end

	send_msg(msg, message)
end

return PLUGIN

