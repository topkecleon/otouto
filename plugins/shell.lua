local shell = {}

local bindings = require('bindings')
local utilities = require('utilities')

function shell:init()
	shell.triggers = utilities.triggers(self.info.username):t('run', true).table
end

function shell:action(msg)

	if msg.from.id ~= self.config.admin then
		return
	end

	local input = utilities.input(msg.text)
	input = input:gsub('—', '--')
	
	if not input then
		bindings.sendReply(self, msg, 'Please specify a command to run.')
		return
	end

	local output = io.popen(input):read('*all')
	if output:len() == 0 then
		output = 'Done!'
	else
		output = '```\n' .. output .. '\n```'
	end
	bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)

end

return shell
