local channel = {}

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

function channel:init(config)
	channel.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('ch', true).table
	channel.command = 'ch <channel> \\n <message>'
	channel.doc = config.cmd_pat .. [[ch <channel>
<message>

Sends a message to a channel. Channel may be specified via ID or username. Messages are markdown-enabled. Users may only send messages to channels for which they are the owner or an administrator.

The following markdown syntax is supported:
 *bold text*
 _italic text_
 [text](URL)
 `inline fixed-width code`
 `‌`‌`pre-formatted fixed-width code block`‌`‌`]]
end

function channel:action(msg, config)
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
				output = 'Sorry, you do not appear to be an administrator for that channel.'
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
