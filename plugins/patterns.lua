 -- Shout-out to Kenny, as I didn't want to write this until
 -- he upset himself over the very thought of me doing so.

local patterns = {}

local bindings = require('bindings')

patterns.triggers = {
	'^/?s/.-/.-/?$'
}

function patterns:action(msg)

	if not msg.reply_to_message then return end
	local output = msg.reply_to_message.text or ''
	local m1, m2 = msg.text:match('^/?s/(.-)/(.-)/?$')
	if not m2 then return true end
	output = output:gsub(m1, m2)
	output = 'Did you mean:\n"' .. output:sub(1, 4000) .. '"'
	bindings.sendReply(self, msg.reply_to_message, output)

end

return patterns
