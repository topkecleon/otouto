local preview = {}

local HTTP = require('socket.http')
local bindings = require('bindings')
local utilities = require('utilities')

preview.command = 'preview <link>'
preview.doc = [[```
/preview <link>
Returns a full-message, "unlinked" preview.
```]]

function preview:init()
	preview.triggers = utilities.triggers(self.info.username):t('preview', true).table
end

function preview:action(msg)

	local input = utilities.input(msg.text)

	if not input then
		bindings.sendMessage(self, msg.chat.id, preview.doc, true, nil, true)
		return
	end

	input = utilities.get_word(input, 1)
	if not input:match('^https?://.+') then
		input = 'http://' .. input
	end

	local res = HTTP.request(input)
	if not res then
		bindings.sendReply(self, msg, 'Please provide a valid link.')
		return
	end

	if res:len() == 0 then
		bindings.sendReply(self, msg, 'Sorry, the link you provided is not letting us make a preview.')
		return
	end

	-- Invisible zero-width, non-joiner.
	local output = '[​](' .. input .. ')'
	bindings.sendMessage(self, msg.chat.id, output, false, nil, true)

end

return preview
