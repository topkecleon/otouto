local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('dice.COMMAND') .. ' [' .. I18N('ARG_RANGE') .. ']\n' .. I18N('dice.HELP', {COMMAND_START = config.COMMAND_START, COMMAND = I18N('dice.COMMAND')})

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('dice.COMMAND')
}

function PLUGIN.action(msg)

	math.randomseed(os.time())

	local input = get_input(msg.text)
	if not input then
		input = 6
	else
		input = string.upper(input)
	end

	if tonumber(input) then
		range = tonumber(input)
		rolls = 1
	elseif string.find(input, 'D') then
		local dloc = string.find(input, 'D')
		if dloc == 1 then
			rolls = 1
		else
			rolls = string.sub(input, 1, dloc-1)
		end
		range = string.sub(input, dloc+1)
		if not tonumber(rolls) or not tonumber(range) then
			return send_msg(msg, I18N('INVALID_SYNTAX'))
		end
	else
		return send_msg(msg, I18N('INVALID_SYNTAX'))
	end

	if tonumber(rolls) == 1 then
		results = 'Random (1-' .. range .. '):\t'
	elseif tonumber(rolls) > 1 then
		results = rolls .. 'D' .. range .. ':\n'
	else
		return send_msg(msg, I18N('INVALID_SYNTAX'))
	end

	if tonumber(range) < 2 then
		return send_msg(msg, I18N('INVALID_SYNTAX'))
	end

	if tonumber(rolls) > 100 then
		return send_msg(msg, I18N('dice.MAX_DICE'))
	end

	if tonumber(range) > 100000 then
		return send_msg(msg, I18N('dice.MAX_RANGE'))
	end

	for i = 1, tonumber(rolls) do
		results = results .. math.random(range) .. '\t'
	end

	send_msg(msg, results)

end

return PLUGIN

