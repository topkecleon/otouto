local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[images <query>
	This command performs a Google Images search for the given query. One random top result is returned. Safe search is enabled by default; use '!insfw' to get potentially NSFW results.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'images?',
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
		send_msg(msg, 'Connection error.')
		return
	end

	local jdat = JSON.decode(jstr)

	if #jdat.responseData.results < 1 then
		send_msg(msg, 'No results found.')
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
