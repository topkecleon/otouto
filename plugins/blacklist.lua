 -- This plugin will allow the admin to blacklist users who will be unable to
 -- use the bot. This plugin should be at the top of your plugin list in config.

local blacklist = {}

local bindings = require('bindings')
local utilities = require('utilities')

function blacklist:init()
	if not self.database.blacklist then
		self.database.blacklist = {}
	end
end

blacklist.triggers = {
	''
}

function blacklist:action(msg)

	if self.database.blacklist[msg.from.id_str] then return end
	if self.database.blacklist[msg.chat.id_str] then return end
	if not msg.text:match('^/blacklist') then return true end
	if msg.from.id ~= self.config.admin then return end

	local target = utilities.user_from_message(self, msg)
	if target.err then
		bindings.sendReply(self, msg, target.err)
		return
	end

	if tonumber(target.id) < 0 then
		target.name = 'Group'
	end

	if self.database.blacklist[tostring(target.id)] then
		self.database.blacklist[tostring(target.id)] = nil
		bindings.sendReply(self, msg, target.name .. ' has been removed from the blacklist.')
	else
		self.database.blacklist[tostring(target.id)] = true
		bindings.sendReply(self, msg, target.name .. ' has been added to the blacklist.')
	end

 end

 return blacklist
