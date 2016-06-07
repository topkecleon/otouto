local shell = {}

local utilities = require('otouto.utilities')

function shell:init(config)
	shell.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('run', true).table
end

function shell:action(msg, config)

	if msg.from.id ~= config.admin then
		return
	end

	local input = utilities.input(msg.text)
	input = input:gsub('—', '--')

	if not input then
		utilities.send_reply(self, msg, 'Please specify a command to run.')
		return
	end

	local output = io.popen(input):read('*all')
	if output:len() == 0 then
		output = 'Done!'
	else
		output = '```\n' .. output .. '\n```'
	end
	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return shell
