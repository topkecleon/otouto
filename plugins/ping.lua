 -- Actually the simplest plugin ever!

local ping = {}

local utilities = require('utilities')

function ping:init()
	ping.triggers = utilities.triggers(self.info.username):t('ping'):t('annyong').table
end

function ping:action(msg)
	local output = msg.text_lower:match('^/ping') and 'Pong!' or 'Annyong.'
	utilities.send_message(self, msg.chat.id, output)
end

return ping
