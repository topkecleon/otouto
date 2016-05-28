local cats = {}

local HTTP = require('socket.http')
local bindings = require('bindings')
local utilities = require('utilities')

function cats:init()
	if not self.config.thecatapi_key then
		print('Missing config value: thecatapi_key.')
		print('cats.lua will be enabled, but there are more features with a key.')
	end

	cats.triggers = utilities.triggers(self.info.username):t('cat').table
end

cats.command = 'cat'
cats.doc = '`Returns a cat!`'

function cats:action(msg)

	local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg'
	if self.config.thecatapi_key then
		url = url .. '&api_key=' .. self.config.thecatapi_key
	end

	local str, res = HTTP.request(url)
	if res ~= 200 then
		bindings.sendReply(msg, self.config.errors.connection)
		return
	end

	str = str:match('<img src="(.-)">')
	local output = '[Meow!]('..str..')'

	bindings.sendMessage(self, msg.chat.id, output, false, nil, true)

end

return cats
