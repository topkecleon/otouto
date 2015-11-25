local doc = [[
	/hackernews
	Returns four (if group) or eight (if private message) top stories from Hacker News.
]]

local triggers = {
	'^/hackernews[@'..bot.username..']*',
	'^/hn[@'..bot.username..']*'
}

local action = function(msg)

	local jstr, res = HTTPS.request('https://hacker-news.firebaseio.com/v0/topstories.json')
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	local res_count = 4
	if msg.chat.id == msg.from.id then
		res_count = 8
	end

	local message = ''
	for i = 1, res_count do
		local res_url = 'https://hacker-news.firebaseio.com/v0/item/' .. jdat[i] .. '.json'
		jstr, res = HTTPS.request(res_url)
		if res ~= 200 then
			sendReply(msg, config.errors.connection)
			return
		end
		local res_jdat = JSON.decode(jstr)
		message = message .. res_jdat.title .. '\n ' .. res_jdat.url .. '\n'
	end

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
