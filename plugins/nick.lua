local doc = [[
	/nick <nickname>
	Set your nickname for the bot to call you.
	Use -- to clear your nickname.
]]

local triggers = {
	'^/nick'
}

local action = function(msg)

	local data = load_data('nicknames.json')
	local id = tostring(msg.from.id)
	local input = get_input(msg.text)
	if not input then
		local message = ''
		if data[id] then
			message = '\nYour nickname is currently ' .. data[id] .. '.'
		end
		return send_msg(msg, doc..message)
	end

	if input == '--' then
		data[id] = nil
		save_data('nicknames.json', data)
		send_msg(msg, 'Your nickname has been deleted.')
		return
	end

	input = input:sub(1,64):gsub('\n',' ')
	data[id] = input
	save_data('nicknames.json', data)
	send_msg(msg, 'Your nickname has been set to ' .. input .. '.')

end

return {
	doc = doc,
	triggers = triggers,
	action = action
}
