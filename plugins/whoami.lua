local whoami = {}

local utilities = require('utilities')

whoami.command = 'whoami'
whoami.doc = [[```
Returns user and chat info for you or the replied-to message.
Alias: /who
```]]

function whoami:init()
	whoami.triggers = utilities.triggers(self.info.username):t('who', true):t('whoami').table
end

function whoami:action(msg)

	if msg.reply_to_message then
		msg = msg.reply_to_message
		msg.from.name = utilities.build_name(msg.from.first_name, msg.from.last_name)
	end

	local chat_id = math.abs(msg.chat.id)
	if chat_id > 1000000000000 then
		chat_id = chat_id - 1000000000000
	end

	local user = 'You are @%s, also known as *%s* `[%s]`'
	if msg.from.username then
		user = user:format(utilities.markdown_escape(msg.from.username), msg.from.name, msg.from.id)
	else
		user = 'You are *%s* `[%s]`,'
		user = user:format(msg.from.name, msg.from.id)
	end

	local group = '@%s, also known as *%s* `[%s]`.'
	if msg.chat.type == 'private' then
		group = group:format(utilities.markdown_escape(self.info.username), self.info.first_name, self.info.id)
	elseif msg.chat.username then
		group = group:format(utilities.markdown_escape(msg.chat.username), msg.chat.title, chat_id)
	else
		group = '*%s* `[%s]`.'
		group = group:format(msg.chat.title, chat_id)
	end

	local output = user .. ', and you are messaging ' .. group

	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return whoami
