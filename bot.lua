local bot = {}

-- Requires are moved to init to allow for reloads.
local bindings -- Load Telegram bindings.
local utilities -- Load miscellaneous and cross-plugin functions.

bot.version = '3.8'

function bot:init() -- The function run when the bot is started or reloaded.

	bindings = require('bindings')
	utilities = require('utilities')

	self.config = require('config') -- Load configuration file.

	assert(
		self.config.bot_api_key and self.config.bot_api_key ~= '',
		'You did not set your bot token in config.lua!'
	)
	self.BASE_URL = 'https://api.telegram.org/bot' .. self.config.bot_api_key .. '/'

	-- Fetch bot information. Try until it succeeds.
	repeat
		print('Fetching bot information...')
		self.info = bindings.getMe(self)
	until self.info
	self.info = self.info.result

	-- Load the "database"! ;)
	if not self.database then
		self.database = utilities.load_data(self.info.username..'.db')
	end

	self.plugins = {} -- Load plugins.
	for _,v in ipairs(self.config.plugins) do
		local p = require('plugins.'..v)
		table.insert(self.plugins, p)
		if p.init then p.init(self) end
	end

	print('@' .. self.info.username .. ', AKA ' .. self.info.first_name ..' ('..self.info.id..')')

	self.last_update = self.last_update or 0 -- Set loop variables: Update offset,
	self.last_cron = self.last_cron or os.date('%M') -- the time of the last cron job,
	self.is_started = true -- and whether or not the bot should be running.
	self.database.users = self.database.users or {} -- Table to cache userdata.
	self.database.users[tostring(self.info.id)] = self.info

end

function bot:on_msg_receive(msg) -- The fn run whenever a message is received.

	-- Cache user info for those involved.
	utilities.create_user_entry(self, msg.from)
	if msg.forward_from and msg.forward_from.id ~= msg.from.id then
		utilities.create_user_entry(self, msg.forward_from)
	elseif msg.reply_to_message and msg.reply_to_message.from.id ~= msg.from.id then
		utilities.create_user_entry(self, msg.reply_to_message.from)
	end

	if msg.date < os.time() - 5 then return end -- Do not process old messages.

	msg = utilities.enrich_message(msg)

	if msg.text:match('^/start .+') then
		msg.text = '/' .. utilities.input(msg.text)
		msg.text_lower = msg.text:lower()
	end

	for _,v in ipairs(self.plugins) do
		for _,w in pairs(v.triggers) do
			if string.match(msg.text:lower(), w) then
				local success, result = pcall(function()
					return v.action(self, msg)
				end)
				if not success then
					utilities.send_reply(self, msg, 'Sorry, an unexpected error occurred.')
					utilities.handle_exception(self, result, msg.from.id .. ': ' .. msg.text)
					return
				end
				-- If the action returns a table, make that table the new msg.
				if type(result) == 'table' then
					msg = result
				-- If the action returns true, continue.
				elseif result ~= true then
					return
				end
			end
		end
	end

end

function bot:run()
	bot.init(self) -- Actually start the script. Run the bot_init function.

	while self.is_started do -- Start a loop while the bot should be running.

		local res = bindings.getUpdates(self, { timeout=20, offset = self.last_update+1 } )
		if res then
			for _,v in ipairs(res.result) do -- Go through every new message.
				self.last_update = v.update_id
				if v.message then
					bot.on_msg_receive(self, v.message)
				end
			end
		else
			print('Connection error fetching updates.')
		end

		if self.last_cron ~= os.date('%M') then -- Run cron jobs every minute.
			self.last_cron = os.date('%M')
			utilities.save_data(self.info.username..'.db', self.database) -- Save the database.
			for i,v in ipairs(self.plugins) do
				if v.cron then -- Call each plugin's cron function, if it has one.
					local result, err = pcall(function() v.cron(self) end)
					if not result then
						utilities.handle_exception(self, err, 'CRON: ' .. i)
					end
				end
			end
		end

	end

	-- Save the database before exiting.
	utilities.save_data(self.info.username..'.db', self.database)
	print('Halted.')
end

return bot
