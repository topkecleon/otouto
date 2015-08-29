HTTP = require('socket.http')
HTTPS= require('ssl.https')
URL  = require('socket.url')
JSON = require('dkjson')

VERSION = 2.9

function on_msg_receive(msg)

	if blacklist[tostring(msg.from.id)] then return end
	if floodcontrol[-msg.chat.id] then return end

	msg = process_msg(msg)

	if msg.date < os.time() - 5 then return end -- don't react to old messages
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
					print('',msg.text,'\n',b) -- For debugging purposes.
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

	bot = get_me().result
	if not bot then
		error('Failure fetching bot information.')
	end

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

function process_msg(msg)

	if msg.text and msg.reply_to_message and string.sub(msg.text, 1, 1) ~= '/' and msg.reply_to_message.from.id == bot.id then
		msg.text = bot.first_name .. ', ' .. msg.text
	end

	if msg.new_chat_participant and msg.new_chat_participant.id ~= bot.id then
		if msg.from.id == 100547061 then return msg end
		msg.text = 'hi '..bot.first_name
		msg.from = msg.new_chat_participant
	end

	if msg.left_chat_participant and msg.left_chat_participant.id ~= bot.id then
		if msg.from.id == 100547061 then return msg end
		msg.text = 'bye '..bot.first_name
		msg.from = msg.left_chat_participant
	end

	if msg.new_chat_participant and msg.new_chat_participant.id == bot.id then
		msg.text = '/about'
	end

	return msg

end

bot_init()
last_update = 0

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
	if os.date('%S', os.time()) % 5 == 0 then -- Only check every five seconds.
		for k,v in pairs(plugins) do
			if v.cron then
				pcall(function() v.cron() end)
			end
		end
	end

end

print('Halted.')
