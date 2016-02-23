 -- Moderation for Liberbot groups.
 -- The bot must be made an admin.
 -- Put this near the top, after blacklist.
 -- If you want to enable antisquig, put that at the top, before blacklist.

if not database.moderation then
	database.moderation = {}
end

local antisquig = {}

local commands = {

	['^/modhelp[@'..bot.username..']*$'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

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

		sendMessage(msg.chat.id, output, true, nil, true)

	end,

	['^/modlist[@'..bot.username..']*$'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

		local output = ''

		for k,v in pairs(database.moderation[msg.chat.id_str]) do
			output = output .. '• ' .. v .. ' (' .. k .. ')\n'
		end

		if output ~= '' then
			output = '*Moderators for* _' .. msg.chat.title .. '_ *:*\n' .. output
		end

		output = output .. '*Administrators for* _' .. config.moderation.realm_name .. '_ *:*\n'
		for k,v in pairs(config.moderation.admins) do
			output = output .. '• ' .. v .. ' (' .. k .. ')\n'
		end

		sendMessage(msg.chat.id, output, true, nil, true)

	end,

	['^/modcast[@'..bot.username..']*'] = function(msg)

		local output = msg.text:input()
		if not output then
			return 'You must include a message.'
		end

		if msg.chat.id ~= config.moderation.admin_group then
			return 'This command must be run in the administration group.'
		end

		if not config.moderation.admins[msg.from.id_str] then
			return config.moderation.errors.not_admin
		end

		output = '*Admin Broadcast:*\n' .. output

		for k,v in pairs(database.moderation) do
			sendMessage(k, output, true, nil, true)
		end

		return 'Your broadcast has been sent.'

	end,

	['^/modadd[@'..bot.username..']*$'] = function(msg)

		if not config.moderation.admins[msg.from.id_str] then
			return config.moderation.errors.not_admin
		end

		if database.moderation[msg.chat.id_str] then
			return 'I am already moderating this group.'
		end

		database.moderation[msg.chat.id_str] = {}
		return 'I am now moderating this group.'

	end,

	['^/modrem[@'..bot.username..']*$'] = function(msg)

		if not config.moderation.admins[msg.from.id_str] then
			return config.moderation.errors.not_admin
		end

		if not database.moderation[msg.chat.id_str] then
			return config.moderation.errors.moderation
		end

		database.moderation[msg.chat.id_str] = nil
		return 'I am no longer moderating this group.'

	end,

	['^/modprom[@'..bot.username..']*$'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

		if not config.moderation.admins[msg.from.id_str] then
			return config.moderation.errors.not_admin
		end

		if not msg.reply_to_message then
			return 'Promotions must be done via reply.'
		end

		local modid = tostring(msg.reply_to_message.from.id)
		local modname = msg.reply_to_message.from.first_name

		if config.moderation.admins[modid] then
			return modname .. ' is already an administrator.'
		end

		if database.moderation[msg.chat.id_str][modid] then
			return modname .. ' is already a moderator.'
		end

		database.moderation[msg.chat.id_str][modid] = modname

		return modname .. ' is now a moderator.'

	end,

	['^/moddem[@'..bot.username..']*'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

		if not config.moderation.admins[msg.from.id_str] then
			return config.moderation.errors.not_admin
		end

		local modid = msg.text:input()

		if not modid then
			if msg.reply_to_message then
				modid = tostring(msg.reply_to_message.from.id)
			else
				return 'Demotions must be done via reply or specification of a moderator\'s ID.'
			end
		end

		if config.moderation.admins[modid] then
			return config.moderation.admins[modid] .. ' is an administrator.'
		end

		if not database.moderation[msg.chat.id_str][modid] then
			return 'User is not a moderator.'
		end

		local modname = database.moderation[msg.chat.id_str][modid]
		database.moderation[msg.chat.id_str][modid] = nil

		return modname .. ' is no longer a moderator.'

	end,

	['/modkick[@'..bot.username..']*'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

		if not database.moderation[msg.chat.id_str][msg.from.id_str] then
			if not config.moderation.admins[msg.from.id_str] then
				return config.moderation.errors.not_mod
			end
		end

		local userid = msg.text:input()
		local usernm = userid

		if msg.reply_to_message then
			userid = tostring(msg.reply_to_message.from.id)
			usernm = msg.reply_to_message.from.first_name
		end

		if not userid then
			return 'Kicks must be done via reply or specification of a user/bot\'s ID or username.'
		end

		if database.moderation[msg.chat.id_str][userid] or config.moderation.admins[userid] then
			return 'You cannot kick a moderator.'
		end

		sendMessage(config.moderation.admin_group, '/kick ' .. userid .. ' from ' .. math.abs(msg.chat.id))

		sendMessage(config.moderation.admin_group, usernm .. ' kicked from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

	end,

	['^/modban[@'..bot.username..']*'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return end

		if not database.moderation[msg.chat.id_str][msg.from.id_str] then
			if not config.moderation.admins[msg.from.id_str] then
				return config.moderation.errors.not_mod
			end
		end

		local userid = msg.text:input()
		local usernm = userid

		if msg.reply_to_message then
			userid = tostring(msg.reply_to_message.from.id)
			usernm = msg.reply_to_message.from.first_name
		end

		if not userid then
			return 'Kicks must be done via reply or specification of a user/bot\'s ID or username.'
		end

		if database.moderation[msg.chat.id_str][userid] or config.moderation.admins[userid] then
			return 'You cannot ban a moderator.'
		end

		sendMessage(config.moderation.admin_group, '/ban ' .. userid .. ' from ' .. math.abs(msg.chat.id))

		sendMessage(config.moderation.admin_group, usernm .. ' banned from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

	end

}

if config.moderation.antisquig then
	commands['[\216-\219][\128-\191]'] = function(msg)

		if not database.moderation[msg.chat.id_str] then return true end
		if config.moderation.admins[msg.from.id_str] then return true end
		if database.moderation[msg.chat.id_str][msg.from.id_str] then return true end

		if antisquig[msg.from.id] == true then
			return
		end
		antisquig[msg.from.id] = true

		sendReply(msg, config.moderation.errors.antisquig)
		sendMessage(config.moderation.admin_group, '/kick ' .. msg.from.id .. ' from ' .. math.abs(msg.chat.id))
		sendMessage(config.moderation.admin_group, 'ANTISQUIG: ' .. msg.from.first_name .. ' kicked from ' .. msg.chat.title .. '.')

	end
end

local triggers = {}
for k,v in pairs(commands) do
	table.insert(triggers, k)
end

local action = function(msg)

	for k,v in pairs(commands) do
		if string.match(msg.text_lower, k) then
			local output = v(msg)
			if output == true then
				return true
			elseif output then
				sendReply(msg, output)
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
local cron = function()

	antisquig = {}

end

return {
	action = action,
	triggers = triggers,
	cron = cron
}
