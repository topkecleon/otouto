local command = 'translate [text]'
local doc = [[```
/translate [text]
Translates input or the replied-to message into the bot's language.
```]]

local triggers = {
	'^/translate[@'..bot.username..']*',
	'^/tl[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key=' .. config.yandex_key .. '&lang=' .. config.lang .. '&text=' .. URL.escape(input)

	local str, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(str)
	if jdat.code ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local output = jdat.text[1]
	output = latcyr(output)

	sendReply(msg.reply_to_message or msg, output)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
