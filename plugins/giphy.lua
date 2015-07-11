local PLUGIN = {}

PLUGIN.doc = [[
	/giphy [query]
	Returns a random or search-resulted GIF from giphy.com. Results are limited to PG-13 by default; use '/gifnsfw' to get potentially NSFW results.
]]

PLUGIN.triggers = {
	'^/giphy',
	'^/gifnsfw'
}

function PLUGIN.action(msg)

	local search_url = 'http://api.giphy.com/v1/gifs/search?limit=10&api_key=' .. config.GIPHY_API_KEY
	local random_url = 'http://tv.giphy.com/v1/gifs/random?api_key=' .. config.GIPHY_API_KEY
	local result_url = ''

	if string.match(msg.text, '^/giphynsfw') then
		search_url = search_url .. '&rating=r&q='
		random_url = random_url .. '&rating=r'
	else
		search_url = search_url .. '&rating=pg-13&q='
		random_url = random_url .. '&rating=pg-13'
	end

	local input = get_input(msg.text)

	if not input then

		local jstr, res = HTTP.request(random_url)
		if res ~= 200 then
			return send_msg(msg, locale.conn_err)
		end
		local jdat = JSON.decode(jstr)
		result_url = jdat.data.image_url

	else

		local jstr, res = HTTP.request(search_url .. input)
		if res ~= 200 then
			return send_msg(msg, locale.conn_err)
		end
		local jdat = JSON.decode(jstr)
		result_url = jdat.data[math.random(#jdat.data)].images.original.url

	end

	send_message(msg.chat.id, result_url, false, msg.message_id)

end

return PLUGIN
