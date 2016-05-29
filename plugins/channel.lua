local channel = {}

local bindings = require('bindings')
local utilities = require('utilities')

--channel.command = 'ch <channel> \\n <message>'
channel.doc = [[```
/ch <channel>
<message>

Sends a message to a channel. Channel may be specified via ID or username. Messages are markdown-enabled. Users may only send messages to channels for which they are the owner or an administrator.

The following markdown syntax is supported:
 *bold text*
 _italic text_
 [text](URL)
 `inline fixed-width code`
 `‌`‌`pre-formatted fixed-width code block`‌`‌`

Due to the frequent dysfunction and incompletion of the API method used to determine the administrators of a channel, this command may not work for the owners of some channels.
```]]

function channel:init()
	channel.triggers = utilities.triggers(self.info.username):t('ch', true).table
end

function channel:action(msg)
	-- An exercise in using zero early returns. :)
	local input = utilities.input(msg.text)
	local output
	if input then
		local chat_id = utilities.get_word(input, 1)
		local admin_list, t = bindings.getChatAdministrators(self, { chat_id = chat_id } )
		if admin_list then
			local is_admin = false
			for _, admin in ipairs(admin_list.result) do
				if admin.user.id == msg.from.id then
					is_admin = true
				end
			end
			if is_admin then
				local text = input:match('\n(.+)')
				if text then
					local success, result = utilities.send_message(self, chat_id, text, true, nil, true)
					if success then
						output = 'Your message has been sent!'
					else
						output = 'Sorry, I was unable to send your message.\n`' .. result.description .. '`'
					end
				else
					output = 'Please enter a message to be sent. Markdown is supported.'
				end
			else
				output = 'Sorry, you do not appear to be an administrator for that channel.\nThere is currently a known bug in the getChatAdministrators method, where administrator lists will often not show a channel\'s owner.'
			end
		else
			output = 'Sorry, I was unable to retrieve a list of administrators for that channel.\n`' .. t.description .. '`'
		end
	else
		output = channel.doc
	end
	utilities.send_reply(self, msg, output, true)
end

return channel
