local doc = [[
	/reddit [r/subreddit | query]
	Returns the four (if group) or eight (if private message) top posts for the given subreddit or query, or from the frontpage.
]]

local triggers = {
	'^/r[eddit]*[@'..bot.username..']*$',
	'^/r[eddit]*[@'..bot.username..']* ',
	'^/r/'
}

local action = function(msg)

	msg.text_lower = msg.text_lower:gsub('/r/', '/r r/')
	local input = msg.text_lower:input()
	local url

	local limit = 4
	if msg.chat.id == msg.from.id then
		limit = 8
	end

	if input then
		if input:match('^r/') then
			url = 'http://www.reddit.com/' .. input .. '/.json?limit=' .. limit
		else
			url = 'http://www.reddit.com/search.json?q=' .. input .. '&limit=' .. limit
		end
	else
		url = 'http://www.reddit.com/.json?limit=' .. limit
	end

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if #jdat.data.children == 0 then
		sendReply(msg, config.errors.results)
		return
	end

  	local i = 0 + 1
	local message = ''
	for i,v in ipairs(jdat.data.children) do
		if v.data.over_18 then
			message = message .. '[NSFW] '
		end
		local long_url = '\n'
		if not v.data.is_self then
			long_url = '\n' .. v.data.url .. '\n'
		end
		local short_url = '(redd.it/' .. v.data.id .. ') '
		message = message .. i ..  ' - [' .. v.data.title .. ']' .. short_url .. long_url
	end
  	
  	sendMessage(msg.chat.id, message, true, msg.message_id, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
