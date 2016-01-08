local command = 'translate [text]'
local doc = [[```
/translate [text]
Translates input or the replied-to message into the bot's language.
```]]

local triggers = {
	'^/translate[@'..bot.username..']*'
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

	local url = 'https://translate.google.com/translate_a/single?client=t&ie=UTF-8&oe=UTF-8&hl=en&dt=t&sl=auto&tl=' .. config.lang .. '&text=' .. URL.escape(input)

	local str, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local output = latcyr(str:gmatch("%[%[%[\"(.*)\"")():gsub("\"(.*)", ""))

	sendReply(msg.reply_to_message or msg, output)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
