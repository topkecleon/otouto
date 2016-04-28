database.reminders = database.reminders or {}

local command = 'remind <duration> <message>'
local doc = [[```
/remind <duration> <message>
Repeats a message after a duration of time, in minutes.
```]]

local triggers = {
	'^/remind'
}

local action = function(msg)
	-- Ensure there are arguments. If not, send doc.
	local input = msg.text:input()
	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end
	-- Ensure first arg is a number. If not, send doc.
	local duration = get_word(input, 1)
	if not tonumber(duration) then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end
	-- Duration must be between one minute and one year (approximately).
	duration = tonumber(duration)
	if duration < 1 then
		duration = 1
	elseif duration > 526000 then
		duration = 526000
	end
	-- Ensure there is a second arg.
	local message = input:input()
	if not message then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end
	-- Make a database entry for the group/user if one does not exist.
	database.reminders[msg.chat.id_str] = database.reminders[msg.chat.id_str] or {}
	-- Limit group reminders to 10 and private reminders to 50.
	if msg.chat.type ~= 'private' and table_size(database.reminders[msg.chat.id_str]) > 9 then
		sendReply(msg, 'Sorry, this group already has ten reminders.')
		return
	elseif msg.chat.type == 'private' and table_size(database.reminders[msg.chat.id_str]) > 49 then
		sendReply(msg, 'Sorry, you already have fifty reminders.')
		return
	end
	-- Put together the reminder with the expiration, message, and message to reply to.
	local reminder = {
		time = os.time() + duration * 60,
		message = message
	}
	table.insert(database.reminders[msg.chat.id_str], reminder)
	local output = 'I will remind you in ' .. duration
	if duration == 1 then
		output = output .. ' minute!'
	else
		output = output .. ' minutes!'
	end
	sendReply(msg, output)
end

local cron = function()
	local time = os.time()
	-- Iterate over the group entries in the reminders database.
	for chat_id, group in pairs(database.reminders) do
		local new_group = {}
		-- Iterate over each reminder.
		for i, reminder in ipairs(group) do
			-- If the reminder is past-due, send it and nullify it.
			-- Otherwise, add it to the replacement table.
			if time > reminder.time then
				local output = '*Reminder:*\n"' .. markdown_escape(reminder.message) .. '"'
				local res = sendMessage(chat_id, output, true, nil, true)
				-- If the message fails to send, save it for later.
				if res then
					reminder = nil
				else
					table.insert(new_group, reminder)
				end
			else
				table.insert(new_group, reminder)
			end
		end
		-- Nullify the original table and replace it with the new one.
		group = nil
		database.reminders[chat_id] = new_group
		-- Nullify the table if it is empty.
		if #new_group == 0 then
			database.reminders[chat_id] = nil
		end
	end
end

return {
	action = action,
	triggers = triggers,
	cron = cron,
	command = command,
	doc = doc
}
