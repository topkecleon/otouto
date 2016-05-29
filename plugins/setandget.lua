local setandget = {}

local utilities = require('utilities')

function setandget:init()
	self.database.setandget = self.database.setandget or {}
	setandget.triggers = utilities.triggers(self.info.username):t('set', true):t('get', true).table
end

setandget.command = 'set <name> <value>'
setandget.doc = [[```
/set <name> <value>
Stores a value with the given name. Use "/set <name> --" to delete the stored value.
/get [name]
Returns the stored value or a list of stored values.
```]]


function setandget:action(msg)

	local input = utilities.input(msg.text)
	self.database.setandget[msg.chat.id_str] = self.database.setandget[msg.chat.id_str] or {}

	if msg.text_lower:match('^/set') then

		if not input then
			utilities.send_message(self, msg.chat.id, setandget.doc, true, nil, true)
			return
		end

		local name = utilities.get_word(input:lower(), 1)
		local value = utilities.input(input)

		if not name or not value then
			utilities.send_message(self, msg.chat.id, setandget.doc, true, nil, true)
		elseif value == '--' or value == '—' then
			self.database.setandget[msg.chat.id_str][name] = nil
			utilities.send_message(self, msg.chat.id, 'That value has been deleted.')
		else
			self.database.setandget[msg.chat.id_str][name] = value
			utilities.send_message(self, msg.chat.id, '"' .. name .. '" has been set to "' .. value .. '".', true)
		end

	elseif msg.text_lower:match('^/get') then

		if not input then
			local output
			if utilities.table_size(self.database.setandget[msg.chat.id_str]) == 0 then
				output = 'No values have been stored here.'
			else
				output = '*List of stored values:*\n'
				for k,v in pairs(self.database.setandget[msg.chat.id_str]) do
					output = output .. '• ' .. k .. ': `' .. v .. '`\n'
				end
			end
			utilities.send_message(self, msg.chat.id, output, true, nil, true)
			return
		end

		local output
		if self.database.setandget[msg.chat.id_str][input:lower()] then
			output = '`' .. self.database.setandget[msg.chat.id_str][input:lower()] .. '`'
		else
			output = 'There is no value stored by that name.'
		end

		utilities.send_message(self, msg.chat.id, output, true, nil, true)

	end

end

return setandget
