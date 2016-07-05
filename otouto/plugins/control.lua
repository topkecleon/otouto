local control = {}

local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

local cmd_pat -- Prevents the command from being uncallable.

function control:init(config)
	cmd_pat = config.cmd_pat
	control.triggers = utilities.triggers(self.info.username, cmd_pat,
		{'^'..cmd_pat..'script'}):t('reload', true):t('halt').table
end

function control:action(msg, config)

	if msg.from.id ~= config.admin then
		return
	end

	if msg.date < os.time() - 2 then return end

	if msg.text_lower:match('^'..cmd_pat..'reload') then
		for pac, _ in pairs(package.loaded) do
			if pac:match('^otouto%.plugins%.') then
				package.loaded[pac] = nil
			end
		end
		package.loaded['otouto.bindings'] = nil
		package.loaded['otouto.utilities'] = nil
		package.loaded['config'] = nil
		if msg.text_lower:match('%+config') then for k, v in pairs(require('config')) do
			config[k] = v
		end end
		bot.init(self, config)
		utilities.send_reply(self, msg, 'Bot reloaded!')
	elseif msg.text_lower:match('^'..cmd_pat..'halt') then
		self.is_started = false
		utilities.send_reply(self, msg, 'Stopping bot!')
	elseif msg.text_lower:match('^'..cmd_pat..'script') then
		local input = msg.text_lower:match('^'..cmd_pat..'script\n(.+)')
		if not input then
			utilities.send_reply(self, msg, 'usage: ```\n'..cmd_pat..'script\n'..cmd_pat..'command <arg>\n...\n```', true)
			return
		end
		input = input .. '\n'
		for command in input:gmatch('(.-)\n') do
			command = utilities.trim(command)
			msg.text = command
			bot.on_msg_receive(self, msg, config)
		end
	end

end

return control

