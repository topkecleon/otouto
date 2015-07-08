local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[gif [consulta]
	Devuelve un gif de Giphy.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'gif',
	'^' .. config.COMMAND_START .. 'gifnsfw'
}

function PLUGIN.action(msg)

	local search_url = 'http://api.giphy.com/v1/gifs/search?limit=10&api_key=' .. config.GIPHY_API_KEY
	local random_url = 'http://tv.giphy.com/v1/gifs/random?api_key=' .. config.GIPHY_API_KEY
	local result_url = ''

	if string.match(msg.text, '^' .. config.COMMAND_START .. 'giphynsfw') then
		search_url = search_url .. '&rating=r&q='
		random_url = random_url .. '&rating=r'
	else
		search_url = search_url .. '&rating=pg-13&q='
		random_url = random_url .. '&rating=pg-13'
	end

	local input = get_input(msg.text)

	if not input then

		return send_msg(msg, PLUGIN.doc)

	else

		local jstr, res = HTTP.request(search_url .. input)
		if res ~= 200 then
			return send_msg(msg, 'No pude conectarme, ' .. msg.from.first_name .. '...  ')
		end
		local jdat = JSON.decode(jstr)
		result_url = jdat.data[math.random(#jdat.data)].images.original.url

	end

	send_msg(msg, result_url)

end

return PLUGIN
