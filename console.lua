JSON = require('dkjson')
URL  = require('socket.url')
HTTP = require('socket.http')
HTTPS= require('ssl.https')

require('utilities')
config = require('config')
require('bindings')

data = load_data('moderation.json')

print('Fetching bot data...')
bot = get_me().result
if not bot then
	error('Failure fetching bot information.')
end
for k,v in pairs(bot) do
	print('',k,v)
end

print('Loading plugins...')
plugins = {}
for i,v in ipairs(config.plugins) do
	local p = dofile('plugins/'..v)
	table.insert(plugins, p)
end

clear = function()
	for i = 1, 100 do
		print('\n')
	end
end

print('You are now in the otouto console!')
