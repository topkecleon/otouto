--[[
    remind.lua
    Allows users to set reminders.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local remind = {}

function remind:init()
    self.database.remind = self.database.remind or {}

    remind.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('remind', true).table

    remind.doc = self.config.cmd_pat .. [[remind <duration> <message>
Repeats a message after a duration of time, in minutes.
The maximum length of a reminder is %s characters. The maximum duration of a timer is %s minutes. The maximum number of reminders for a group is %s. The maximum number of reminders in private is %s.]]
    remind.doc = remind.doc:format(
        self.config.remind.max_length,
        self.config.remind.max_duration,
        self.config.remind.max_reminders_group,
        self.config.remind.max_reminders_private
    )
end

function remind:action(msg)
    local input = utilities.input(msg.text)
    if not input then
        utilities.send_reply(msg, remind.doc, 'html')
        return
    end

    local duration = tonumber(utilities.get_word(input, 1))
    if not duration then
        utilities.send_reply(msg, remind.doc, 'html')
        return
    end

    if duration < 1 then
        duration = 1
    elseif duration > self.config.remind.max_duration then
        duration = self.config.remind.max_duration
    end

    local message
    if msg.reply_to_message and #msg.reply_to_message.text > 0 then
        message = msg.reply_to_message.text
    elseif utilities.input(input) then
        message = utilities.input(input)
    else
        utilities.send_reply(msg, remind.doc, 'html')
        return
    end

    if #message > self.config.remind.max_length then
        utilities.send_reply(msg, 'The maximum length of reminders is ' .. self.config.remind.max_length .. '.')
        return
    end

    local chat_id_str = tostring(msg.chat.id)
    local output
    self.database.remind[chat_id_str] = self.database.remind[chat_id_str] or {}
    if msg.chat.type == 'private' and utilities.table_size(self.database.remind[chat_id_str]) >= self.config.remind.max_reminders_private then
        output = 'Sorry, you already have the maximum number of reminders.'
    elseif msg.chat.type ~= 'private' and utilities.table_size(self.database.remind[chat_id_str]) >= self.config.remind.max_reminders_group then
        output = 'Sorry, this group already has the maximum number of reminders.'
    else
        table.insert(self.database.remind[chat_id_str], {
            time = os.time() + (duration * 60),
            message = message
        })
        output = string.format(
            'I will remind you in %s minute%s!',
            duration,
            duration == 1 and '' or 's'
        )
    end
    utilities.send_reply(msg, output, true)
end

function remind:cron()
    local time = os.time()
    -- Iterate over the group entries in the reminders database.
    for chat_id, group in pairs(self.database.remind) do
        -- Iterate over each reminder.
        for k, reminder in pairs(group) do
            -- If the reminder is past-due, send it and nullify it.
            -- Otherwise, add it to the replacement table.
            if time > reminder.time then
                local output = '<b>Reminder:</b>\n"' .. utilities.html_escape(reminder.message) .. '"'
                local res = utilities.send_message(chat_id, output, true, nil, 'html')
                -- If the message fails to send, save it for later (if enabled in config).
                if res or not self.config.remind.persist then
                    group[k] = nil
                end
            end
        end
    end
end

return remind
