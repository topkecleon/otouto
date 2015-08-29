--[[

This works using the settings in the "moderation" section of config.lua.
"realm" should be set to the group ID of the admin group. A negative number.
"data" will be the file name of where the moderation 'database' will be stored. The file will be created if it does not exist.
"admins" is a table of administrators for the Liberbot admin group. They will have the power to add groups and moderators to the database. The value can be a nickname for the admin, but it only needs to be true for it to work.

Your bot should have privacy mode disabled.

]]--

local help = {}

help.trigger = '^/modhelp'

help.action = function(msg)

	local data = load_data('moderation.json')

	local do_send = false
	if data[tostring(msg.chat.id)] and data[tostring(msg.chat.id)][tostring(msg.from.id)] then do_send = true end
	if config.moderation.admins[tostring(msg.from.id)] then do_send = true end
	if do_send == false then return end

	local message = [[
		Moderator commands:
			/modban - Ban a user via reply or username.
			/modkick -  Kick a user via reply or username.
			/modlist - Get a list of moderators for this group.
		Administrator commands:
			/add - Add this group to the database.
			/remove - Remove this group from the database.
			/promote - Promote a user via reply.
			/demote - Demote a user via reply.
			/modcast - Send a broastcast to every group.
			/hammer - Ban a user from all groups via reply or username.
	]]

	send_message(msg.chat.id, message)

end


local ban = {}

ban.trigger = '^/modban'

