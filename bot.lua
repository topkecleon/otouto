HTTP = require('socket.http')
HTTPS= require('ssl.https')
URL  = require('socket.url')
JSON = require('dkjson')

VERSION = '2.11'

function on_msg_receive(msg)

	if blacklist[tostring(msg.from.id)] then return end
	if floodcontrol[-msg.chat.id] then -- This stuff is useful for the moderation plugin to not be completely unusable when floodcontrol is activated.
		msg.flood = msg.chat.id
		msg.chat.id = msg.from.id
	end

	if msg.new_chat_participant and msg.new_chat_participant.id == bot.id then
		msg.text = '/about'
	end -- If bot is added to a group, send the about message.

	if msg.date < os.time() - 10 then return end -- don't react to old messages
	if not msg.text then return end -- don't react to media messages
	if msg.forward_from then return end -- don't react to forwarded messages

	local lower = string.lower(msg.text)
	for i,v in pairs(plugins) do
		for j,w in pairs(v.triggers) do
			if string.match(lower, w) then
				if v.typing then
					send_chat_action(msg.chat.id, 'typing')
				end
				local a,b = pcall(function() -- Janky error handling
					v.action(msg)
				end)
				if not a then
					print('',msg.text,'\n',b) -- debugging
					send_msg(msg, b)
				end
			end
		end
	end
end

function bot_init()

	print('Loading configuration...')

	config = dofile('config.lua')
	require('bindings')
	require('utilities')
	blacklist = load_data('blacklist.json')

	print('Fetching bot information...')

	bot = get_me()
	while bot == false do
		print('Failure fetching bot information. Trying again...')
		bot = get_me()
	end
	bot = bot.result

	print('Loading plugins...')

	plugins = {}
	for i,v in ipairs(config.plugins) do
		local p = dofile('plugins/'..v)
		table.insert(plugins, p)
	end

	print('Plugins loaded: ' .. #plugins .. '. Generating help message...')

	help_message = ''
	for i,v in ipairs(plugins) do
		if v.doc then
			local a = string.sub(v.doc, 1, string.find(v.doc, '\n')-1)
			help_message = help_message .. ' - ' .. a .. '\n'
		end
	end

	print('@'.. bot.username ..', AKA '.. bot.first_name ..' ('.. bot.id ..')')

	is_started = true

end

bot_init()
last_update = 0
last_cron = os.time()

while is_started do

	local res = get_updates(last_update+1)
	if not res then
		print('Error getting updates.')
	else
		for i,v in ipairs(res.result) do
			if v.update_id > last_update then
				last_update = v.update_id
				on_msg_receive(v.message)
			end
		end
	end

	-- cron-like thing
	-- run PLUGIN.cron() every five seconds
	if last_cron < os.time() - 5 then
		for k,v in pairs(plugins) do
			if v.cron then
				a,b = pcall(function() v.cron() end)
				if not a then print(b) end
			end
		end
		last_cron = os.time()
	end

end

print('Halted.')
