reminders = {}

local doc = [[
	/remind <delay> <message>
	Set a reminder for yourself. First argument is the number of minutes until you wish to be reminded.
]]

local triggers = {
	'^/remind'
}

local action = function(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, doc)
	end

	local delay = first_word(input)
	if not tonumber(delay) then
		return send_msg(msg, 'The delay must be a number.')
	end

	if string.len(msg.text) <= string.len(delay) + 9 then
		return send_msg(msg, 'Please include a reminder.')
	end
	local text = string.sub(msg.text, string.len(delay)+10)
	if msg.from.username then
		text = text .. '\n@' .. msg.from.username
	end

	local delay = tonumber(delay)

	local rem = {
		alarm = os.time() + (delay * 60),
		chat_id = msg.chat.id,
		text = text
	}

	table.insert(reminders, rem)

	if delay <= 1 then
		delay = (delay * 60) .. ' seconds'
	else
		delay = delay .. ' minutes'
	end

	local message = 'Your reminder has been set for ' .. delay .. ' from now:\n' .. text

	send_msg(msg, message)

end

local cron = function()

	for i,v in ipairs(reminders) do
		if os.time() > v.alarm then
			send_message(v.chat_id, text)
			table.remove(reminders, i)
		end
	end

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	cron = cron
}
