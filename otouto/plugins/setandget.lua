local setandget = {}

local utilities = require('otouto.utilities')

function setandget:init(config)
	self.database.setandget = self.database.setandget or {}
	setandget.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('set', true):t('get', true).table
	setandget.doc = [[```
]]..config.cmd_pat..[[set <name> <value>
Stores a value with the given name. Use "]]..config.cmd_pat..[[set <name> --" to delete the stored value.
]]..config.cmd_pat..[[get [name]
Returns the stored value or a list of stored values.
```]]
end

setandget.command = 'set <name> <value>'

function setandget:action(msg, config)

	local chat_id_str = tostring(msg.chat.id)
	local input = utilities.input(msg.text)
	self.database.setandget[chat_id_str] = self.database.setandget[chat_id_str] or {}

	if msg.text_lower:match('^'..config.cmd_pat..'set') then

		if not input then
			utilities.send_message(self, msg.chat.id, setandget.doc, true, nil, true)
			return
		end

		local name = utilities.get_word(input:lower(), 1)
		local value = utilities.input(input)

		if not name or not value then
			utilities.send_message(self, msg.chat.id, setandget.doc, true, nil, true)
		elseif value == '--' or value == '—' then
			self.database.setandget[chat_id_str][name] = nil
			utilities.send_message(self, msg.chat.id, 'That value has been deleted.')
		else
			self.database.setandget[chat_id_str][name] = value
			utilities.send_message(self, msg.chat.id, '"' .. name .. '" has been set to "' .. value .. '".', true)
		end

	elseif msg.text_lower:match('^'..config.cmd_pat..'get') then

		if not input then
			local output
			if utilities.table_size(self.database.setandget[chat_id_str]) == 0 then
				output = 'No values have been stored here.'
			else
				output = '*List of stored values:*\n'
				for k,v in pairs(self.database.setandget[chat_id_str]) do
					output = output .. '• ' .. k .. ': `' .. v .. '`\n'
				end
			end
			utilities.send_message(self, msg.chat.id, output, true, nil, true)
			return
		end

		local output
		if self.database.setandget[chat_id_str][input:lower()] then
			output = '`' .. self.database.setandget[chat_id_str][input:lower()] .. '`'
		else
			output = 'There is no value stored by that name.'
		end

		utilities.send_message(self, msg.chat.id, output, true, nil, true)

	end

end

return setandget
