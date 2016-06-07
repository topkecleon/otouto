local luarun = {}

local utilities = require('otouto.utilities')
local URL = require('socket.url')
local JSON = require('dkjson')

function luarun:init(config)
	luarun.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('lua', true):t('return', true).table
end

function luarun:action(msg, config)

	if msg.from.id ~= config.admin then
		return true
	end

	local input = utilities.input(msg.text)
	if not input then
		utilities.send_reply(self, msg, 'Please enter a string to load.')
		return
	end

	if msg.text_lower:match('^'..config.cmd_pat..'return') then
		input = 'return ' .. input
	end

	local output = loadstring( [[
		local bot = require('otouto.bot')
		local bindings = require('otouto.bindings')
		local utilities = require('otouto.utilities')
		local JSON = require('dkjson')
		local URL = require('socket.url')
		local HTTP = require('socket.http')
		local HTTPS = require('ssl.https')
		return function (self, msg, config) ]] .. input .. [[ end
	]] )()(self, msg, config)
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

