local nick = {}

local utilities = require('otouto.utilities')

nick.command = 'nick <nickname>'

function nick:init(config)
	nick.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('nick', true).table
	nick.doc = [[```
]]..config.cmd_pat..[[nick <nickname>
Set your nickname. Use "]]..config.cmd_pat..[[nick --" to delete it.
```]]
end

function nick:action(msg, config)

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
	local input = utilities.input(msg.text)
	if not input then
		if self.database.users[target.id_str].nickname then
			output = target.name .. '\'s nickname is "' .. self.database.users[target.id_str].nickname .. '".'
		else
			output = target.name .. ' currently has no nickname.'
		end
	elseif utilities.utf8_len(input) > 32 then
		output = 'The character limit for nicknames is 32.'
	elseif input == '--' or input == utilities.char.em_dash then
		self.database.users[target.id_str].nickname = nil
		output = target.name .. '\'s nickname has been deleted.'
	else
		input = input:gsub('\n', ' ')
		self.database.users[target.id_str].nickname = input
		output = target.name .. '\'s nickname has been set to "' .. input .. '".'
	end

	utilities.send_reply(self, msg, output)

end

return nick
