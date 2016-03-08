if not database.nicknames then
	database.nicknames = {}
end

local command = 'nick <nickname>'
local doc = [[```
/nick <nickname>
Set your nickname. Use "/nick --" to delete it.
```]]

local triggers = {
	'^/nick[@'..bot.username..']*'
}

local action = function(msg)

	local target = msg.from

	if msg.from.id == config.admin and msg.reply_to_message then
		target = msg.reply_to_message.from
		target.id_str = tostring(target.id)
		target.name = target.first_name
		if target.last_name then
			target.name = target.first_name .. ' ' .. target.last_name
		end
	end

	local output
	local input = msg.text:input()
	if not input then
		if database.nicknames[target.id_str] then
			output = target.name .. '\'s nickname is "' .. database.nicknames[target.id_str] .. '".'
		else
			output = target.name .. ' currently has no nickname.'
		end
	elseif string.len(input) > 32 then
		output = 'The character limit for nicknames is 32.'
	elseif input == '--' or input == '—' then
		database.nicknames[target.id_str] = nil
		output = target.name .. '\'s nickname has been deleted.'
	else
		database.nicknames[target.id_str] = input
		output = target.name .. '\'s nickname has been set to "' .. input .. '".'
	end

	sendReply(msg, output)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
