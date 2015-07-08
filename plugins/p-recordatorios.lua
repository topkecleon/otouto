local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[recuerdame <tiempo> <mensaje>
	Establece un recordatorio, el primer parametro es el numero de minutos.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'recuerdame'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local delay = first_word(input)
	if not tonumber(delay) then
		return send_msg(msg, 'El tiempo debe ser un numero.')
	end

	if string.len(msg.text) <= string.len(delay) + 9 then
		return send_msg(msg, 'Por favor, añade un mensaje')
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
		delay = (delay * 60) .. ' segundos'
	else
		delay = delay .. ' minutos'
	end

	local message = 'El recordatorio se ha establecido en ' .. delay .. ' de ahora:\n' .. text

	send_msg(msg, message)

end

return PLUGIN
