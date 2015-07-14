local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.bible.command .. '\n' .. locale.bible.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.bible.command,
	'^' .. config.COMMAND_START .. 'b '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://api.biblia.com/v1/bible/content/KJV.txt?key=' .. config.BIBLIA_API_KEY .. '&passage=' .. URL.escape(input)
	local message, res = HTTP.request(url)

	if res ~= 200 then
		message = locale.conn_err
	end

	send_msg(msg, message)

end

return PLUGIN
