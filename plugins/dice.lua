local doc = [[
	/roll <nDr>
	Returns a set of dice rolls, where n is the number of rolls and r is the range. If only a range is given, returns only one roll.
]]

local triggers = {
	'^/roll[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text_lower:input()
	if not input then
		sendReply(msg, doc)
		return
	end

	local count, range
	if input:match('^[%d]+d[%d]+$') then
		count, range = input:match('([%d]+)d([%d]+)')
	elseif input:match('^d?[%d]+$') then
		count = 1
		range = input:match('^d?([%d]+)$')
	else
		sendReply(msg, doc)
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

	local message = ''
	for i = 1, count do
		message = message .. math.random(range) .. '\t'
	end

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
