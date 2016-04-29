 -- Put this absolutely at the end, even after greetings.lua.

local chatter = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')

function chatter:init()
	if not self.config.simsimi_key then
		print('Missing config value: simsimi_key.')
		print('chatter.lua will not be enabled.')
		return
	end

	chatter.triggers = {
		'',
		'^' .. self.info.first_name .. ',',
		'^@' .. self.info.username .. ','
	}
end

function chatter:action(msg)

	if msg.text == '' then return end

	-- This is awkward, but if you have a better way, please share.
	if msg.text_lower:match('^' .. self.info.first_name .. ',')
	or msg.text_lower:match('^@' .. self.info.username .. ',') then
	elseif msg.text:match('^/') then
		return true
	-- Uncomment the following line for Al Gore-like reply chatter.
	-- elseif msg.reply_to_message and msg.reply_to_message.from.id == bot.id then
	elseif msg.from.id == msg.chat.id then
	else
		return true
	end

	bindings.sendChatAction(self, msg.chat.id, 'typing')

	local input = msg.text_lower
	input = input:gsub(self.info.first_name, 'simsimi')
	input = input:gsub('@'..self.info.username, 'simsimi')

	local sandbox
	if self.config.simsimi_trial then
		sandbox = 'sandbox.'
	else
		sandbox = '' -- NO Sandbox
	end

	local url = 'http://' ..sandbox.. 'api.simsimi.com/request.p?key=' ..self.config.simsimi_key.. '&lc=' ..self.config.lang.. '&ft=1.0&text=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		bindings.sendMessage(self, msg.chat.id, self.config.errors.chatter_connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.response then
		bindings.sendMessage(self, msg.chat.id, self.config.errors.chatter_response)
		return
	end
	local output = jdat.response

	if output:match('^I HAVE NO RESPONSE.') then
		output = self.config.errors.chatter_response
	end

	-- Let's clean up the response a little. Capitalization & punctuation.
	local filter = {
		['%aimi?%aimi?'] = self.info.first_name,
		['^%s*(.-)%s*$'] = '%1',
		['^%l'] = string.upper,
		['USER'] = msg.from.first_name
	}

	for k,v in pairs(filter) do
		output = string.gsub(output, k, v)
	end

	if not string.match(output, '%p$') then
		output = output .. '.'
	end

	bindings.sendMessage(self, msg.chat.id, output)

end

return chatter
