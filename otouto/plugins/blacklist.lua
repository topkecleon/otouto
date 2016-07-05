 -- This plugin will allow the admin to blacklist users who will be unable to
 -- use the bot. This plugin should be at the top of your plugin list in config.

local blacklist = {}

local utilities = require('otouto.utilities')

function blacklist:init()
	if not self.database.blacklist then
		self.database.blacklist = {}
	end
end

blacklist.triggers = {
	''
}

function blacklist:action(msg, config)

	if self.database.blacklist[tostring(msg.from.id)] then return end
	if self.database.blacklist[tostring(msg.chat.id)] then return end
	if not msg.text:match('^'..config.cmd_pat..'blacklist') then return true end
	if msg.from.id ~= config.admin then return end

	local target = utilities.user_from_message(self, msg)
	if target.err then
		utilities.send_reply(self, msg, target.err)
		return
	end

	if tonumber(target.id) < 0 then
		target.name = 'Group'
	end

	if self.database.blacklist[tostring(target.id)] then
		self.database.blacklist[tostring(target.id)] = nil
		utilities.send_reply(self, msg, target.name .. ' has been removed from the blacklist.')
		if config.drua_block_on_blacklist then
			require('drua-tg').unblock(target.id)
		end
	else
		self.database.blacklist[tostring(target.id)] = true
		utilities.send_reply(self, msg, target.name .. ' has been added to the blacklist.')
		if config.drua_block_on_blacklist then
			require('drua-tg').block(target.id)
		end
	end

 end

 return blacklist
