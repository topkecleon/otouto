local echo = {}

local utilities = require('otouto.utilities')

echo.command = 'echo <text>'

function echo:init(config)
	echo.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('echo', true).table
	echo.doc = [[```
]]..config.cmd_pat..[[echo <text>
Repeats a string of text.
```]]
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
