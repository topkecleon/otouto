--[[
	administration.lua
	Version 1.6.1
	Part of the otouto project.
	© 2016 topkecleon <drew@otou.to>
	GNU General Public License, version 2

	This plugin provides self-hosted, single-realm group administration.
	It requires tg (http://github.com/vysheng/tg) with supergroup support.
	For more documentation, view the readme or the manual (otou.to/rtfm).

	Remember to load this before blacklist.lua.

	Important notices about updates will be here!

	Rules lists always exist, empty if there are no rules. Group arrays are now
	stored in a "groups" array rather than at the top level. Global data is now
	stored at the top level rather than in a "global" array. Automatic migration
	will occur in versions 1.5 and 1.6.

	/groups will now list groups according to activity.
]]--

 -- Build the administration db if nonexistent.
if not database.administration then
	database.administration = {
		admins = {},
		groups = {},
		activity = {}
	}
end

admin_temp = {
	help = {},
	flood = {}
}

 -- Migration code: Remove this in v1.7.
 -- Group data is now stored in a "groups" array.
if not database.administration.groups then
	database.administration.groups = {}
	for k,v in pairs(database.administration) do
		if tonumber(k) then
			database.administration.groups[k] = v
			database.administration[k] = nil
		end
	end
end
 -- Global data is stored at the top level.
if database.administration.global then
	for k,v in pairs(database.administration.global) do
		database.administration[k] = v
	end
	database.administration.global = nil
end
 -- Rule lists remain empty, rather than nil, when there are no rules.
for k,v in pairs(database.administration.groups) do
	v.rules = v.rules or {}
end

 -- Migration code: Remove this in v1.8.
 -- Most recent group activity is now cached for group listings.
if not database.administration.activity then
	database.administration.activity = {}
	for k,v in pairs(database.administration.groups) do
		table.insert(database.administration.activity, k)
	end
end

drua = dofile('drua-tg/drua-tg.lua')
drua.PORT = config.cli_port or 4567

local flags = {
	[1] = {
		name = 'unlisted',
		desc = 'Removes this group from the group listing.',
		short = 'This group is unlisted.',
		enabled = 'This group is no longer listed in /groups.',
		disabled = 'This group is now listed in /groups.'
	},
	[2] = {
		name = 'antisquig',
		desc = 'Automatically removes users who post Arabic script or RTL characters.',
		short = 'This group does not allow Arabic script or RTL characters.',
		enabled = 'Users will now be removed automatically for posting Arabic script and/or RTL characters.',
		disabled = 'Users will no longer be removed automatically for posting Arabic script and/or RTL characters..',
		kicked = 'You were automatically kicked from GROUPNAME for posting Arabic script and/or RTL characters.'
	},
	[3] = {
		name = 'antisquig++',
		desc = 'Automatically removes users whose names contain Arabic script or RTL characters.',
		short = 'This group does not allow users whose names contain Arabic script or RTL characters.',
		enabled = 'Users whose names contain Arabic script and/or RTL characters will now be removed automatically.',
		disabled = 'Users whose names contain Arabic script and/or RTL characters will no longer be removed automatically.',
		kicked = 'You were automatically kicked from GROUPNAME for having a name which contains Arabic script and/or RTL characters.'
	},
	[4] = {
		name = 'antibot',
		desc = 'Prevents the addition of bots by non-moderators.',
		short = 'This group does not allow users to add bots.',
		enabled = 'Non-moderators will no longer be able to add bots.',
		disabled = 'Non-moderators will now be able to add bots.'
	},
	[5] = {
		name = 'antiflood',
		desc = 'Prevents flooding by rate-limiting messages per user.',
		short = 'This group automatically removes users who flood.',
		enabled = 'Users will now be removed automatically for excessive messages. Use /antiflood to configure limits.',
		disabled = 'Users will no longer be removed automatically for excessive messages.',
		kicked = 'You were automatically kicked from GROUPNAME for flooding.'
	}
}

local antiflood = {
	text = 5,
	voice = 5,
	audio = 5,
	contact = 5,
	photo = 10,
	video = 10,
	location = 10,
	document = 10,
	sticker = 20
}

local ranks = {
	[0] = 'Banned',
	[1] = 'Users',
	[2] = 'Moderators',
	[3] = 'Governors',
	[4] = 'Administrators',
	[5] = 'Owner'
}

local get_rank = function(target, chat)

	target = tostring(target)
	if chat then
		chat = tostring(chat)
	end

	if tonumber(target) == config.admin or tonumber(target) == bot.id then
		return 5
	end

	if database.administration.admins[target] then
		return 4
	end

	if chat and database.administration.groups[chat] then
		if database.administration.groups[chat].govs[target] then
			return 3
		elseif database.administration.groups[chat].mods[target] then
			return 2
		elseif database.administration.groups[chat].bans[target] then
			return 0
		end
	end

	if database.blacklist[target] then
		return 0
	end

	return 1

end

local get_target = function(msg)

	local target = user_from_message(msg)
	if target.id then
		target.rank = get_rank(target.id, msg.chat.id)
	end
	return target

end

local mod_format = function(id)
	id = tostring(id)
	local user = database.users[id] or { first_name = 'Unknown' }
	local name = user.first_name
	if user.last_name then name = user.first_name .. ' ' .. user.last_name end
	name = markdown_escape(name)
	local output = '• ' .. name .. ' `[' .. id .. ']`\n'
	return output
end

local get_desc = function(chat_id)

	local group = database.administration.groups[tostring(chat_id)]
	local t = {}
	if group.link then
		table.insert(t, '*Welcome to* [' .. group.name .. '](' .. group.link .. ')*!*')
	else
		table.insert(t, '*Welcome to* _' .. group.name .. '_*!*')
	end
	if group.motd then
		table.insert(t, '*Message of the Day:*\n' .. group.motd)
	end
	if #group.rules > 0 then
		local rulelist = '*Rules:*\n'
		for i,v in ipairs(group.rules) do
			rulelist = rulelist .. '*' .. i .. '.* ' .. v .. '\n'
		end
		table.insert(t, rulelist:trim())
	end
	local flaglist = ''
	for i = 1, #flags do
		if group.flags[i] then
			flaglist = flaglist .. '• ' .. flags[i].short .. '\n'
		end
	end
	if flaglist ~= '' then
		table.insert(t, '*Flags:*\n' .. flaglist:trim())
	end
	local modstring = ''
	for k,v in pairs(group.mods) do
		modstring = modstring .. mod_format(k)
	end
	if modstring ~= '' then
		table.insert(t, '*Moderators:*\n' .. modstring:trim())
	end
	local govstring = ''
	for k,v in pairs(group.govs) do
		govstring = govstring .. mod_format(k)
	end
	if govstring ~= '' then
		table.insert(t, '*Governors:*\n' .. govstring:trim())
	end
	return table.concat(t, '\n\n')

end

local commands = {

	{ -- antisquig
		triggers = {
			'[\216-\219][\128-\191]', -- arabic
			'‮', -- rtl
			'‏', -- other rtl
		},

		privilege = 0,
		interior = true,

		action = function(msg, group)
			if get_rank(msg.from.id, msg.chat.id) > 1 then
				return true
			end
			if not group.flags[2] then
				return true
			end
			drua.kick_user(msg.chat.id, msg.from.id)
			local output = flags[2].kicked:gsub('GROUPNAME', msg.chat.title)
			sendMessage(msg.from.id, output)
		end
	},

	{ -- generic
		triggers = { '' },

		privilege = 0,
		interior = true,

		action = function(msg, group)

			local rank = get_rank(msg.from.id, msg.chat.id)

			-- banned
			if rank == 0 then
				drua.kick_user(msg.chat.id, msg.from.id)
				sendMessage(msg.from.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
				return
			end

			if rank < 2 then

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.from.name:match('[\216-\219][\128-\191]') or msg.from.name:match('‮') or msg.from.name:match('‏') then
						drua.kick_user(msg.chat.id, msg.from.id)
						local output = flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
						sendMessage(msg.from.id, output)
						return
					end
				end

				-- antiflood
				if group.flags[5] == true then
					if not group.antiflood then
						group.antiflood = JSON.decode(JSON.encode(antiflood))
					end
					if not admin_temp.flood[msg.chat.id_str] then
						admin_temp.flood[msg.chat.id_str] = {}
					end
					if not admin_temp.flood[msg.chat.id_str][msg.from.id_str] then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = 0
					end
					if msg.sticker then -- Thanks Brazil for discarding switches.
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.sticker
					elseif msg.photo then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.photo
					elseif msg.document then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.document
					elseif msg.audio then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.audio
					elseif msg.contact then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.contact
					elseif msg.video then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.video
					elseif msg.location then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.location
					elseif msg.voice then
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.voice
					else
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.text
					end
					if admin_temp.flood[msg.chat.id_str][msg.from.id_str] > 99 then
						drua.kick_user(msg.chat.id, msg.from.id)
						local output = flags[5].kicked:gsub('GROUPNAME', msg.chat.title)
						sendMessage(msg.from.id, output)
						admin_temp.flood[msg.chat.id_str][msg.from.id_str] = nil
						return
					end
				end

			end

			if msg.new_chat_participant then

				msg.new_chat_participant.name = msg.new_chat_participant.first_name
				if msg.new_chat_participant.last_name then
					msg.new_chat_participant.name = msg.new_chat_participant.first_name .. ' ' .. msg.new_chat_participant.last_name
				end

				-- banned
				if get_rank(msg.new_chat_participant.id, msg.chat.id) == 0 then
					drua.kick_user(msg.chat.id, msg.new_chat_participant.id)
					sendMessage(msg.new_chat_participant.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
					return
				end

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.new_chat_participant.name:match('[\216-\219][\128-\191]') or msg.new_chat_participant.name:match('‮') or msg.new_chat_participant.name:match('‏') then
						drua.kick_user(msg.chat.id, msg.new_chat_participant.id)
						local output = flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
						sendMessage(msg.new_chat_participant.id, output)
						return
					end
				end

				-- antibot
				if msg.new_chat_participant.username and msg.new_chat_participant.username:match('bot$') then
					if rank < 2 and group.flags[4] == true then
						drua.kick_user(msg.chat.id, msg.new_chat_participant.id)
						return
					end
				else
					local output = get_desc(msg.chat.id)
					sendMessage(msg.new_chat_participant.id, output, true, nil, true)
					return
				end

			elseif msg.new_chat_title then

				if rank < 3 then
					drua.rename_chat(msg.chat.id, group.name)
				else
					group.name = msg.new_chat_title
				end
				return

			elseif msg.new_chat_photo then

				if group.grouptype == 'group' then
					if rank < 3 then
						drua.set_photo(msg.chat.id, group.photo)
					else
						group.photo = drua.get_photo(msg.chat.id)
					end
				else
					group.photo = drua.get_photo(msg.chat.id)
				end
				return

			elseif msg.delete_chat_photo then

				if group.grouptype == 'group' then
					if rank < 3 then
						drua.set_photo(msg.chat.id, group.photo)
					else
						group.photo = nil
					end
				else
					group.photo = nil
				end
				return

			end

			-- Last active time for group listing.
			for i,v in pairs(database.administration.activity) do
				if v == msg.chat.id_str then
					table.remove(database.administration.activity, i)
					table.insert(database.administration.activity, 1, msg.chat.id_str)
				end
			end

			return true

		end
	},

	{ -- groups
		triggers = {
			'^/groups$',
			'^/groups@'..bot.username
		},

		command = 'groups',
		privilege = 1,
		interior = false,

		action = function(msg)
			local output = ''
			for i,v in ipairs(database.administration.activity) do
				local group = database.administration.groups[v]
				if not group.flags[1] then -- no unlisted groups
					if group.link then
						output = output ..  '• [' .. group.name .. '](' .. group.link .. ')\n'
					else
						output = output ..  '• ' .. group.name .. '\n'
					end
				end
			end
			if output == '' then
				output = 'There are currently no listed groups.'
			else
				output = '*Groups:*\n' .. output
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- ahelp
		triggers = {
			'^/ahelp$',
			'^/ahelp@'..bot.username
		},

		command = 'ahelp',
		privilege = 1,
		interior = true,

		action = function(msg)
			local rank = get_rank(msg.from.id, msg.chat.id)
			local output = '*Commands for ' .. ranks[rank] .. ':*\n'
			for i = 1, rank do
				for ind, val in ipairs(admin_temp.help[i]) do
					output = output .. '• /' .. val .. '\n'
				end
			end
			if sendMessage(msg.from.id, output, true, nil, true) then
				sendReply(msg, 'I have sent you the requested information in a private message.')
			else
				sendMessage(msg.chat.id, output, true, nil, true)
			end
		end
	},

	{ -- alist
		triggers = {
			'^/ops$',
			'^/ops@'..bot.username,
			'^/oplist$',
			'^/oplist@'..bot.username
		},

		command = 'ops',
		privilege = 1,
		interior = true,

		action = function(msg, group)
			local modstring = ''
			for k,v in pairs(group.mods) do
				modstring = modstring .. mod_format(k)
			end
			if modstring ~= '' then
				modstring = '*Moderators for* _' .. msg.chat.title .. '_ *:*\n' .. modstring
			end
			local govstring = ''
			for k,v in pairs(group.govs) do
				govstring = govstring .. mod_format(k)
			end
			if govstring ~= '' then
				govstring = '*Governors for* _' .. msg.chat.title .. '_ *:*\n' .. govstring
			end
			local output = modstring .. govstring
			if output == '' then
				output = 'There are currently no moderators for this group.'
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end

	},

	{ -- desc
		triggers = {
			'^/desc[ription]*$',
			'^/desc[ription]*@'..bot.username
		},

		command = 'description',
		privilege = 1,
		interior = true,

		action = function(msg)
			local output = get_desc(msg.chat.id)
			if sendMessage(msg.from.id, output, true, nil, true) then
				sendReply(msg, 'I have sent you the requested information in a private message.')
			else
				sendMessage(msg.chat.id, output, true, nil, true)
			end
		end
	},

	{ -- rules
		triggers = {
			'^/rules$',
			'^/rules@'..bot.username
		},

		command = 'rules',
		privilege = 1,
		interior = true,

		action = function(msg, group)
			local output = 'No rules have been set for ' .. msg.chat.title .. '.'
			if #group.rules > 0 then
				output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
				for i,v in ipairs(group.rules) do
					output = output .. '*' .. i .. '.* ' .. v .. '\n'
				end
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- motd
		triggers = {
			'^/motd$',
			'^/motd@'..bot.username
		},

		command = 'motd',
		privilege = 1,
		interior = true,

		action = function(msg, group)
			local output = 'No MOTD has been set for ' .. msg.chat.title .. '.'
			if group.motd then
				output = '*MOTD for* _' .. msg.chat.title .. '_ *:*\n' .. group.motd
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- link
		triggers = {
			'^/link$',
			'^/link@'..bot.username
		},

		command = 'link',
		privilege = 1,
		interior = true,

		action = function(msg, group)
			local output = 'No link has been set for ' .. msg.chat.title .. '.'
			if group.link then
				output = '[' .. msg.chat.title .. '](' .. group.link .. ')'
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- kickme
		triggers = {
			'^/leave[@'..bot.username..']*',
			'^/kickme[@'..bot.username..']*'
		},

		command = 'leave',
		privilege = 1,
		interior = true,

		action = function(msg)
			if get_rank(msg.from.id) == 5 then
				local output = 'I can\'t let you do that, ' .. msg.from.first_name .. '.'
				sendMessage(msg.chat.id, output, true, nil, true)
			elseif msg.chat.type == 'supergroup' then
				local output = 'Leave this group manually or you will be unable to rejoin.'
				sendMessage(msg.chat.id, output, true, nil, true)
			else
				drua.kick_user(msg.chat.id, msg.from.id)
			end
		end
	},

	{ -- kick
		triggers = {
			'^/kick[@'..bot.username..']*'
		},

		command = 'kick <user>',
		privilege = 2,
		interior = true,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			elseif target.rank > 1 then
				sendReply(msg, target.name .. ' is too privileged to be kicked.')
				return
			end
			drua.kick_user(msg.chat.id, target.id)
			sendMessage(msg.chat.id, target.name .. ' has been kicked.')
		end
	},

	{ -- ban
		triggers = {
			'^/ban',
			'^/unban'
		},

		command = 'ban <user>',
		privilege = 2,
		interior = true,

		action = function(msg, group)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if target.rank > 1 then
				sendReply(msg, target.name .. ' is too privileged to be banned.')
				return
			end
			if group.bans[target.id_str] then
				group.bans[target.id_str] = nil
				sendReply(msg, target.name .. ' has been unbanned.')
			else
				group.bans[target.id_str] = true
				drua.kick_user(msg.chat.id, target.id)
				sendReply(msg, target.name .. ' has been banned.')
			end
		end
	},

	{ -- changerule
		triggers = {
			'^/changerule',
			'^/changerule@' .. bot.username
		},

		command = 'changerule <i> <rule>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local usage = 'usage: `/changerule <i> <newrule>`\n`/changerule <i> -- `deletes.'
			local input = msg.text:input()
			if not input then
				sendMessage(msg.chat.id, usage, true, msg.message_id, true)
				return
			end
			local rule_num = input:match('^%d+')
			if not rule_num then
				local output = 'Please specify which rule you want to change.\n' .. usage
				sendMessage(msg.chat.id, output, true, msg.message_id, true)
				return
			end
			rule_num = tonumber(rule_num)
			local rule_new = input:input()
			if not rule_new then
				local output = 'Please specify the new rule.\n' .. usage
				sendMessage(msg.chat.id, output, true, msg.message_id, true)
				return
			end
			if not group.rules then
				local output = 'Sorry, there are no rules to change. Please use /setrules.\n' .. usage
				sendMessage(msg.chat.id, output, true, msg.message_id, true)
				return
			end
			if not group.rules[rule_num] then
				rule_num = #group.rules + 1
			end
			if rule_new == '--' or rule_new == '—' then
				if group.rules[rule_num] then
					table.remove(group.rules, rule_num)
					sendReply(msg, 'That rule has been deleted.')
				else
					sendReply(msg, 'There is no rule with that number.')
				end
				return
			end
			group.rules[rule_num] = rule_new
			local output = '*' .. rule_num .. '*. ' .. rule_new
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- setrules
		triggers = {
			'^/setrules[@'..bot.username..']*'
		},

		command = 'setrules <rules>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local input = msg.text:match('^/setrules[@'..bot.username..']*(.+)')
			if not input then
				sendMessage(msg.chat.id, '```\n/setrules [rule]\n<rule>\n[rule]\n...\n```', true, msg.message_id, true)
				return
			elseif input == ' --' or input == ' —' then
				group.rules = {}
				sendReply(msg, 'The rules have been cleared.')
				return
			end
			group.rules = {}
			input = input:trim() .. '\n'
			local output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
			local i = 1
			for l in input:gmatch('(.-)\n') do
				output = output .. '*' .. i .. '.* ' .. l .. '\n'
				i = i + 1
				table.insert(group.rules, l:trim())
			end
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- setmotd
		triggers = {
			'^/setmotd[@'..bot.username..']*'
		},

		command = 'setmotd <motd>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local input = msg.text:input()
			if not input then
				if msg.reply_to_message and msg.reply_to_message.text then
					input = msg.reply_to_message.text
				else
					sendReply(msg, 'Please specify the new message of the day.')
					return
				end
			elseif input == '--' or input == '—' then
				group.motd = nil
				sendReply(msg, 'The MOTD has been cleared.')
				return
			end
			input = input:trim()
			group.motd = input
			local output = '*MOTD for* _' .. msg.chat.title .. '_ *:*\n' .. input
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- setlink
		triggers = {
			'^/setlink[@'..bot.username..']*'
		},

		command = 'setlink <link>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local input = msg.text:input()
			if not input then
				sendReply(msg, 'Please specify the new link.')
				return
			elseif input == '--' or input == '—' then
				group.link = drua.export_link(msg.chat.id)
				sendReply(msg, 'The link has been regenerated.')
				return
			end
			group.link = input
			local output = '[' .. msg.chat.title .. '](' .. input .. ')'
			sendMessage(msg.chat.id, output, true, nil, true)
		end
	},

	{ -- flags
		triggers = {
			'^/flags?[@'..bot.username..']*'
		},

		command = 'flag <i>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local input = msg.text:input()
			if input then
				input = get_word(input, 1)
				input = tonumber(input)
				if not input or not flags[input] then input = false end
			end
			if not input then
				local output = '*Flags for* _' .. msg.chat.title .. '_ *:*\n'
				for i,v in ipairs(flags) do
					local status = group.flags[i] or false
					output = output .. '`[' .. i .. ']` *' .. v.name .. '*` = ' .. tostring(status) .. '`\n• ' .. v.desc .. '\n'
				end
				sendMessage(msg.chat.id, output, true, nil, true)
				return
			end
			local output
			if group.flags[input] == true then
				group.flags[input] = false
				sendReply(msg, flags[input].disabled)
			else
				group.flags[input] = true
				sendReply(msg, flags[input].enabled)
			end
		end
	},

	{ -- antiflood
		triggers = {
			'^/antiflood',
			'^/antiflood@'..bot.username
		},

		command = 'antiflood <type> <i>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			if not group.flags[5] then
				sendMessage(msg.chat.id, 'antiflood is not enabled. Use `/flag 5` to enable it.', true, nil, true)
				return
			end
			if not group.antiflood then
				group.antiflood = JSON.decode(JSON.encode(antiflood))
			end
			local input = msg.text_lower:input()
			local output
			if input then
				local key, val = input:match('(%a+) (%d+)')
				if not group.antiflood[key] or not tonumber(val) then
					output = 'Not a valid message type or number.'
				else
					group.antiflood[key] = val
					output = 'A *' .. key .. '* message is now worth *' .. val .. '* points.'
				end
			else
				output = 'usage: `/antiflood <type> <i>`\nexample: `/antiflood text 5`\nUse this command to configure the point values for each message type. When a user reaches 100 points, he is kicked. The points are reset each minute. The current values are:\n'
				for k,v in pairs(group.antiflood) do
					output = output .. '*'..k..':* `'..v..'`\n'
				end
			end
			sendMessage(msg.chat.id, output, true, msg.message_id, true)
		end
	},

	{ -- mod
		triggers = {
			'^/mod',
			'^/demod'
		},

		command = 'mod <user>',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if group.mods[target.id_str] then
				if group.grouptype == 'supergroup' then
					drua.channel_set_admin(msg.chat.id, target.id, 0)
				end
				group.mods[target.id_str] = nil
				sendReply(msg, target.name .. ' is no longer a moderator.')
			else
				if target.rank > 2 then
					sendReply(msg, target.name .. ' is greater than a moderator.')
					return
				end
				if group.grouptype == 'supergroup' then
					drua.channel_set_admin(msg.chat.id, target.id, 2)
				end
				group.mods[target.id_str] = true
				sendReply(msg, target.name .. ' is now a moderator.')
			end
		end
	},

	{ -- gov
		triggers = {
			'^/gov',
			'^/degov'
		},

		command = 'gov <user>',
		privilege = 4,
		interior = true,

		action = function(msg, group)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if group.govs[target.id_str] then
				if group.grouptype == 'supergroup' then
					drua.channel_set_admin(msg.chat.id, target.id, 0)
				end
				group.govs[target.id_str] = nil
				sendReply(msg, target.name .. ' is no longer a governor.')
			else
				if target.rank == 2 then
					group.mods[target.id_str] = nil
				end
				if group.grouptype == 'supergroup' then
					drua.channel_set_admin(msg.chat.id, target.id, 2)
				end
				group.govs[target.id_str] = true
				sendReply(msg, target.name .. ' is now a governor.')
			end
		end
	},

	{ -- hammer
		triggers = {
			'^/hammer',
			'^/unhammer'
		},

		command = 'hammer <user>',
		privilege = 4,
		interior = false,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if target.rank > 3 then
				sendReply(msg, target.name .. ' is too privileged to be globally banned.')
				return
			end
			if database.blacklist[target.id_str] then
				database.blacklist[target.id_str] = nil
				sendReply(msg, target.name .. ' has been globally unbanned.')
			else
				database.blacklist[target.id_str] = true
				for k,v in pairs(database.administration.groups) do
					drua.kick_user(k, target.id)
				end
				sendReply(msg, target.name .. ' has been globally banned.')
			end
		end
	},

	{ -- admin
		triggers = {
			'^/admin',
			'^/deadmin'
		},

		command = 'admin <user',
		privilege = 5,
		interior = false,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if database.administration.admins[target.id_str] then
				database.administration.admins[target.id_str] = nil
				sendReply(msg, target.name .. ' is no longer an administrator.')
			else
				if target.rank == 5 then
					sendReply(msg, target.name .. ' is greater than an administrator.')
					return
				end
				for k,v in pairs(database.administration.groups) do
					v.mods[target.id_str] = nil
					v.govs[target.id_str] = nil
				end
				database.administration.admins[target.id_str] = true
				sendReply(msg, target.name .. ' is now an administrator.')
			end
		end
	},

	{ -- gadd
		triggers = {
			'^/gadd[@'..bot.username..']*$'
		},

		command = 'gadd',
		privilege = 5,
		interior = false,

		action = function(msg)
			if database.administration.groups[msg.chat.id_str] then
				sendReply(msg, 'I am already administrating this group.')
				return
			end
			database.administration.groups[msg.chat.id_str] = {
				mods = {},
				govs = {},
				bans = {},
				flags = {},
				rules = {},
				grouptype = msg.chat.type,
				name = msg.chat.title,
				link = drua.export_link(msg.chat.id),
				photo = drua.get_photo(msg.chat.id),
				founded = os.time()
			}
			table.insert(database.administration.activity, msg.chat.id_str)
			sendReply(msg, 'I am now administrating this group.')
		end
	},

	{ -- grem
		triggers = {
			'^/grem[@'..bot.username..']*',
			'^/gremove[@'..bot.username..']*'
		},

		command = 'gremove \\[chat]',
		privilege = 5,
		interior = true,

		action = function(msg)
			local input = msg.text:input() or msg.chat.id_str
			if database.administration.groups[input] then
				database.administration.groups[input] = nil
				for i,v in ipairs(database.administration.activity) do
					if v == input then
						table.remove(database.administration.activity, i)
					end
				end
				sendReply(msg, 'I am no longer administrating that group.')
			else
				sendReply(msg, 'I do not administrate that group.')
			end
		end
	},

	{ -- broadcast
		triggers = {
			'^/broadcast[@'..bot.username..']*'
		},

		command = 'broadcast <message>',
		privilege = 5,
		interior = false,

		action = function(msg)
			local input = msg.text:input()
			if not input then
				sendReply(msg, 'Give me something to broadcast.')
				return
			end
			input = '*Admin Broadcast:*\n' .. input
			for k,v in pairs(database.administration.groups) do
				sendMessage(k, input, true, nil, true)
			end
		end
	}

}

 -- Generate trigger table.
local triggers = {}
for i,v in ipairs(commands) do
	for ind, val in ipairs(v.triggers) do
		table.insert(triggers, val)
	end
end

database.administration.help = {}
for i,v in ipairs(ranks) do
	admin_temp.help[i] = {}
end
for i,v in ipairs(commands) do
	if v.command then
		table.insert(admin_temp.help[v.privilege], v.command)
	end
end

local action = function(msg)
	for i,v in ipairs(commands) do
		for key,val in pairs(v.triggers) do
			if msg.text_lower:match(val) then
				if v.interior and not database.administration.groups[msg.chat.id_str] then
					break
				end
				if msg.chat.type ~= 'private' and get_rank(msg.from.id, msg.chat.id) < v.privilege then
					break
				end
				local res = v.action(msg, database.administration.groups[msg.chat.id_str])
				if res ~= true then
					return res
				end
			end
		end
	end
	return true
end

local cron = function()
	admin_temp.flood = {}
end

local command = 'groups'
local doc = '`Returns a list of administrated groups.\nUse /ahelp for more administrative commands.`'

return {
	action = action,
	triggers = triggers,
	cron = cron,
	doc = doc,
	command = command
}
