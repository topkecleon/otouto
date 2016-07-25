 -- Put this on the bottom of your plugin list, after help.lua.
 -- If you want to configure your own greetings, copy the following table
 -- (without the "config.") to your config.lua file.

local greetings = {}

local utilities = require('otouto.utilities')

function greetings:init(config)
	config.greetings = config.greetings or {
		['Hello, #NAME.'] = {
			'hello',
			'hey',
			'sup',
			'hi',
			'good morning',
			'good day',
			'good afternoon',
			'good evening'
		},
		['Goodbye, #NAME.'] = {
			'bye',
			'later',
			'see ya',
			'good night'
		},
		['Welcome back, #NAME.'] = {
			'i\'m home',
			'i\'m back'
		},
		['You\'re welcome, #NAME.'] = {
			'thanks',
			'thank you'
		}
	}

	greetings.triggers = {
		self.info.first_name:lower() .. '%p*$'
	}
end

function greetings:action(msg, config)

	local nick = utilities.build_name(msg.from.first_name, msg.from.last_name)
	if self.database.userdata[tostring(msg.from.id)] then
		nick = self.database.userdata[tostring(msg.from.id)].nickname or nick
	end

	for trigger,responses in pairs(config.greetings) do
		for _,response in pairs(responses) do
			if msg.text_lower:match(response..',? '..self.info.first_name:lower()) then
				local output = utilities.char.zwnj .. trigger:gsub('#NAME', nick)
				utilities.send_message(self, msg.chat.id, output)
				return
			end
		end
	end

	return true

end

return greetings
