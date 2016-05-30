local patterns = {}

local utilities = require('utilities')

patterns.triggers = {
	'^/?s/.-/.-/?$'
}

function patterns:action(msg)

	if not msg.reply_to_message then return end
	local output = msg.reply_to_message.text or ''
	local m1, m2 = msg.text:match('^/?s/(.-)/(.-)/?$')
	if not m2 then return true end
	local res
	res, output = pcall(
		function()
			return output:gsub(m1, m2)
		end
	)
	if res == false then
		output = 'Malformed pattern!'
		utilities.send_reply(self, msg, output)
		return
	end
	output = 'Did you mean:\n"' .. output:sub(1, 4000) .. '"'
	utilities.send_reply(self, msg.reply_to_message, output)

end

return patterns
