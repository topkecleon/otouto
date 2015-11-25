local doc = [[
	/image <query>
	Returns a randomized top result from Google Images. Safe search is enabled by default; use "/insfw" to disable it. NSFW results will not display an image preview.
]]

local triggers = {
	'^/i[mage]*[nsfw]*[@'..bot.username..']*$',
	'^/i[mage]*[nsfw]*[@'..bot.username..']* '
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

	local url = 'https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8'

	if not string.match(msg.text, '^/i[mage]*nsfw') then
		url = url .. '&safe=active'
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if #jdat.responseData.results < 1 then
		sendReply(msg, config.errors.results)
		return
	end

	local i = math.random(#jdat.responseData.results)
	local result = jdat.responseData.results[i].url

	if string.match(msg.text, '^/i[mage]*nsfw') then
		sendReply(msg, result)
	else
		sendMessage(msg.chat.id, result, false, msg.message_id)
	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
