local luarun = {}

local utilities = require('utilities')
local URL = require('socket.url')
local JSON = require('dkjson')

function luarun:init()
	luarun.triggers = utilities.triggers(self.info.username):t('lua', true):t('return', true).table
end

function luarun:action(msg)

	if msg.from.id ~= self.config.admin then
		return true
	end

	local input = utilities.input(msg.text)
	if not input then
		utilities.send_reply(self, msg, 'Please enter a string to load.')
		return
	end

	if msg.text_lower:match('^/return') then
		input = 'return ' .. input
	end

	local output = loadstring( [[
		local bot = require('bot')
		local bindings = require('bindings')
		local utilities = require('utilities')
		local JSON = require('dkjson')
		local URL = require('socket.url')
		local HTTP = require('socket.http')
		local HTTPS = require('ssl.https')
		return function (self, msg) ]] .. input .. [[ end
	]] )()(self, msg)
	if output == nil then
		output = 'Done!'
	else
		if type(output) == 'table' then
			local s = JSON.encode(output, {indent=true})
			if URL.escape(s):len() < 4000 then
				output = s
			end
		end
		output = '```\n' .. tostring(output) .. '\n```'
	end
	utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)

end

return luarun

