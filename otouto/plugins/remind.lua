local remind = {}

local utilities = require('otouto.utilities')

remind.command = 'remind <duration> <message>'

function remind:init(config)
	self.database.reminders = self.database.reminders or {}

	remind.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('remind', true).table

	config.remind = config.remind or {}
	setmetatable(config.remind, { __index = function() return 1000 end })

	remind.doc = config.cmd_pat .. [[remind <duration> <message>
Repeats a message after a duration of time, in minutes.
The maximum length of a reminder is %s characters. The maximum duration of a timer is %s minutes. The maximum number of reminders for a group is %s. The maximum number of reminders in private is %s.]]
	remind.doc = remind.doc:format(config.remind.max_length, config.remind.max_duration, config.remind.max_reminders_group, config.remind.max_reminders_private)
end

function remind:action(msg, config)
	local input = utilities.input(msg.text)
	if not input then
		utilities.send_reply(self, msg, remind.doc, true)
		return
	end

	local duration = tonumber(utilities.get_word(input, 1))
	if not duration then
		utilities.send_reply(self, msg, remind.doc, true)
		return
	end

	if duration < 1 then
		duration = 1
	elseif duration > config.remind.max_duration then
		duration = config.remind.max_duration
	end
	local message = utilities.input(input)
	if not message then
		utilities.send_reply(self, msg, remind.doc, true)
		return
	end

	if #message > config.remind.max_length then
		utilities.send_reply(self, msg, 'The maximum length of reminders is ' .. config.remind.max_length .. '.')
		return
	end

	local chat_id_str = tostring(msg.chat.id)
	local output
	self.database.reminders[chat_id_str] = self.database.reminders[chat_id_str] or {}
	if msg.chat.type == 'private' and utilities.table_size(self.database.reminders[chat_id_str]) >= config.remind.max_reminders_private then
		output = 'Sorry, you already have the maximum number of reminders.'
	elseif msg.chat.type ~= 'private' and utilities.table_size(self.database.reminders[chat_id_str]) >= config.remind.max_reminders_group then
		output = 'Sorry, this group already has the maximum number of reminders.'
	else
		table.insert(self.database.reminders[chat_id_str], {
			time = os.time() + (duration * 60),
			message = message
		})
		output = string.format(
			'I will remind you in %s minute%s!',
			duration,
			duration == 1 and '' or 's'
		)
	end
	utilities.send_reply(self, msg, output, true)
end

function remind:cron(config)
	local time = os.time()
	-- Iterate over the group entries in the reminders database.
	for chat_id, group in pairs(self.database.reminders) do
		-- Iterate over each reminder.
		for k, reminder in pairs(group) do
			-- If the reminder is past-due, send it and nullify it.
			-- Otherwise, add it to the replacement table.
			if time > reminder.time then
				local output = utilities.style.enquote('Reminder', reminder.message)
				local res = utilities.send_message(self, chat_id, output, true, nil, true)
				-- If the message fails to send, save it for later (if enabled in config).
				if res or not config.remind.persist then
					group[k] = nil
				end
			end
		end
	end
end

return remind
