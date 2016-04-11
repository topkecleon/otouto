 -- Requires that the "fortune" program is installed on your computer.

local fortune = {}

local bindings = require('bindings')
local utilities = require('utilities')

function fortune:init()
	local s = io.popen('fortune'):read('*all')
	if s:match('not found$') then
		print('fortune is not installed on this computer.')
		print('fortune.lua will not be enabled.')
		return
	end

	fortune.triggers = utilities.triggers(self.info.username):t('fortune').table
end

fortune.command = 'fortune'
fortune.doc = '`Returns a UNIX fortune.`'

function fortune:action(msg)

	local message = io.popen('fortune'):read('*all')
	bindings.sendMessage(self, msg.chat.id, message)

end

return fortune
