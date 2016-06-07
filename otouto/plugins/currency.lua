local currency = {}

local HTTPS = require('ssl.https')
local utilities = require('otouto.utilities')

currency.command = 'cash [amount] <from> to <to>'

function currency:init(config)
	currency.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('cash', true).table
	currency.doc = [[```
]]..config.cmd_pat..[[cash [amount] <from> to <to>
Example: ]]..config.cmd_pat..[[cash 5 USD to EUR
Returns exchange rates for various currencies.
Source: Google Finance.
```]]
end

function currency:action(msg, config)

	local input = msg.text:upper()
	if not input:match('%a%a%a TO %a%a%a') then
		utilities.send_message(self, msg.chat.id, currency.doc, true, msg.message_id, true)
		return
	end

	local from = input:match('(%a%a%a) TO')
	local to = input:match('TO (%a%a%a)')
	local amount = utilities.get_word(input, 2)
	amount = tonumber(amount) or 1
	local result = 1

	local url = 'https://www.google.com/finance/converter'

	if from ~= to then

		url = url .. '?from=' .. from .. '&to=' .. to .. '&a=' .. amount
		local str, res = HTTPS.request(url)
		if res ~= 200 then
			utilities.send_reply(self, msg, config.errors.connection)
			return
		end

		str = str:match('<span class=bld>(.*) %u+</span>')
		if not str then
			utilities.send_reply(self, msg, config.errors.results)
			return
		end

		result = string.format('%.2f', str)

	end

	local output = amount .. ' ' .. from .. ' = ' .. result .. ' ' .. to .. '\n\n'
	output = output .. os.date('!%F %T UTC') .. '\nSource: Google Finance`'
	output = '```\n' .. output .. '\n```'

	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return currency
