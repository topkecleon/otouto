local doc = [[
	/cash <from> <to> [amount]
	Convert an amount from one currency to another.
	Example: /cash USD EUR 5
]]

local triggers = {
	'^/cash'
}

local action = function(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, doc)
	end

	local url = 'http://www.google.com/finance/converter' -- thanks juan :^)

	local from = first_word(input):upper()
	local to = first_word(input, 2):upper()
	local amount = first_word(input, 3)
	local result

	if not tonumber(amount) then
		amount = 1
		result = 1
	end

	if from ~= to then

		local url = url .. '?from=' .. from .. '&to=' .. to .. '&a=' .. amount

		local str, res = HTTP.request(url)
		if res ~= 200 then
			return send_msg(msg, config.locale.errors.connection)
		end

		local str = str:match('<span class=bld>(.*) %u+</span>')
		if not str then return send_msg(msg, config.locale.errors.results) end
		result = string.format('%.2f', str)

	end

	local message = amount .. ' ' .. from .. ' = ' .. result .. ' ' .. to
	send_msg(msg, message)

end

return {
	doc = doc,
	triggers = triggers,
	action = action
}
