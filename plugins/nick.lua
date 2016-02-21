if not database.nicknames then
	database.nicknames = {}
end

local command = 'nick <nickname>'
local doc = [[```
/nick <nickname>
Set your nickname. Use "/whoami" to check your nickname and "/nick -" to delete it.
```]]

local triggers = {
	'^/nick[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return true
	end

	if string.len(input) > 32 then
		sendReply(msg, 'The character limit for nicknames is 32.')
		return true
	end

	if input == '-' then
		database.nicknames[msg.from.id_str] = nil
		sendReply(msg, 'Your nickname has been deleted.')
	else
		database.nicknames[msg.from.id_str] = input
		sendReply(msg, 'Your nickname has been set to "' .. input .. '".')
	end

	return true

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
