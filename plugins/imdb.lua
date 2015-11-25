local doc = [[
	/imdb <query>
	Returns an IMDb entry.
]]

local triggers = {
	'^/imdb[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendReply(msg, doc)
			return
		end
	end

	local url = 'http://www.omdbapi.com/?t=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	if jdat.Response ~= 'True' then
		sendReply(msg, config.errors.results)
		return
	end

	local message = jdat.Title ..' ('.. jdat.Year ..')\n'
	message = message .. jdat.imdbRating ..' | '.. jdat.Runtime ..' | '.. jdat.Genre ..'\n'
	message = message .. jdat.Plot .. '\n'
	message = message .. 'http://imdb.com/title/' .. jdat.imdbID

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
