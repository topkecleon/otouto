local PLUGIN = {}

PLUGIN.doc = [[
	!remind <delay> <message>
	Set a reminder for yourself. First argument is the number of minutes until you wish to be reminded.
]]

PLUGIN.triggers = {
	'^!remind$',
	'^!remind '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local delay = first_word(input)
	if not tonumber(delay) then
		return send_msg(msg, 'The delay must be a number.')
	end

	if string.len(msg.text) <= string.len(delay) + 9 then
		return send_msg(msg, 'Please include a reminder.')
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
		delay = (delay * 60) .. ' seconds'
	else
		delay = delay .. ' minutes'
	end

	local message = 'Your reminder has been set for ' .. delay .. ' from now:\n' .. text

	send_msg(msg, message)

end

return PLUGIN
