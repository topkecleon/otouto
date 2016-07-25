 -- Actually the simplest plugin ever!

local ping = {}

local utilities = require('otouto.utilities')

function ping:init(config)
	ping.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('ping'):t('annyong').table
end

function ping:action(msg, config)
	local output = msg.text_lower:match('^'..config.cmd_pat..'ping') and 'Pong!' or 'Annyong.'
	utilities.send_message(self, msg.chat.id, output)
end

return ping
