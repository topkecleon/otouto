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

	local url = 'https://www.googleapis.com/customsearch/v1?&searchType=image&imgSize=xlarge&alt=json&num=8&start=1'
        url = url .. '&key=0000000' -- KEY Get https://console.developers.google.com/apis/credentials
        url = url .. '&cx=ABCD:000' -- CX Get https://cse.google.com/cse

	if not string.match(msg.text, '^/i[mage]*nsfw') then
		url = url .. '&safe=high'
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.searchInformation.totalResults == '0' then
		sendReply(msg, config.errors.results)
		return
	end

	local i = math.random(jdat.queries.request[1].count)
	local result = jdat.items[i].link

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