ban.action = function(msg)

	local data = load_data('moderation.json')

	if not data[tostring(msg.chat.id)] then return end
	if not data[tostring(msg.chat.id)][tostring(msg.from.id)] then
		if not config.moderation.admins[tostring(msg.from.id)] then
			return
		end
	end

	local target = get_target(msg)
	if not target then
		return send_message(msg.chat.id, 'No one to remove.\nBots must be removed by username.')
	end

	if msg.reply_to_message and data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] then
		return send_message(msg.chat.id, 'Cannot remove a moderator.')
	end

	local chat_id = math.abs(msg.chat.id)

	send_message(config.moderation.realm, '/ban ' .. target .. ' from ' .. chat_id)

	if msg.reply_to_message then
		target = msg.reply_to_message.from.first_name
	end

	send_message(config.moderation.realm, target .. ' banned from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

end


local kick = {}

kick.trigger = '^/modkick'

kick.action = function(msg)

	local data = load_data('moderation.json')

	if not data[tostring(msg.chat.id)] then return end
	if not data[tostring(msg.chat.id)][tostring(msg.from.id)] then
		if not config.moderation.admins[tostring(msg.from.id)] then
			return
		end
	end

	local target = get_target(msg)
	if not target then
		return send_message(msg.chat.id, 'No one to remove.\nBots must be removed by username.')
	end

	if msg.reply_to_message and data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] then
		return send_message(msg.chat.id, 'Cannot remove a moderator.')
	end

	local chat_id = math.abs(msg.chat.id)

	send_message(config.moderation.realm, '/kick ' .. target .. ' from ' .. chat_id)

	if msg.reply_to_message then
		target = msg.reply_to_message.from.first_name
	end

	send_message(config.moderation.realm, target .. ' kicked from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

end


local add = {}

add.trigger = '^/[mod]*add$'

add.action = function(msg)

	local data = load_data('moderation.json')

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	if data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is already added.')
	end

	data[tostring(msg.chat.id)] = {}
	save_data('moderation.json', data)

	send_message(msg.chat.id, 'Group has been added.')

end


local rem = {}

rem.trigger = '^/[mod]*rem[ove]*$'

rem.action = function(msg)

	local data = load_data('moderation.json')

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	data[tostring(msg.chat.id)] = nil
	save_data('moderation.json', data)

	send_message(msg.chat.id, 'Group has been removed.')

end


local promote = {}

promote.trigger = '^/[mod]*prom[ote]*$'

promote.action = function(msg)

	local data = load_data('moderation.json')
	local chatid = tostring(msg.chat.id)

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	if not data[chatid] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	if not msg.reply_to_message then
		return send_message(msg.chat.id, 'Promotions must be done via reply.')
	end

	local targid = tostring(msg.reply_to_message.from.id)

	if data[chatid][targid] then
		return send_message(msg.chat.id, msg.reply_to_message.from.first_name..' is already a moderator.')
	end

	if config.moderation.admins[targid] then
		return send_message(msg.chat.id, 'Administrators do not need to be promoted.')
	end

	if not msg.reply_to_message.from.username then
		msg.reply_to_message.from.username = msg.reply_to_message.from.first_name
	end

	data[chatid][targid] = msg.reply_to_message.from.first_name
	save_data('moderation.json', data)

	send_message(msg.chat.id, msg.reply_to_message.from.first_name..' has been promoted.')

end


local demote = {}

demote.trigger = '^/[mod]*dem[ote]*'

demote.action = function(msg)

	local data = load_data('moderation.json')

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			input = msg.reply_to_message.from.id
		else
			return send_msg('Demotions must be done by reply or by specifying a moderator\'s ID.')
		end
	end

	if not data[tostring(msg.chat.id)][tostring(input)] then
		return send_message(msg.chat.id, input..' is not a moderator.')
	end

	data[tostring(msg.chat.id)][tostring(input)] = nil
	save_data('moderation.json', data)

	send_message(msg.chat.id, input..' has been demoted.')

end


local broadcast = {}

broadcast.trigger = '^/modcast'

broadcast.action = function(msg)

	local data = load_data('moderation.json')

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	if msg.chat.id ~= config.moderation.realm then
		return send_message(msg.chat.id, 'This command must be run in the admin group.')
	end

	local message = get_input(msg.text)

	if not message then
		return send_message(msg.chat.id, 'You must specify a message to broadcast.')
	end

	for k,v in pairs(data) do
		send_message(k, message)
	end

end


local modlist = {}

modlist.trigger = '^/modlist'

modlist.action = function(msg)

	local data = load_data('moderation.json')

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	local message = ''

	for k,v in pairs(data[tostring(msg.chat.id)]) do
		message = message ..' - '..v.. ' (' .. k .. ')\n'
	end

	if message ~= '' then
		message = 'Moderators for ' .. msg.chat.title .. ':\n' .. message .. '\n'
	end

	message = message .. 'Administrators for ' .. config.moderation.realmname .. ':\n'
	for k,v in pairs(config.moderation.admins) do
		message = message ..' - '..v.. ' (' .. k .. ')\n'
	end

	send_message(msg.chat.id, message)

end


local badmin = {}

badmin.trigger = '^/hammer'

badmin.action = function(msg)

	if not config.moderation.admins[tostring(msg.from.id)] then return end

	local target = get_target(msg)
	if not target then
		return send_message(msg.chat.id, 'No one to remove.\nBots must be removed by username.')
	end

	send_message(config.moderation.realm, '/ban ' .. target .. ' from all')

	if msg.reply_to_message then
		target = msg.reply_to_message.from.first_name
	end

	send_message(config.moderation.realm, target .. ' was banhammered by ' .. msg.from.first_name .. '.')

end


local modactions = {
	help,
	ban,
	kick,
	add,
	rem,
	promote,
	demote,
	broadcast,
	modlist,
	badmin
}


local triggers = {
	'^/modhelp',
	'^/modlist',
	'^/modcast',
	'^/[mod]*add$',
	'^/[mod]*rem[ove]*$',
	'^/[mod]*prom[ote]*$',
	'^/[mod]*dem[ote]*',
	'^/modkick',
	'^/modban',
	'^/hammer'
}

local action = function(msg)
	for k,v in pairs(modactions) do
		if string.match(msg.text, v.trigger) then
			return v.action(msg)
		end
	end
end

return {
	triggers = triggers,
	action = action
}
