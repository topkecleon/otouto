local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[imdb <movie | TV series>
	This function retrieves the IMDb info for a given film or television series, including the year, genre, imdb rating, runtime, and a summation of the plot.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'imdb'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://www.imdbapi.com/?t=' .. URL.escape(input)
	local jstr, res = HTTP.request(url)
	local jdat = JSON.decode(jstr)

	if res ~= 200 then
		return send_msg(msg, 'Error connecting to server.')
	end

	if jdat.Response ~= 'True' then
		return send_msg(msg, jdat.Error)
	end

	local message = jdat.Title ..' ('.. jdat.Year ..')\n'
	message = message .. jdat.imdbRating ..' | '.. jdat.Runtime ..' | '.. jdat.Genre ..'\n'
	message = message .. jdat.Plot .. '\n'
	message = message .. 'http://imdb.com/title/' .. jdat.imdbID

	send_msg(msg, message)

end

return PLUGIN
