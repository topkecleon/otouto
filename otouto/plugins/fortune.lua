 -- Requires that the "fortune" program is installed on your computer.

local fortune = {}

local utilities = require('otouto.utilities')

function fortune:init(config)
	local s = io.popen('fortune'):read('*all')
	if s:match('not found$') then
		print('fortune is not installed on this computer.')
		print('fortune.lua will not be enabled.')
		return
	end

	fortune.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('fortune').table
end

fortune.command = 'fortune'
fortune.doc = '`Returns a UNIX fortune.`'

function fortune:action(msg)

	local fortunef = io.popen('fortune')
	local output = fortunef:read('*all')
	output = '```\n' .. output .. '\n```'
	utilities.send_message(self, msg.chat.id, output, true, nil, true)
	fortunef:close()

end

return fortune
