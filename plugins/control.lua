local control = {}

local bot = require('bot')
local utilities = require('utilities')

function control:init()
	control.triggers = utilities.triggers(self.info.username):t('reload'):t('halt').table
	table.insert(control.triggers, '^/script')
end

function control:action(msg, config)

	if msg.from.id ~= config.admin then
		return
	end

	if msg.date < os.time() - 1 then return end

	if msg.text:match('^'..utilities.INVOCATION_PATTERN..'reload') then
		for pac, _ in pairs(package.loaded) do
			if pac:match('^plugins%.') then
				package.loaded[pac] = nil
			end
		end
		package.loaded['bindings'] = nil
		package.loaded['utilities'] = nil
		package.loaded['config'] = nil
		for k, v in pairs(require('config')) do
			config[k] = v
		end
		bot.init(self, config)
		utilities.send_reply(self, msg, 'Bot reloaded!')
	elseif msg.text:match('^'..utilities.INVOCATION_PATTERN..'halt') then
		self.is_started = false
		utilities.send_reply(self, msg, 'Stopping bot!')
	elseif msg.text:match('^'..utilities.INVOCATION_PATTERN..'script') then
		local input = msg.text:match('^'..utilities.INVOCATION_PATTERN..'script\n(.+)')
		if not input then
			utilities.send_reply(self, msg, 'usage: ```\n/script\n/command <arg>\n...\n```', true)
			return
		end
		input = input .. '\n'
		for command in input:gmatch('(.-)\n') do
			command = utilities.trim(command)
			msg.text = command
			bot.on_msg_receive(self, msg)
		end
	end

end

return control

