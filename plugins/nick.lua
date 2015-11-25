local doc = [[
	/nick <nickname>
	Set your nickname. Use "/whoami" to check your nickname and "/nick -" to delete it.
]]

local triggers = {
	'^/nick[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		sendReply(msg, doc)
		return true
	end

	if string.len(input) > 32 then
		sendReply(msg, 'The character limit for nicknames is 32.')
		return true
	end

	nicks = load_data('nicknames.json')

	if input == '-' then
		nicks[msg.from.id_str] = nil
		sendReply(msg, 'Your nickname has been deleted.')
	else
		nicks[msg.from.id_str] = input
		sendReply(msg, 'Your nickname has been set to "' .. input .. '".')
	end

	save_data('nicknames.json', nicks)
	return true

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
