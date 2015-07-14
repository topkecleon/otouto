local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.remind.command .. '\n' .. locale.remind.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.remind.command,
	'^' .. config.COMMAND_START .. 'remind '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local delay = first_word(input)
	if not tonumber(delay) then
		return send_msg(msg, locale.remind.no_delay)
	end

	if string.len(msg.text) <= string.len(delay) + 9 then
		return send_msg(msg, locale.remind.no_message)
	end
	local text = string.sub(msg.text, string.len(delay)+10) -- this is gross
	if msg.from.username then
		text = text .. '\n@' .. msg.from.username
	end

	local delay = tonumber(delay)

	local reminder = {
		alarm = os.time() + (delay * 60),
		chat_id = msg.chat.id,
		text = text
	}

	table.insert(reminders, reminder)

	if delay <= 1 then
		delay = (delay * 60) .. ' ' .. locale.remind.seconds
	else
		delay = delay .. ' ' .. locale.remind.minutes
	end

	local message = locale.remind.reminder_set
	message = message:gsub('#DELAY', delay)
	message = message:gsub('#TEXT', text)

	send_msg(msg, message)

end

return PLUGIN
