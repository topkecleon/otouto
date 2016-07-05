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

	local id_str, name

	if msg.from.id == config.admin and msg.reply_to_message then
		id_str = tostring(msg.reply_to_message.from.id)
		name = utilities.build_name(msg.reply_to_message.from.first_name, msg.reply_to_message.from.last_name)
	else
		id_str = tostring(msg.from.id)
		name = utilities.build_name(msg.from.first_name, msg.from.last_name)
	end

	self.database.userdata[id_str] = self.database.userdata[id_str] or {}

	local output
	local input = utilities.input(msg.text)
	if not input then
		if self.database.userdata[id_str].nickname then
			output = name .. '\'s nickname is "' .. self.database.userdata[id_str].nickname .. '".'
		else
			output = name .. ' currently has no nickname.'
		end
	elseif utilities.utf8_len(input) > 32 then
		output = 'The character limit for nicknames is 32.'
	elseif input == '--' or input == utilities.char.em_dash then
		self.database.userdata[id_str].nickname = nil
		output = name .. '\'s nickname has been deleted.'
	else
		input = input:gsub('\n', ' ')
		self.database.userdata[id_str].nickname = input
		output = name .. '\'s nickname has been set to "' .. input .. '".'
	end

	utilities.send_reply(self, msg, output)

end

return nick
