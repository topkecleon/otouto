local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('gImages.COMMAND') .. ' <' .. I18N('ARG_QUERY') .. '>\n' .. I18N('gImages.HELP', {COMMAND_START = config.COMMAND_START})

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('gImages.COMMAND') .. '?',
	'^' .. config.COMMAND_START .. 'img',
	'^' .. config.COMMAND_START .. 'i ',
	'^' .. config.COMMAND_START .. 'insfw'
}

PLUGIN.exts = {
	'.png$',
	'.jpg$',
	'.jpeg$',
	'.jpe$',
	'.gif$'
}

function PLUGIN.action(msg)

	local url = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8'

	if not string.match(msg.text, '^' .. config.COMMAND_START .. 'insfw ') then
		url = url .. '&safe=active'
	end

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		send_msg(msg, I18N('CONNECTION_ERROR'))
		return
	end

	local jdat = JSON.decode(jstr)

	if #jdat.responseData.results < 1 then
		send_msg(msg, I18N('NO_RESULTS_FOUND'))
		return
	end

	is_real = false
	while is_real == false do
		local i = math.random(#jdat.responseData.results)
		result_url = jdat.responseData.results[i].url
		for i,v in pairs(PLUGIN.exts) do
			if string.match(string.lower(result_url), v) then
				is_real = true
			end
		end
	end

	send_message(msg.chat.id, result_url, false, msg.message_id)

end

return PLUGIN
