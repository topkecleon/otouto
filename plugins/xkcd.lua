local command = 'xkcd [query]'
local doc = [[```
/xkcd [query]
Returns an xkcd strip and its alt text. If there is no query, it will be randomized.
```]]

local triggers = {
	'^/xkcd[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()

	local jstr, res = HTTP.request('http://xkcd.com/info.0.json')
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local latest = JSON.decode(jstr).num
	local res_url

	if input then
		local url = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=active&q=site%3axkcd%2ecom%20' .. URL.escape(input)
		local jstr, res = HTTPS.request(url)
		if res ~= 200 then
			sendReply(msg, config.errors.connection)
			return
		end
		local jdat = JSON.decode(jstr)
		if #jdat.responseData.results == 0 then
			sendReply(msg, config.errors.results)
			return
		end
		res_url = jdat.responseData.results[1].url .. 'info.0.json'
	else
		res_url = 'http://xkcd.com/' .. math.random(latest) .. '/info.0.json'
	end

	local jstr, res = HTTP.request(res_url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end
	local jdat = JSON.decode(jstr)

	local output = '[' .. jdat.num .. '](' .. jdat.img .. ')\n' .. jdat.alt

	sendMessage(msg.chat.id, output, false, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
