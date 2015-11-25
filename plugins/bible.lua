if not config.biblia_api_key then
	print('Missing config value: biblia_api_key.')
	print('bible.lua will not be enabled.')
	return
end

local doc = [[
	/bible <reference>
	Returns a verse from the American Standard Version of the Bible, or an apocryphal verse from the King James Version. Results from biblia.com.
]]

local triggers = {
	'^/b[ible]*[@'..bot.username..']*$',
	'^/b[ible]*[@'..bot.username..']* '
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		sendReply(msg, doc)
		return
	end

	local url = 'http://api.biblia.com/v1/bible/content/ASV.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)

	local message, res = HTTP.request(url)

	if message:len() == 0 then
		url = 'http://api.biblia.com/v1/bible/content/KJVAPOC.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)
		message, res = HTTP.request(url)
	end

	if res ~= 200 then
		message = config.errors.results
	end

	if message:len() > 4000 then
		message = 'The text is too long to post here. Try being more specific.'
	end

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
