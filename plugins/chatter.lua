 -- Put this absolutely at the end, even after greetings.lua.

local chatter = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')
local utilities = require('utilities')

function chatter:init()
	if not self.config.simsimi_key then
		print('Missing config value: simsimi_key.')
		print('chatter.lua will not be enabled.')
		return
	end

	chatter.triggers = {
		''
	}
end

chatter.base_url = 'http://%sapi.simsimi.com/request.p?key=%s&lc=%s&ft=1.0&text=%s'

function chatter:action(msg)

	if msg.text == '' then return true end

	if (
		not (
			msg.text_lower:match('^'..self.info.first_name:lower()..',')
			or msg.text_lower:match('^@'..self.info.username:lower()..',')
			or msg.from.id == msg.chat.id
			--Uncomment the following line for Al Gore-like conversation.
			--or (msg.reply_to_message and msg.reply_to_message.from.id == self.info.id)
		)
		or msg.text:match('^/')
		or msg.text == ''
	) then
		return true
	end

	bindings.sendChatAction(self, { action = 'typing' } )

	local input = msg.text_lower:gsub(self.info.first_name, 'simsimi')
	input = input:gsub('@'..self.info.username, 'simsimi')

	local sandbox = self.config.simsimi_trial and 'sandbox.' or ''

	local url = chatter.base_url:format(sandbox, self.config.simsimi_key, self.config.lang, URL.escape(input))

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		utilities.send_message(self, msg.chat.id, self.config.errors.chatter_connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.response or jdat.response:match('^I HAVE NO RESPONSE.') then
		utilities.send_message(self, msg.chat.id, self.config.errors.chatter_response)
		return
	end
	local output = jdat.response

	-- Clean up the response here.
	output = utilities.trim(output)
	-- Simsimi will often refer to itself. Replace "simsimi" with the bot name.
	output = output:gsub('%aimi?%aimi?', self.info.first_name)
	-- Self-explanatory.
	output = output:gsub('USER', msg.from.first_name)
	-- Capitalize the first letter.
	output = output:gsub('^%l', string.upper)
	-- Add a period if there is no punctuation.
	output = output:gsub('%P$', '%1.')

	utilities.send_message(self, msg.chat.id, output)

end

return chatter
