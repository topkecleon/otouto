local command = 'apod [date]'
local doc = [[```
/apod [query]
Returns the Astronomy Picture of the Day.
If the query is a date, in the format YYYY-MM-DD, the APOD of that day is returned.
/apodhd [query]
Returns the image in HD, if available.
/apodtext [query]
Returns the explanation of the APOD.
Source: nasa.gov
```]]

local triggers = {
	'^/apod[@'..bot.username..']*',
	'^/apodhd[@'..bot.username..']*',
	'^/apodtext[@'..bot.username..']*'
}

local action = function(msg)

	if not config.nasa_api_key then
		config.nasa_api_key = 'DEMO_KEY'
	end

	local input = msg.text:input()
	local caption = ''
	local date = '*'
	local disable_page_preview = false

	local url = 'https://api.nasa.gov/planetary/apod?api_key=' .. config.nasa_api_key

	if input then
		if input:match('(%d+)%-(%d+)%-(%d+)$') then
			url = url .. '&date=' .. URL.escape(input)
			date = date .. input
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
			return
		end
	else
		date = date .. os.date("%F")
	end

	date = date .. '*\n'

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	if jdat.error then
		sendReply(msg, config.errors.results)
		return
	end

	local img_url = jdat.url

	if string.match(msg.text, '^/apodhd*') then
		img_url = jdat.hdurl or jdat.url
	end

	output = date .. '[' .. jdat.title  .. '](' .. img_url .. ')'

	if string.match(msg.text, '^/apodtext*') then
		output = output .. '\n' .. jdat.explanation
		disable_page_preview = true
	end

	if jdat.copyright then
		output = output .. '\nCopyright: ' .. jdat.copyright
	end

	sendMessage(msg.chat.id, output, disable_page_preview, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
