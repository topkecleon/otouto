local bot = {}
local bindings -- Bot API bindings.
local utilities -- Miscellaneous and shared plugins.

bot.version = '3.13'

 -- Function to be run on start and reload.
function bot:init(config)

	bindings = require('otouto.bindings')
	utilities = require('otouto.utilities')

	assert(
		config.bot_api_key,
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
	self.database_name = config.database_name or self.info.username .. '.db'
	if not self.database then
		self.database = utilities.load_data(self.database_name)
	end

	-- Migration code 1.12 -> 1.13
	-- Back to administration global ban list; copy over current blacklist.
	if self.database.version ~= '3.13' then
		if self.database.administration then
			self.database.administration.globalbans = self.database.administration.globalbans or self.database.blacklist or {}
			utilities.save_data(self.database_name, self.database)
			self.database = utilities.load_data(self.database_name)
		end
	end
	-- End migration code.

	-- Table to cache user info (usernames, IDs, etc).
	self.database.users = self.database.users or {}
	-- Table to store userdata (nicknames, lastfm usernames, etc).
	self.database.userdata = self.database.userdata or {}
	-- Table to store the IDs of blacklisted users.
	self.database.blacklist = self.database.blacklist or {}
	-- Save the bot's version in the database to make migration simpler.
	self.database.version = bot.version
	-- Add updated bot info to the user info cache.
	self.database.users[tostring(self.info.id)] = self.info

	-- All plugins go into self.plugins. Plugins which accept forwarded messages
	-- and messages from blacklisted users also go into self.panoptic_plugins.
	self.plugins = {}
	self.panoptic_plugins = {}
	local t = {} -- Petty pseudo-optimization.
	for _, pname in ipairs(config.plugins) do
		local plugin = require('otouto.plugins.'..pname)
		table.insert(self.plugins, plugin)
		if plugin.init then plugin.init(self, config) end
		if plugin.panoptic then table.insert(self.panoptic_plugins, plugin) end
		if plugin.doc then plugin.doc = '```\n'..plugin.doc..'\n```' end
		if not plugin.triggers then plugin.triggers = t end
	end

	print('@' .. self.info.username .. ', AKA ' .. self.info.first_name ..' ('..self.info.id..')')

	-- Set loop variables.
	self.last_update = self.last_update or 0 -- Update offset.
	self.last_cron = self.last_cron or os.date('%M') -- Last cron job.
	self.last_database_save = self.last_database_save or os.date('%H') -- Last db save.
	self.is_started = true

end

 -- Function to be run on each new message.
function bot:on_msg_receive(msg, config)

	-- Do not process old messages.
	if msg.date < os.time() - 5 then return end

	-- plugint is the array of plugins we'll check the message against.
	-- If the message is forwarded or from a blacklisted user, the bot will only
	-- check against panoptic plugins.
	local plugint = self.plugins
	local from_id_str = tostring(msg.from.id)

	-- Cache user info for those involved.
	self.database.users[from_id_str] = msg.from
	if msg.reply_to_message then
		self.database.users[tostring(msg.reply_to_message.from.id)] = msg.reply_to_message.from
	elseif msg.forward_from then
		-- Forwards only go to panoptic plugins.
		plugint = self.panoptic_plugins
		self.database.users[tostring(msg.forward_from.id)] = msg.forward_from
	elseif msg.new_chat_member then
		self.database.users[tostring(msg.new_chat_member.id)] = msg.new_chat_member
	elseif msg.left_chat_member then
		self.database.users[tostring(msg.left_chat_member.id)] = msg.left_chat_member
	end

	-- Messages from blacklisted users only go to panoptic plugins.
	if self.database.blacklist[from_id_str] then
		plugint = self.panoptic_plugins
	end

	-- If no text, use captions.
	msg.text = msg.text or msg.caption or ''
	msg.text_lower = msg.text:lower()
	if msg.reply_to_message then
		msg.reply_to_message.text = msg.reply_to_message.text or msg.reply_to_message.caption or ''
	end

	-- Support deep linking.
	if msg.text:match('^'..config.cmd_pat..'start .+') then
		msg.text = config.cmd_pat .. utilities.input(msg.text)
		msg.text_lower = msg.text:lower()
	end

	-- If the message is forwarded or comes from a blacklisted yser,

	-- Do the thing.
	for _, plugin in ipairs(plugint) do
		for _, trigger in ipairs(plugin.triggers) do
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
					msg = nil
					return
				-- Continue if the return value is true.
				elseif result ~= true then
					msg = nil
					return
				end
			end
		end
	end
	msg = nil

end

 -- main
function bot:run(config)
	bot.init(self, config)
	while self.is_started do
		-- Update loop.
		local res = bindings.getUpdates(self, { timeout = 20, offset = self.last_update + 1 } )
		if res then
			-- Iterate over every new message.
			for _,v in ipairs(res.result) do
				self.last_update = v.update_id
				if v.message then
					bot.on_msg_receive(self, v.message, config)
				end
			end
		else
			print('Connection error while fetching updates.')
		end

		-- Run cron jobs every minute.
		if self.last_cron ~= os.date('%M') then
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

		-- Save the "database" every hour.
		if self.last_database_save ~= os.date('%H') then
			self.last_database_save = os.date('%H')
			utilities.save_data(self.database_name, self.database)
		end
	end
	-- Save the database before exiting.
	utilities.save_data(self.database_name, self.database)
	print('Halted.')
end

return bot
