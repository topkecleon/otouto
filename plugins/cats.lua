if not config.thecatapi_key then
	print('Missing config value: thecatapi_key.')
	print('cats.lua will be enabled, but there are more features with a key.')
end

local doc = [[
	/cat
	Returns a cat!
]]

local triggers = {
	'^/cat[@'..bot.username..']*$'
}

local action = function(msg)

	local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg'
	if config.thecatapi_key then
		url = url .. '&api_key=' .. config.thecatapi_key
	end

	local str, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	str = str:match('<img src="(.*)">')

	sendMessage(msg.chat.id, str)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
