local command = 'imdb <query>'
local doc = [[```
/imdb <query>
Returns an IMDb entry.
```]]

local triggers = {
	'^/imdb[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
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

	local output = '[' .. jdat.Title .. '](http://imdb.com/title/'
	output = output .. jdat.imdbID .. ') ('.. jdat.Year ..')\n'
	output = output .. jdat.imdbRating ..'/10 | '.. jdat.Runtime ..' | '.. jdat.Genre ..'\n'
	output = output .. jdat.Plot

	sendMessage(msg.chat.id, output, true, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
