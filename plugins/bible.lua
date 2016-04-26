if not config.biblia_api_key then
	print('Missing config value: biblia_api_key.')
	print('bible.lua will not be enabled.')
	return
end

local command = 'bible <reference>'
local doc = [[```
/bible <reference>
Returns a verse from the American Standard Version of the Bible, or an apocryphal verse from the King James Version. Results from biblia.com.
Alias: /b
```]]

local triggers = {
	'^/bible*[@'..bot.username..']*',
	'^/b[@'..bot.username..']* ',
	'^/b[@'..bot.username..']*$'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end

	local url = 'http://api.biblia.com/v1/bible/content/ASV.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)

	local output, res = HTTP.request(url)

	if not output or res ~= 200 or output:len() == 0 then
		url = 'http://api.biblia.com/v1/bible/content/KJVAPOC.txt?key=' .. config.biblia_api_key .. '&passage=' .. URL.escape(input)
		output, res = HTTP.request(url)
	end

	if not output or res ~= 200  or output:len() == 0 then
		output = config.errors.results
	end

	if output:len() > 4000 then
		output = 'The text is too long to post here. Try being more specific.'
	end

	sendMessage(msg.chat.id, output, true, msg.message_id, true)

end

return {
	action = action,
	triggers = triggers,
	command = command,
	doc = doc
}
