local calc = {}

local URL = require('socket.url')
local HTTPS = require('ssl.https')
local utilities = require('utilities')

calc.command = 'calc <expression>'
calc.doc = [[```
/calc <expression>
Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.
```]]

function calc:init()
	calc.triggers = utilities.triggers(self.info.username):t('calc', true).table
end

function calc:action(msg)

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
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	output = '`' .. output .. '`'

	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return calc
