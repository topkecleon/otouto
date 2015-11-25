local doc = [[
	/google <query>
	Returns four (if group) or eight (if private message) results from Google. Safe search is enabled by default, use "/gnsfw" to disable it.
]]

local triggers = {
	'^/g[oogle]*[nsfw]*[@'..bot.username..']*$',
	'^/g[oogle]*[nsfw]*[@'..bot.username..']* '
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

	local url = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0'

	if msg.from.id == msg.chat.id then
		url = url .. '&rsz=8'
	else
		url = url .. '&rsz=4'
	end

	if not string.match(msg.text, '^/g[oogle]*nsfw') then
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

	local message = ''
	for i,v in ipairs(jdat.responseData.results) do
		message = message .. jdat.responseData.results[i].titleNoFormatting .. '\n ' .. jdat.responseData.results[i].unescapedUrl .. '\n'
	end

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
