 -- Thanks to @TiagoDanin for writing the original plugin.

local doc = [[
	/youtube <query>
	Returns the top result from YouTube.
]]

local triggers = {
	'^/y[ou]*t[ube]*[@'..bot.username..']*'
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

	local url = 'https://www.googleapis.com/youtube/v3/search?key=AIzaSyAfe7SI8kwQqaoouvAmevBfKumaLf-3HzI&type=video&part=snippet&maxResults=1&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	local message = 'https://www.youtube.com/watch?v=' .. jdat.items[1].id.videoId

	sendMessage(msg.chat.id, message, false, msg.message_id)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
