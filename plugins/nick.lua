local doc = [[
	/nick <nickname>
	Set your nickname for the bot to call you.
]]

local triggers = {
	'^/nick'
}

local action = function(msg)

	local data = load_data('nicknames.json')
	local id = tostring(msg.from.id)
	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, doc)
	end

	data[id] = input
	save_data('nicknames.json', data)
	send_msg(msg, 'Your nickname has been set to ' .. input .. '.')

end

return {
	doc = doc,
	triggers = triggers,
	action = action
}
