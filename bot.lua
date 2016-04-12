HTTP = require('socket.http')
HTTPS = require('ssl.https')
URL = require('socket.url')
JSON = require('cjson')

version = '3.6'

bot_init = function() -- The function run when the bot is started or reloaded.

	config = dofile('config.lua') -- Load configuration file.
	dofile('bindings.lua') -- Load Telegram bindings.
	dofile('utilities.lua') -- Load miscellaneous and cross-plugin functions.

	-- Fetch bot information. Try until it succeeds.
	repeat bot = getMe() until bot
	bot = bot.result

	-- Load the "database"! ;)
	if not database then
		database = load_data(bot.username..'.db')
	end

	plugins = {} -- Load plugins.
	for i,v in ipairs(config.plugins) do
		local p = dofile('plugins/'..v)
		table.insert(plugins, p)
	end

	print('@' .. bot.username .. ', AKA ' .. bot.first_name ..' ('..bot.id..')')

	-- Generate a random seed and "pop" the first random number. :)
	math.randomseed(os.time())
	math.random()

	last_update = last_update or 0 -- Set loop variables: Update offset,
	last_cron = last_cron or os.date('%M') -- the time of the last cron job,
	is_started = true -- and whether or not the bot should be running.
	database.users = database.users or {} -- Table to cache userdata.
	database.users[tostring(bot.id)] = bot

end

on_msg_receive = function(msg) -- The fn run whenever a message is received.

	-- Create a user entry if it does not exist.
	if not database.users[tostring(msg.from.id)] then
		database.users[tostring(msg.from.id)] = {}
	end
	-- Clear things that no longer exist.
	database.users[tostring(msg.from.id)].username = nil
	database.users[tostring(msg.from.id)].last_name = nil
	-- Wee.
	for k,v in pairs(msg.from) do
		database.users[tostring(msg.from.id)][k] = v
	end

	if msg.date < os.time() - 5 then return end -- Do not process old messages.

	msg = enrich_message(msg)

	if msg.text:match('^/start .+') then
		msg.text = '/' .. msg.text:input()
		msg.text_lower = msg.text:lower()
	end

	for i,v in ipairs(plugins) do
		for k,w in pairs(v.triggers) do
			if string.match(msg.text:lower(), w) then
				local success, result = pcall(function()
					return v.action(msg)
				end)
				if not success then
					sendReply(msg, 'Sorry, an unexpected error occurred.')
					handle_exception(result, msg.from.id .. ': ' .. msg.text)
					return
				end
				-- If the action returns a table, make that table msg.
				if type(result) == 'table' then
					msg = result
				-- If the action returns true, don't stop.
				elseif result ~= true then
					return
				end
			end
		end
	end

end

bot_init() -- Actually start the script. Run the bot_init function.

while is_started do -- Start a loop while the bot should be running.

	local res = getUpdates(last_update+1) -- Get the latest updates!
	if res then
		for i,v in ipairs(res.result) do -- Go through every new message.
			last_update = v.update_id
			on_msg_receive(v.message)
		end
	else
		print(config.errors.connection)
	end

	if last_cron ~= os.date('%M') then -- Run cron jobs every minute.
		last_cron = os.date('%M')
		save_data(bot.username..'.db', database) -- Save the database.
		for i,v in ipairs(plugins) do
			if v.cron then -- Call each plugin's cron function, if it has one.
				local res, err = pcall(function() v.cron() end)
				if not res then
					handle_exception(err, 'CRON: ' .. i)
				end
			end
		end
	end

end

 -- Save the database before exiting.
save_data(bot.username..'.db', database)
print('Halted.')
