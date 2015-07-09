local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('remind.COMMAND') .. ' <' .. I18N('ARG_DELAY') .. '> <' .. I18N('ARG_MESSAGE') .. '>\n' .. I18N('remind.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('remind.COMMAND') .. '$',
	'^' .. config.COMMAND_START .. I18N('remind.COMMAND') .. ' '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local delay = first_word(input)
	if not tonumber(delay) then
		return send_msg(msg, I18N('remind.NO_DELAY'))
	end

	if string.len(msg.text) <= string.len(delay) + 9 then
		return send_msg(msg, I18N('remind.NO_MESSAGE'))
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
		delay = (delay * 60) .. ' ' .. I18N('remind.SECONDS')
	else
		delay = delay .. ' ' .. I18N('remind.MINUTES')
	end

	local message = I18N('remind.REMINDER_SET', {DELAY = delay, MESSAGE = text})

	send_msg(msg, message)

end

return PLUGIN
