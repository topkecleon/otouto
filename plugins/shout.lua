local command = 'shout <text>'
local doc = [[```
/shout <text>
Shouts something.
```]]

local triggers = {
	'^/shout[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()

	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
		return
	end
	input = input:trim()

	if input:len() > 20 then
		input = input:sub(1,20)
	end

	input = input:upper()
	local output = ''
	local inc = 0
	for match in input:gmatch('([%z\1-\127\194-\244][\128-\191]*)') do
		output = output .. match .. ' '
	end
	output = output .. '\n'
	for match in input:sub(2):gmatch('([%z\1-\127\194-\244][\128-\191]*)') do
		local spacing = ''
		for i = 1, inc do
			spacing = spacing .. '  '
		end
		inc = inc + 1
		output = output .. match .. ' ' .. spacing .. match .. '\n'
	end
	output = '```\n' .. output:trim() .. '\n```'
	sendMessage(msg.chat.id, output, true, false, true)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
