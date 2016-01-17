 -- Requires that the "fortune" program is installed on your computer.

local s = io.popen('fortune'):read('*all')
if s:match('not found$') then
	print('fortune is not installed on this computer.')
	print('fortune.lua will not be enabled.')
	return
end

local command = 'fortune'
local doc = '`Returns a UNIX fortune.`'

local triggers = {
	'^/fortune[@'..bot.username..']*'
}

local action = function(msg)

	local message = io.popen('fortune'):read('*all')
	sendMessage(msg.chat.id, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
