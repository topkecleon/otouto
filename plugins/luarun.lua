local luarun = {}

local bindings = require('bindings')
local utilities = require('utilities')

function luarun:init()
	luarun.triggers = utilities.triggers(self.info.username):t('lua', true).table
end

function luarun:action(msg)

	if msg.from.id ~= self.config.admin then
		return
	end

	local input = utilities.input(msg.text)
	if not input then
		bindings.sendReply(self, msg, 'Please enter a string to load.')
		return
	end

	local output = loadstring('local bindings = require(\'bindings\'); local utilities = require(\'utilities\'); return function (instance, msg) '..input..' end')()(self, msg)
	if output == nil then
		output = 'Done!'
	elseif type(output) == 'table' then
		output = 'Done! Table returned.'
	else
		output = '```\n' .. tostring(output) .. '\n```'
	end
	bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)

end

return luarun

