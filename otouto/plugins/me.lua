local me = {}

local utilities = require('otouto.utilities')

function me:init(config)
	me.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('me', true).table
	me.command = 'me'
	me.doc = '`Returns userdata stored by the bot.`'
end

function me:action(msg, config)

	local userdata = self.database.userdata[tostring(msg.from.id)] or {}

	if msg.from.id == config.admin then
		if msg.reply_to_message then
			userdata = self.database.userdata[tostring(msg.reply_to_message.from.id)]
		else
			local input = utilities.input(msg.text)
			if input then
				local user_id = utilities.id_from_username(self, input)
				if user_id then
					userdata = self.database.userdata[tostring(user_id)] or {}
				end
			end
		end
	end

	local output = ''
	for k,v in pairs(userdata) do
		output = output .. '*' .. k .. ':* `' .. tostring(v) .. '`\n'
	end

	if output == '' then
		output = 'There is no data stored for this user.'
	end

	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return me
