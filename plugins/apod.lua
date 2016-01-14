-- TODO:
-- 	inline bot stuff

if not config.nasaapi_key then
	print('Missing config value: nasaapi_key.')
	print('You can use the simple key DEMO_KEY, but it is very limited.')
	print('apod.lua will not be enabled.')
	return
end

local command = 'apod [query]'
local doc = [[```
/apod [query]
Returns the Astronomy Picture of the Day.

If the query is a date, in the format YYYY-MM-DD,
the APOD of that day is returned.
```]]

local triggers = {
	'^/apod[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	local caption = '' 
	local date = '*'
	--local date_url = ''

	local url = 'https://api.nasa.gov/planetary/apod?api_key=' .. config.nasaapi_key

	if input then
		url = url .. '&date=' .. URL.escape(input)
	--	date_url = string.sub(date,3,4) .. string.sub(date,6,7) .. string.sub(date,9,10)
		date = date .. input
	else
	--	date_url = os.date("%y%m%d")
		date = date .. os.date("%Y-%m-%d")
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

	--local weburl = 'http://apod.nasa.gov/apod/ap' .. date_url .. '.html'
	--caption = date .. '[' .. jdat.title  .. '](' .. weburl .. ')\n'
	caption = date .. '[' .. jdat.title  .. '](' .. jdat.url .. ')\n'

	if jdat.copyright then
		caption = caption .. 'Copyright: ' .. jdat.copyright
	end

	sendMessage(msg.chat.id, caption, false, nil, true)
end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
