local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('urbandictionary.COMMAND') .. ' <' .. I18N('ARG_TERM') .. '>\n' .. I18N('urbandictionary.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'ud',
	'^' .. config.COMMAND_START .. I18N('urbandictionary.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://api.urbandictionary.com/v0/define?term=' .. URL.escape(input)
	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, I18N('CONNECTION_ERROR'))
	end

	local jdat = JSON.decode(jstr)

	if jdat.result_type == "no_results" then
		return send_msg(msg, I18N('NO_RESULTS_FOUND'))
	end

	message = '"' .. jdat.list[1].word .. '"\n' .. trim_string(jdat.list[1].definition)
	if string.len(jdat.list[1].example) > 0 then
		message = message .. '\n\n' .. I18N('urbandictionary.EXAMPLE') .. '\n' .. trim_string(jdat.list[1].example)
	end

	send_msg(msg, message)

end

return PLUGIN
