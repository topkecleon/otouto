local echo = {}

local utilities = require('utilities')

echo.command = 'echo <text>'
echo.doc = [[```
/echo <text>
Repeats a string of text.
```]]

function echo:init()
	echo.triggers = utilities.triggers(self.info.username):t('echo', true).table
end

function echo:action(msg)

	local input = utilities.input(msg.text)

	if not input then
		utilities.send_message(self, msg.chat.id, echo.doc, true, msg.message_id, true)
	else
		local output
		if msg.chat.type == 'supergroup' then
			output = '*Echo:*\n"' .. utilities.md_escape(input) .. '"'
		else
			output = utilities.md_escape(utilities.char.zwnj..input)
		end
		utilities.send_message(self, msg.chat.id, output, true, nil, true)
	end


end

return echo
