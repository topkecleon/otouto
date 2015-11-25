local triggers = {
	'^/admin[@'..bot.username..']*'
}

local commands = {

	['run'] = function(cmd)
		local cmd = cmd:input()
		if not cmd then
			return 'Please enter a command to run.'
		end
		return io.popen(cmd):read('*all')
	end,

	['lua'] = function(cmd)
		local cmd = cmd:input()
		if not cmd then
			return 'Please enter a command to run.'
		end
		local a = loadstring(cmd)()
		if a then
			return a
		else
			return 'Done!'
		end
	end,

	['reload'] = function(cmd)
		bot_init()
		return 'Bot reloaded!'
	end,

	['halt'] = function(cmd)
		is_started = false
		return 'Stopping bot!'
	end,

	['error'] = function(cmd)
		error('Intentional test error.')
	end

}

local action = function(msg)

	if msg.from.id ~= config.admin then
		return
	end

	local input = msg.text:input()
	if not input then
		local list = 'Specify a command: '
		for k,v in pairs(commands) do
			list = list .. k .. ', '
		end
		list = list:gsub(', $', '.')
		sendReply(msg, list)
		return
	end

	for k,v in pairs(commands) do
		if string.match(get_word(input, 1), k) then
			sendReply(msg, v(input))
			return
		end
	end

	sendReply(msg, 'Specify a command: run, reload, halt.')

end

return {
	action = action,
	triggers = triggers
}
