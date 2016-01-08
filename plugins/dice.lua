local command = 'roll <nDr>'
local doc = [[```
/roll <nDr>
Returns a set of dice rolls, where n is the number of rolls and r is the range. If only a range is given, returns only one roll.
```]]

local triggers = {
	'^/roll[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text_lower:input()
	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end

	local count, range
	if input:match('^[%d]+d[%d]+$') then
		count, range = input:match('([%d]+)d([%d]+)')
	elseif input:match('^d?[%d]+$') then
		count = 1
		range = input:match('^d?([%d]+)$')
	else
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end

	count = tonumber(count)
	range = tonumber(range)

	if range < 2 then
		sendReply(msg, 'The minimum range is 2.')
		return
	end
	if range > 1000 or count > 1000 then
		sendReply(msg, 'The maximum range and count are 1000.')
		return
	end

	local output = '*' .. count .. 'd' .. range .. '*\n`'
	for i = 1, count do
		output = output .. math.random(range) .. '\t'
	end
	output = output .. '`'

	sendMessage(msg.chat.id, output, true, msg.message_id, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
