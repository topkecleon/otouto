-- bot.lua
-- Run this!

HTTP = require('socket.http')
HTTPS = require('ssl.https')
JSON = require('dkjson')
URL = require('socket.url')

VERSION = 2.1

function on_msg_receive(msg)

	if msg.date < os.time() - 5 then return end -- don't react to old messages
	if not msg.text then return end -- don't react to media messages
	if msg.forward_from then return end -- don't react to forwarded messages

	local lower = string.lower(msg.text)
	for i,v in pairs(plugins) do
		for j,w in pairs(v.triggers) do
			if string.match(lower, w) then
				send_chat_action(msg.chat.id, 'typing')
				v.action(msg)
			end
		end
	end
end

function bot_init()

	print('\nLoading configuration...')

	local jstr = io.open('config.json')
	local jstr = jstr:read('*all')
	config = JSON.decode(jstr)
	print(#config.plugins .. ' plugins enabled.')

	require('bindings')
	require('utilities')

	print('\nFetching bot information...')

	bot = get_me().result
	for k,v in pairs(bot) do
		print('',k,v)
	end

	print('Bot information retrieved!\n')
	print('Loading plugins...')

	plugins = {}
	for i,v in ipairs(config.plugins) do
		print('',v)
		local p = loadfile('plugins/'..v)()
		table.insert(plugins, p)
	end

	print('Done! Plugins loaded: ' .. #plugins .. '\n')
	print('Generating help message...')

	help_message = ''
	for i,v in ipairs(plugins) do
		if v.doc then
			local a = string.sub(v.doc, 1, string.find(v.doc, '\n')-1)
			print(a)
			help_message = help_message .. ' - ' .. a .. '\n'
		end
	end

	print('Help message generated!\n')

	is_started = true

end

bot_init()
reminders = {}
last_update = 0
while is_started == true do

	for i,v in ipairs(get_updates(last_update).result) do
		if v.update_id > last_update then
			last_update = v.update_id
			on_msg_receive(v.message)
		end
	end

	for i,v in pairs(reminders) do
		if os.time() > v.alarm then
			send_message(v.chat_id, 'Reminder: '..v.text)
			table.remove(reminders, i)
		end
	end

end
