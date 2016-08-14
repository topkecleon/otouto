local utilities = require('otouto.utilities')

local greetings = {}

function greetings:init(config)
	greetings.triggers = {}
	for _, triggers in pairs(config.greetings) do
		for i = 1, #triggers do
			triggers[i] = '^' .. triggers[i] .. ',? ' .. self.info.first_name:lower() .. '%p*$'
			table.insert(greetings.triggers, triggers[i])
		end
	end
end

function greetings:action(msg, config)
	local nick
	if self.database.userdata[tostring(msg.from.id)] then
		nick = self.database.userdata[tostring(msg.from.id)].nickname
	end
	nick = nick or utilities.build_name(msg.from.first_name, msg.from.last_name)

	for response, triggers in pairs(config.greetings) do
		for _, trigger in pairs(triggers) do
			if string.match(msg.text_lower, trigger) then
				utilities.send_message(self, msg.chat.id, response:gsub('#NAME', nick))
				return
			end
		end
	end
end

return greetings
