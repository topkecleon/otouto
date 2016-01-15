local command = 'apod [query]'
local doc = [[```
/apod [query]
Returns the Astronomy Picture of the Day.
If the query is a date, in the format YYYY-MM-DD, the APOD of that day is returned.
Source: nasa.gov
```]]

local triggers = {
	'^/apod[@'..bot.username..']*'
}

local action = function(msg)

	if not config.nasa_api_key then
		config.nasa_api_key = 'DEMO_KEY'
	end

	local input = msg.text:input()
	local caption = ''
	local date = '*'

	local url = 'https://api.nasa.gov/planetary/apod?api_key=' .. config.nasa_api_key

	if input then
		url = url .. '&date=' .. URL.escape(input)
		date = date .. input
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

	local img_url = jdat.hdurl or jdat.url
	output = date .. '[' .. jdat.title  .. '](' .. img_url .. ')\n'

	if jdat.copyright then
		output = output .. 'Copyright: ' .. jdat.copyright
	end

	sendMessage(msg.chat.id, output, false, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
