local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[bible <verse>
	Returns a verse from the bible, King James Version. Use a standard or abbreviated reference (John 3:16, Jn3:16).
	http://biblia.com
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'bible',
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
		message = 'Connection error.'
	end

	send_msg(msg, message)

end

return PLUGIN
