 -- Moderation for Liberbot groups.
 -- The bot must be made an admin.
 -- Put this near the top, after blacklist.
 -- If you want to enable antisquig, put that at the top, before blacklist.

local moderation = {}

local bindings = require('bindings')
local utilities = require('utilities')

local antisquig = {}

local commands = {

	['^/modhelp$'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		local output = [[
			*Users:*
			• /modlist - List the moderators and administrators of this group.
			*Moderators:*
			• /modkick - Kick a user from this group.
			• /modban - Ban a user from this group.
			*Administrators:*
			• /modadd - Add this group to the moderation system.
			• /modrem - Remove this group from the moderation system.
			• /modprom - Promote a user to a moderator.
			• /moddem - Demote a moderator to a user.
			• /modcast - Send a broadcast to every moderated group.
		]]
		output = output:gsub('\t', '')

		bindings.sendMessage(self, msg.chat.id, output, true, nil, true)

	end,

	['^/modlist$'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		local output = ''

		for k,v in pairs(self.database.moderation[msg.chat.id_str]) do
			output = output .. '• ' .. v .. ' (' .. k .. ')\n'
		end

		if output ~= '' then
			output = '*Moderators for* _' .. msg.chat.title .. '_ *:*\n' .. output
		end

		output = output .. '*Administrators for* _' .. self.config.moderation.realm_name .. '_ *:*\n'
		for k,v in pairs(self.config.moderation.admins) do
			output = output .. '• ' .. v .. ' (' .. k .. ')\n'
		end

		bindings.sendMessage(self, msg.chat.id, output, true, nil, true)

	end,

	['^/modcast'] = function(self, msg)

		local output = utilities.input(msg.text)
		if not output then
			return 'You must include a message.'
		end

		if msg.chat.id ~= self.config.moderation.admin_group then
			return 'This command must be run in the administration group.'
		end

		if not self.config.moderation.admins[msg.from.id_str] then
			return self.config.moderation.errors.not_admin
		end

		output = '*Admin Broadcast:*\n' .. output

		for k,_ in pairs(self.database.moderation) do
			bindings.sendMessage(self, k, output, true, nil, true)
		end

		return 'Your broadcast has been sent.'

	end,

	['^/modadd$'] = function(self, msg)

		if not self.config.moderation.admins[msg.from.id_str] then
			return self.config.moderation.errors.not_admin
		end

		if self.database.moderation[msg.chat.id_str] then
			return 'I am already moderating this group.'
		end

		self.database.moderation[msg.chat.id_str] = {}
		return 'I am now moderating this group.'

	end,

	['^/modrem$'] = function(self, msg)

		if not self.config.moderation.admins[msg.from.id_str] then
			return self.config.moderation.errors.not_admin
		end

		if not self.database.moderation[msg.chat.id_str] then
			return self.config.moderation.errors.moderation
		end

		self.database.moderation[msg.chat.id_str] = nil
		return 'I am no longer moderating this group.'

	end,

	['^/modprom$'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		if not self.config.moderation.admins[msg.from.id_str] then
			return self.config.moderation.errors.not_admin
		end

		if not msg.reply_to_message then
			return 'Promotions must be done via reply.'
		end

		local modid = tostring(msg.reply_to_message.from.id)
		local modname = msg.reply_to_message.from.first_name

		if self.config.moderation.admins[modid] then
			return modname .. ' is already an administrator.'
		end

		if self.database.moderation[msg.chat.id_str][modid] then
			return modname .. ' is already a moderator.'
		end

		self.database.moderation[msg.chat.id_str][modid] = modname

		return modname .. ' is now a moderator.'

	end,

	['^/moddem'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		if not self.config.moderation.admins[msg.from.id_str] then
			return self.config.moderation.errors.not_admin
		end

		local modid = utilities.input(msg.text)

		if not modid then
			if msg.reply_to_message then
				modid = tostring(msg.reply_to_message.from.id)
			else
				return 'Demotions must be done via reply or specification of a moderator\'s ID.'
			end
		end

		if self.config.moderation.admins[modid] then
			return self.config.moderation.admins[modid] .. ' is an administrator.'
		end

		if not self.database.moderation[msg.chat.id_str][modid] then
			return 'User is not a moderator.'
		end

		local modname = self.database.moderation[msg.chat.id_str][modid]
		self.database.moderation[msg.chat.id_str][modid] = nil

		return modname .. ' is no longer a moderator.'

	end,

	['/modkick'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		if not self.database.moderation[msg.chat.id_str][msg.from.id_str] then
			if not self.config.moderation.admins[msg.from.id_str] then
				return self.config.moderation.errors.not_mod
			end
		end

		local userid = utilities.input(msg.text)
		local usernm = userid

		if msg.reply_to_message then
			userid = tostring(msg.reply_to_message.from.id)
			usernm = msg.reply_to_message.from.first_name
		end

		if not userid then
			return 'Kicks must be done via reply or specification of a user/bot\'s ID or username.'
		end

		if self.database.moderation[msg.chat.id_str][userid] or self.config.moderation.admins[userid] then
			return 'You cannot kick a moderator.'
		end

		bindings.sendMessage(self, self.config.moderation.admin_group, '/kick ' .. userid .. ' from ' .. math.abs(msg.chat.id))

		bindings.sendMessage(self, self.config.moderation.admin_group, usernm .. ' kicked from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

	end,

	['^/modban'] = function(self, msg)

		if not self.database.moderation[msg.chat.id_str] then return end

		if not self.database.moderation[msg.chat.id_str][msg.from.id_str] then
			if not self.config.moderation.admins[msg.from.id_str] then
				return self.config.moderation.errors.not_mod
			end
		end

		local userid = utilities.input(msg.text)
		local usernm = userid

		if msg.reply_to_message then
			userid = tostring(msg.reply_to_message.from.id)
			usernm = msg.reply_to_message.from.first_name
		end

		if not userid then
			return 'Kicks must be done via reply or specification of a user/bot\'s ID or username.'
		end

		if self.database.moderation[msg.chat.id_str][userid] or self.config.moderation.admins[userid] then
			return 'You cannot ban a moderator.'
		end

		bindings.sendMessage(self.config.moderation.admin_group, '/ban ' .. userid .. ' from ' .. math.abs(msg.chat.id))

		bindings.sendMessage(self.config.moderation.admin_group, usernm .. ' banned from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

	end

}

function moderation:init()
	if not self.database.moderation then
		self.database.moderation = {}
	end

	if self.config.moderation.antisquig then
		commands['[\216-\219][\128-\191]'] = function(msg)

			if not self.database.moderation[msg.chat.id_str] then return true end
			if self.config.moderation.admins[msg.from.id_str] then return true end
			if self.database.moderation[msg.chat.id_str][msg.from.id_str] then return true end

			if antisquig[msg.from.id] == true then
				return
			end
			antisquig[msg.from.id] = true

			bindings.sendReply(self, msg, self.config.moderation.errors.antisquig)
			bindings.sendMessage(self, self.config.moderation.admin_group, '/kick ' .. msg.from.id .. ' from ' .. math.abs(msg.chat.id))
			bindings.sendMessage(self, self.config.moderation.admin_group, 'ANTISQUIG: ' .. msg.from.first_name .. ' kicked from ' .. msg.chat.title .. '.')

		end
	end

	moderation.triggers = {}
	for trigger,_ in pairs(commands) do
		if trigger[-1] == '$' then
			moderation.triggers:insert(trigger:sub(1, -2)..'@'..self.info.username..'$')
		else
			moderation.triggers:insert(trigger..'%s+[^%s]*')
			moderation.triggers:insert(trigger..'@'..self.info.username..'%s+[^%s]*')
			moderation.triggers:insert(trigger..'$')
			moderation.triggers:insert(trigger..'@'..self.info.username..'$')
		end
	end
end

function moderation:action(msg)

	for trigger,command in pairs(commands) do
		if string.match(msg.text_lower, trigger) then
			local output = command(self, msg)
			if output == true then
				return true
			elseif output then
				bindings.sendReply(self, msg, output)
			end
			return
		end
	end

	return true

end

 -- When a user is kicked for squiggles, his ID is added to this table.
 -- That user will not be kicked again as long as his ID is in the table.
 -- The table is emptied every five seconds.
 -- Thus the bot will not spam the group or admin group when a user posts more than one infringing messages.
function moderation:cron()

	antisquig = {}

end

return moderation
