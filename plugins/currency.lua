local command = 'cash [amount] <from> to <to>'
local doc = [[```
/cash [amount] <from> to <to>
Example: /cash 5 USD to EUR
Returns exchange rates for various currencies.
Source: Google Finance.
```]]

local triggers = {
	'^/cash[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:upper()
	if not input:match('%a%a%a TO %a%a%a') then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end

	local from = input:match('(%a%a%a) TO')
	local to = input:match('TO (%a%a%a)')
	local amount = get_word(input, 2)
	amount = tonumber(amount) or 1
	local result = 1

	local url = 'https://www.google.com/finance/converter'

	if from ~= to then

		local url = url .. '?from=' .. from .. '&to=' .. to .. '&a=' .. amount
		local str, res = HTTPS.request(url)
		if res ~= 200 then
			sendReply(msg, config.errors.connection)
			return
		end

		str = str:match('<span class=bld>(.*) %u+</span>')
		if not str then
			sendReply(msg, config.errors.results)
			return
		end

		result = string.format('%.2f', str)

	end

	local output = amount .. ' ' .. from .. ' = ' .. result .. ' ' .. to .. '\n\n'
	output = output .. os.date('!%F %T UTC') .. '\nSource: Google Finance'
	output = '`' .. output .. '`'

	sendMessage(msg.chat.id, output, true, nil, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
