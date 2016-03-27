local command = 'whoami'
local doc = [[```
Returns user and chat info for you or the replied-to message.
Alias: /who
```]]

local triggers = {
	'^/who[ami]*[@'..bot.username..']*$'
}

local action = function(msg)

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	local from_name = msg.from.first_name
	if msg.from.last_name then
		from_name = from_name .. ' ' .. msg.from.last_name
	end
	if msg.from.username then
		from_name = '@' .. msg.from.username .. ', AKA ' .. from_name
	end
	from_name = from_name .. ' (' .. msg.from.id .. ')'

	local chat_id = math.abs(msg.chat.id)
	if chat_id > 1000000000000 then
		chat_id = chat_id - 1000000000000
	end

	local to_name
	if msg.chat.title then
		to_name = msg.chat.title .. ' (' .. chat_id .. ').'
	else
		to_name = '@' .. bot.username .. ', AKA ' .. bot.first_name .. ' (' .. bot.id .. ').'
	end

	local message = 'You are ' .. from_name .. ' and you are messaging ' .. to_name

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
