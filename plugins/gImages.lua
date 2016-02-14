 -- You need a Google API key and a Google Custom Search Engine set up to use this, in config.google_api_key and config.google_cse_key, respectively.
 -- You must also sign up for the CSE in the Google Developer Concsole, and enable image results.

if not config.google_api_key then
	print('Missing config value: google_api_key.')
	print('gImages.lua will not be enabled.')
	return
elseif not config.google_cse_key then
	print('Missing config value: google_cse_key.')
	print('gImages.lua will not be enabled.')
	return
end

local command = 'image <query>'
local doc = [[```
/image <query>
Returns a randomized top result from Google Images. Safe search is enabled by default; use "/insfw" to disable it. NSFW results will not display an image preview.
Alias: /i
```]]

local triggers = {
	'^/image[@'..bot.username..']*',
	'^/i[@'..bot.username..']* ',
	'^/i[@'..bot.username..']*$',
	'^/insfw[@'..bot.username..']*'
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

	local url = 'https://www.googleapis.com/customsearch/v1?&searchType=image&imgSize=xlarge&alt=json&num=8&start=1&key=' .. config.google_api_key .. '&cx=' .. config.google_cse_key

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
	local output = '[​]('..result..')'


	if string.match(msg.text, '^/i[mage]*nsfw') then
		sendReply(msg, result)
	else
		sendMessage(msg.chat.id, output, false, nil, true)
	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
