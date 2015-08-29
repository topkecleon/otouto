local doc = [[
	/cat
	Get a cat pic!
]]

local triggers = {
	'^/cats?'
}

local action = function(msg)

	local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg'
	if config.thecatapi_key then
		url = url .. '&api_key=' .. config.thecatapi_key
	end

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	jstr = jstr:match('<img src="(.*)">')

	send_message(msg.chat.id, jstr, false, msg.message_id)

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	typing = true
}
