local calc = {}

local URL = require('socket.url')
local HTTPS = require('ssl.https')
local utilities = require('otouto.utilities')

calc.command = 'calc <expression>'

function calc:init(config)
	calc.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('calc', true).table
	calc.doc = [[```
]]..config.cmd_pat..[[calc <expression>
Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.
```]]
end

function calc:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, calc.doc, true, msg.message_id, true)
			return
		end
	end

	local url = 'https://api.mathjs.org/v1/?expr=' .. URL.escape(input)

	local output = HTTPS.request(url)
	if not output then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end

	output = '`' .. output .. '`'

	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return calc
