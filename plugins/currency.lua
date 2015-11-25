local doc = [[
	/cash [amount] <from> to <to>
	Example: /cash 5 USD to EUR
	Returns exchange rates for various currencies.
]]

local triggers = {
	'^/cash[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:upper()
	if not input:match('%a%a%a TO %a%a%a') then
		sendReply(msg, doc)
		return
	end

	local from = input:match('(%a%a%a) TO')
	local to = input:match('TO (%a%a%a)')
	local amount = input:match('([%d]+) %a%a%a TO %a%a%a') or 1
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

		result = str:format('%.2f')

	end

	local message = amount .. ' ' .. from .. ' = ' .. result .. ' ' .. to
	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
