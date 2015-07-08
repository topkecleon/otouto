local PLUGIN = {}

PLUGIN.doc = [[
	/google <query>
	This command performs a Google search for the given query. Four results are returned. Safe search is enabled by default; use '!gnsfw' to get potentially NSFW results. Four results are returned for a group chat, or eight in a private message.
]]

PLUGIN.triggers = {
	'^/g ',
	'^/google',
	'^/gnsfw'
}

function PLUGIN.action(msg)

	local url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0'

	if not string.match(msg.text, '^/gnsfw ') then
		url = url .. '&safe=active'
	end

	if not msg.chat.title then
		url = url .. '&rsz=8'
	end

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, 'Connection error.')
	end

	local jdat = JSON.decode(jstr)

	if #jdat.responseData.results < 1 then
		return send_msg(msg, 'No results found.')
	end

	message = ''

	for i = 1, #jdat.responseData.results do
		local result_url = jdat.responseData.results[i].unescapedUrl
		local result_title = jdat.responseData.results[i].titleNoFormatting
		message = message  .. ' - ' .. result_title ..'\n'.. result_url .. '\n'
	end

	send_msg(msg, message)

end

return PLUGIN
