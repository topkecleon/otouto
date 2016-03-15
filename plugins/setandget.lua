database.setandget = database.setandget or {}

local command = 'set <name> <value>'
local doc = [[```
/set <name> <value>
Stores a value with the given name. Use "/set <name> --" to delete the stored value.
/get [name]
Returns the stored value or a list of stored values.
```]]

local triggers = {
	'^/set',
	'^/get'
}

local action = function(msg)

	local input = msg.text:input()
	database.setandget[msg.chat.id_str] = database.setandget[msg.chat.id_str] or {}

	if msg.text_lower:match('^/set') then

		if not input then
			sendMessage(msg.chat.id, doc, true, nil, true)
			return
		end

		local name = get_word(input:lower(), 1)
		local value = input:input()

		if not name or not value then
			sendMessage(msg.chat.id, doc, true, nil, true)
		elseif value == '--' or value == '—' then
			database.setandget[msg.chat.id_str][name] = nil
			sendMessage(msg.chat.id, 'That value has been deleted.')
		else
			database.setandget[msg.chat.id_str][name] = value
			sendMessage(msg.chat.id, '"' .. name .. '" has been set to "' .. value .. '".', true)
		end

	elseif msg.text_lower:match('^/get') then

		if not input then
			local output
			if table_size(database.setandget[msg.chat.id_str]) == 0 then
				output = 'No values have been stored here.'
			else
				output = '*List of stored values:*\n'
				for k,v in pairs(database.setandget[msg.chat.id_str]) do
					output = output .. '• ' .. k .. ': `' .. v .. '`\n'
				end
			end
			sendMessage(msg.chat.id, output, true, nil, true)
			return
		end

		local output
		if database.setandget[msg.chat.id_str][input:lower()] then
			output = '`' .. database.setandget[msg.chat.id_str][input:lower()] .. '`'
		else
			output = 'There is no value stored by that name.'
		end

		sendMessage(msg.chat.id, output, true, nil, true)

	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
