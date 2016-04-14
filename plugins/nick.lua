local nick = {}

local bindings = require('bindings')
local utilities = require('utilities')

nick.command = 'nick <nickname>'
nick.doc = [[```
/nick <nickname>
Set your nickname. Use "/nick --" to delete it.
```]]

function nick:init()
	nick.triggers = utilities.triggers(self.info.username):t('nick', true).table
end

function nick:action(msg)

	local target = msg.from

	if msg.from.id == self.config.admin and msg.reply_to_message then
		target = msg.reply_to_message.from
		target.id_str = tostring(target.id)
		target.name = target.first_name
		if target.last_name then
			target.name = target.first_name .. ' ' .. target.last_name
		end
	end

	local output
	local input = utilities.input(msg.text)
	if not input then
		if self.database.users[target.id_str].nickname then
			output = target.name .. '\'s nickname is "' .. self.database.users[target.id_str].nickname .. '".'
		else
			output = target.name .. ' currently has no nickname.'
		end
	elseif string.len(input) > 32 then
		output = 'The character limit for nicknames is 32.'
	elseif input == '--' or input == '—' then
		self.database.users[target.id_str].nickname = nil
		output = target.name .. '\'s nickname has been deleted.'
	else
		self.database.users[target.id_str].nickname = input
		output = target.name .. '\'s nickname has been set to "' .. input .. '".'
	end

	bindings.sendReply(self, msg, output)

end

return nick
