local me = {}

local utilities = require('utilities')

function me:init()
	me.triggers = utilities.triggers(self.info.username):t('me', true).table
end

function me:action(msg)

	local target = self.database.users[msg.from.id_str]

	if msg.from.id == self.config.admin and (msg.reply_to_message or utilities.input(msg.text)) then
		target = utilities.user_from_message(self, msg, true)
		if target.err then
			utilities.send_reply(self, msg, target.err)
			return
		end
	end

	local output = ''
	for k,v in pairs(target) do
		output = output .. '*' .. k .. ':* `' .. tostring(v) .. '`\n'
	end
	utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return me
