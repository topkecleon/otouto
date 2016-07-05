local bot = {}

-- Requires are moved to init to allow for reloads.
local bindings -- Load Telegram bindings.
local utilities -- Load miscellaneous and cross-plugin functions.

bot.version = '3.11'

function bot:init(config) -- The function run when the bot is started or reloaded.

	bindings = require('otouto.bindings')
	utilities = require('otouto.utilities')

	assert(
		config.bot_api_key and config.bot_api_key ~= '',
		'You did not set your bot token in the config!'
	)
	self.BASE_URL = 'https://api.telegram.org/bot' .. config.bot_api_key .. '/'

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

	-- MIGRATION CODE 3.10 -> 3.11
	if self.database.users and self.database.version ~= '3.11' then
		self.database.userdata = {}
		for id, user in pairs(self.database.users) do
			self.database.userdata[id] = {}
			self.database.userdata[id].nickname = user.nickname
			self.database.userdata[id].lastfm = user.lastfm
			user.nickname = nil
			user.lastfm = nil
			user.id_str = nil
			user.name = nil
		end
	end
	-- END MIGRATION CODE

	-- Table to cache user info (usernames, IDs, etc).
	self.database.users = self.database.users or {}
	-- Table to store userdata (nicknames, lastfm usernames, etc).
	self.database.userdata = self.database.userdata or {}
	-- Save the bot's version in the database to make migration simpler.
	self.database.version = bot.version
	-- Add updated bot info to the user info cache.
	self.database.users[tostring(self.info.id)] = self.info

	self.plugins = {} -- Load plugins.
	for _,v in ipairs(config.plugins) do
		local p = require('otouto.plugins.'..v)
		table.insert(self.plugins, p)
		if p.init then p.init(self, config) end
	end

	print('@' .. self.info.username .. ', AKA ' .. self.info.first_name ..' ('..self.info.id..')')

	self.last_update = self.last_update or 0 -- Set loop variables: Update offset,
	self.last_cron = self.last_cron or os.date('%M') -- the time of the last cron job,
	self.last_database_save = self.last_database_save or os.date('%H') -- the time of the last database save,
	self.is_started = true -- and whether or not the bot should be running.

end

function bot:on_msg_receive(msg, config) -- The fn run whenever a message is received.

	if msg.date < os.time() - 5 then return end -- Do not process old messages.

	-- Cache user info for those involved.
	self.database.users[tostring(msg.from.id)] = msg.from
	if msg.reply_to_message then
		self.database.users[tostring(msg.reply_to_message.from.id)] = msg.reply_to_message.from
	elseif msg.forward_from then
		self.database.users[tostring(msg.forward_from.id)] = msg.forward_from
	elseif msg.new_chat_member then
		self.database.users[tostring(msg.new_chat_member.id)] = msg.new_chat_member
	elseif msg.left_chat_member then
		self.database.users[tostring(msg.left_chat_member.id)] = msg.left_chat_member
	end

	msg.text = msg.text or msg.caption or ''
	msg.text_lower = msg.text:lower()

	-- Support deep linking.
	if msg.text:match('^'..config.cmd_pat..'start .+') then
		msg.text = config.cmd_pat .. utilities.input(msg.text)
		msg.text_lower = msg.text:lower()
	end

	for _, plugin in ipairs(self.plugins) do
		for _, trigger in pairs(plugin.triggers or {}) do
			if string.match(msg.text_lower, trigger) then
				local success, result = pcall(function()
					return plugin.action(self, msg, config)
				end)
				if not success then
					-- If the plugin has an error message, send it. If it does
					-- not, use the generic one specified in config. If it's set
					-- to false, do nothing.
					if plugin.error then
						utilities.send_reply(self, msg, plugin.error)
					elseif plugin.error == nil then
						utilities.send_reply(self, msg, config.errors.generic)
					end
					utilities.handle_exception(self, result, msg.from.id .. ': ' .. msg.text, config)
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

function bot:run(config)
	bot.init(self, config) -- Actually start the script.

	while self.is_started do -- Start a loop while the bot should be running.

		local res = bindings.getUpdates(self, { timeout=20, offset = self.last_update+1 } )
		if res then
			for _,v in ipairs(res.result) do -- Go through every new message.
				self.last_update = v.update_id
				if v.message then
					bot.on_msg_receive(self, v.message, config)
				end
			end
		else
			print('Connection error while fetching updates.')
		end

		if self.last_cron ~= os.date('%M') then -- Run cron jobs every minute.
			self.last_cron = os.date('%M')
			for i,v in ipairs(self.plugins) do
				if v.cron then -- Call each plugin's cron function, if it has one.
					local result, err = pcall(function() v.cron(self, config) end)
					if not result then
						utilities.handle_exception(self, err, 'CRON: ' .. i, config)
					end
				end
			end
		end

		if self.last_database_save ~= os.date('%H') then
			utilities.save_data(self.info.username..'.db', self.database) -- Save the database.
			self.last_database_save = os.date('%H')
		end

	end

	-- Save the database before exiting.
	utilities.save_data(self.info.username..'.db', self.database)
	print('Halted.')
end

return bot
