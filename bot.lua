local bot = {}

local instance = {}

local bindings = require('bindings') -- Load Telegram bindings.
local utilities = require('utilities') -- Load miscellaneous and cross-plugin functions.

bot.version = '3.5'

function bot:init() -- The function run when the bot is started or reloaded.

	self.config = require('config') -- Load configuration file.

	self.BASE_URL = 'https://api.telegram.org/bot' .. self.config.bot_api_key
	if self.config.bot_api_key == '' then
		error('You did not set your bot token in config.lua!')
	end

	-- Fetch bot information. Try until it succeeds.
	repeat self.info = bindings.getMe(self) until self.info
	self.info = self.info.result

	-- Load the "database"! ;)
	if not self.database then
		self.database = utilities.load_data(self.info.username..'.db')
	end

	self.plugins = {} -- Load plugins.
	for _,v in ipairs(self.config.plugins) do
		local p = require('plugins/'..v)
		table.insert(self.plugins, p)
		if p.init then p.init(self) end
	end

	print('@' .. self.info.username .. ', AKA ' .. self.info.first_name ..' ('..self.info.id..')')

	-- Generate a random seed and "pop" the first random number. :)
	math.randomseed(os.time())
	math.random()

	self.last_update = self.last_update or 0 -- Set loop variables: Update offset,
	self.last_cron = self.last_cron or os.date('%M') -- the time of the last cron job,
	self.is_started = true -- and whether or not the bot should be running.
	self.database.users = self.database.users or {} -- Table to cache userdata.
	self.database.users[tostring(self.info.id)] = self.info

	-- Migration code. Remove in 3.6.
	if self.database.lastfm then
		for k,v in pairs(self.database.lastfm) do
			if not self.database.users[k] then self.database.users[k] = {} end
			self.database.users[k].lastfm = v
		end
	end

	-- Migration code. Remove in 3.6.
	if self.database.nicknames then
		for k,v in pairs(self.database.nicknames) do
			if not self.database.users[k] then self.database.users[k] = {} end
			self.database.users[k].nickname = v
		end
	end

end

function bot:on_msg_receive(msg) -- The fn run whenever a message is received.

	-- Create a user entry if it does not exist.
	if not self.database.users[tostring(msg.from.id)] then
		self.database.users[tostring(msg.from.id)] = {}
	end
	-- Clear things that no longer exist.
	self.database.users[tostring(msg.from.id)].username = nil
	self.database.users[tostring(msg.from.id)].last_name = nil
	-- Wee.
	for k,v in pairs(msg.from) do
		self.database.users[tostring(msg.from.id)][k] = v
	end

	if msg.date < os.time() - 5 then return end -- Do not process old messages.
	if not msg.text then msg.text = msg.caption or '' end

	if msg.reply_to_message and msg.reply_to_message.caption then
		msg.reply_to_message.text = msg.reply_to_message.caption
	end -- If the replied-to message has a caption, make that its text.

	if msg.text:match('^/start .+') then
		msg.text = '/' .. utilities.input(msg.text)
	end

	for _,v in ipairs(self.plugins) do
		for _,w in pairs(v.triggers) do
			if string.match(msg.text:lower(), w) then
				-- a few shortcuts
				msg.chat.id_str = tostring(msg.chat.id)
				msg.from.id_str = tostring(msg.from.id)
				msg.text_lower = msg.text:lower()
				msg.from.name = utilities.build_name(msg.from.first_name, msg.from.last_name)

				local success, result = pcall(function()
					return v.action(self, msg)
				end)
				if not success then
					bindings.sendReply(self, msg, 'Sorry, an unexpected error occurred.')
					bindings.handle_exception(self, result, msg.from.id .. ': ' .. msg.text)
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

bot.init(instance) -- Actually start the script. Run the bot_init function.

while instance.is_started do -- Start a loop while the bot should be running.

	do
		local res = bindings.getUpdates(instance, instance.last_update+1) -- Get the latest updates!
		if res then
			for _,v in ipairs(res.result) do -- Go through every new message.
				instance.last_update = v.update_id
				bot.on_msg_receive(instance, v.message)
			end
		else
			print(instance.config.errors.connection)
		end
	end

	if instance.last_cron ~= os.date('%M') then -- Run cron jobs every minute.
		instance.last_cron = os.date('%M')
		utilities.save_data(instance.info.username..'.db', instance.database) -- Save the database.
		for i,v in ipairs(instance.plugins) do
			if v.cron then -- Call each plugin's cron function, if it has one.
				local res, err = pcall(function() v.cron() end)
				if not res then
					utilities.handle_exception(instance, err, 'CRON: ' .. i)
				end
			end
		end
	end

end

 -- Save the database before exiting.
utilities.save_data(instance.info.username..'.db', instance.database)
print('Halted.')
