local dice = {}

local utilities = require('otouto.utilities')

dice.command = 'roll <nDr>'

function dice:init(config)
	dice.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('roll', true).table
	dice.doc = [[```
]]..config.cmd_pat..[[roll <nDr>
Returns a set of dice rolls, where n is the number of rolls and r is the range. If only a range is given, returns only one roll.
```]]
end

function dice:action(msg)

	local input = utilities.input(msg.text_lower)
	if not input then
		utilities.send_message(self, msg.chat.id, dice.doc, true, msg.message_id, true)
		return
	end

	local count, range
	if input:match('^[%d]+d[%d]+$') then
		count, range = input:match('([%d]+)d([%d]+)')
	elseif input:match('^d?[%d]+$') then
		count = 1
		range = input:match('^d?([%d]+)$')
	else
		utilities.send_message(self, msg.chat.id, dice.doc, true, msg.message_id, true)
		return
	end

	count = tonumber(count)
	range = tonumber(range)

	if range < 2 then
		utilities.send_reply(self, msg, 'The minimum range is 2.')
		return
	end
	if range > 1000 or count > 1000 then
		utilities.send_reply(self, msg, 'The maximum range and count are 1000.')
		return
	end

	local output = '*' .. count .. 'd' .. range .. '*\n`'
	for _ = 1, count do
		output = output .. math.random(range) .. '\t'
	end
	output = output .. '`'

	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return dice
