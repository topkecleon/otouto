local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.imdb.command .. '\n' .. locale.imdb.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.imdb.command
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
		return send_msg(msg, locale.conn_err)
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
