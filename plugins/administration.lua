--[[
	administration.lua
	Version 1.5
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
]]--

 -- Build the administration db if nonexistent.
if not database.administration then
	database.administration = {
		admins = {},
		groups = {}
	}
end

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

local sender = dofile('lua-tg/sender.lua')
tg = sender('localhost', config.cli_port)

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
		name = 'antisquig Strict',
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
	}
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

local kick_user = function(chat, target)

	chat = math.abs(chat)

	if chat > 1000000000000 then
		chat = chat - 1000000000000
		tg:_send('channel_kick channel#' .. chat .. ' user#' .. target .. '\n')
	else
		tg:_send('chat_del_user chat#' .. chat .. ' user#' .. target .. '\n')
	end

end

local get_photo = function(chat)

	chat = math.abs(chat)

	local filename

	if chat > 1000000000000 then
		chat = chat - 1000000000000
		filename = tg:_send('load_channel_photo channel#' .. chat .. '\n', true)
	else
		filename = tg:_send('load_chat_photo chat#' .. chat .. '\n', true)
	end

	if filename:find('FAIL') then
		print('Error downloading photo for group ' .. chat .. '.')
		return
	end
	filename = filename:gsub('Saved to ', '')
	return filename

end

local get_link = function(chat)

	chat = math.abs(chat)
	if chat > 1000000000000 then
		chat = chat - 1000000000000
		return tg:_send('export_channel_link channel#' .. chat .. '\n', true)
	else
		return tg:_send('export_chat_link chat#' .. chat .. '\n', true)
	end

end

local get_desc = function(chat_id)

	local group = database.administration.groups[tostring(chat_id)]
	local output
	if group.link then
		output = '*Welcome to* [' .. group.name .. '](' .. group.link .. ')*!*'
	else
		output = '*Welcome to* _' .. group.name .. '_*!*'
	end
	if group.motd then
		output = output .. '\n\n*Message of the Day:*\n' .. group.motd
	end
	if #group.rules > 0 then
		output = output .. '\n\n*Rules:*'
		for i,v in ipairs(group.rules) do
			output = output .. '\n*' .. i .. '.* ' .. v
		end
	end
	if group.flags then
		output = output .. '\n\n*Flags:*\n'
		for i = 1, #flags do
			if group.flags[i] then
				output = output .. '• ' .. flags[i].short .. '\n'
			end
		end
	end
	return output

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
			kick_user(msg.chat.id, msg.from.id)
			local output = flags[2].kicked:gsub('GROUPNAME', msg.chat.title)
			sendMessage(msg.from.id, output)
		end
	},

	{ -- generic
		triggers = {
			''
		},

		privilege = 0,
		interior = true,

		action = function(msg, group)

			local rank = get_rank(msg.from.id, msg.chat.id)

			-- banned
			if rank == 0 then
				kick_user(msg.chat.id, msg.from.id)
				sendMessage(msg.from.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
				return
			end

			if rank < 2 then

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.from.name:match('[\216-\219][\128-\191]') or msg.from.name:match('‮') or msg.from.name:match('‏') then
						kick_user(msg.chat.id, msg.from.id)
						local output = flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
						sendMessage(msg.from.id, output)
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
					kick_user(msg.chat.id, msg.new_chat_participant.id)
					sendMessage(msg.new_chat_participant.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
					return
				end

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.new_chat_participant.name:match('[\216-\219][\128-\191]') or msg.new_chat_participant.name:match('‮') or msg.new_chat_participant.name:match('‏') then
						kick_user(msg.chat.id, msg.new_chat_participant.id)
						local output = flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
						sendMessage(msg.new_chat_participant.id, output)
						return
					end
				end

				-- antibot
				if msg.new_chat_participant.username and msg.new_chat_participant.username:match('bot$') then
					if rank < 2 and group.flags[4] == true then
						kick_user(msg.chat.id, msg.new_chat_participant.id)
						return
					end
				else
					local output = get_desc(msg.chat.id)
					sendMessage(msg.new_chat_participant.id, output, true, nil, true)
					return
				end

			elseif msg.new_chat_title then

				if rank < 3 then
					tg:rename_chat(msg.chat.id, group.name)
				else
					group.name = msg.new_chat_title
				end
				return

			elseif msg.new_chat_photo then

				if group.grouptype == 'group' then
					if rank < 3 then
						tg:chat_set_photo(msg.chat.id, group.photo)
					else
						group.photo = get_photo(msg.chat.id)
					end
				else
					group.photo = get_photo(msg.chat.id)
				end
				return

			elseif msg.delete_chat_photo then

				if group.grouptype == 'group' then
					if rank < 3 then
						tg:chat_set_photo(msg.chat.id, group.photo)
					else
						group.photo = nil
					end
				else
					group.photo = nil
				end
				return

			end

			return true

		end
	},

	{ -- groups
		triggers = {
			'^/groups[@'..bot.username..']*$',
			'^/glist[@'..bot.username..']*$'
		},

		command = 'groups',
		privilege = 1,
		interior = false,

		action = function(msg)
			local output = ''
			for k,v in pairs(database.administration.groups) do
				-- no unlisted groups
				if not v.flags[1] then
					if v.link then
						output = output .. '• [' .. v.name .. '](' .. v.link .. ')\n'
					else
						output = output .. '• ' .. v.name .. '\n'
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
			'^/ahelp[@'..bot.username..']*$'
		},

		command = 'ahelp',
		privilege = 1,
		interior = true,

		action = function(msg)
			local rank = get_rank(msg.from.id, msg.chat.id)
			local output = '*Commands for ' .. ranks[rank] .. ':*\n'
			for i = 1, rank do
				for ind, val in ipairs(database.administration.help[i]) do
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
			'^/alist[@'..bot.username..']*$',
			'^/ops[@'..bot.username..']*$',
			'^/oplist[@'..bot.username..']*$'
		},

		command = 'ops',
		privilege = 1,
		interior = true,

		action = function(msg, group)
			local mod_format = function(id)
				id = tostring(id)
				local user = database.users[id] or { first_name = 'Unknown' }
				local name = user.first_name
				if user.last_name then name = user.first_name .. ' ' .. user.last_name end
				name = markdown_escape(name)
				local output = '• ' .. name .. ' `[' .. id .. ']`\n'
				return output
			end
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
			local adminstring = '*Administrators:*\n' .. mod_format(config.admin)
			for k,v in pairs(database.administration.admins) do
				adminstring = adminstring .. mod_format(k)
			end
			local output = modstring .. govstring .. adminstring
			sendMessage(msg.chat.id, output, true, nil, true)
		end

	},

	{ -- desc
		triggers = {
			'^/desc[@'..bot.username..']*$',
			'^/description[@'..bot.username..']*$'
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
			'^/rules[@'..bot.username..']*$'
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
			'^/motd[@'..bot.username..']*',
			'^/description[@'..bot.username..']*'
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
			'^/link[@'..bot.username..']*'
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
				kick_user(msg.chat.id, msg.from.id)
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
			kick_user(msg.chat.id, target.id)
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
				kick_user(msg.chat.id, target.id)
				sendReply(msg, target.name .. ' has been banned.')
			end
		end
	},

	{ -- changerule
		triggers = {
			'^/changerule',
			'^/changerule@' .. bot.username
		},

		command = 'changerule <i> <newrule>',
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

		command = 'setrules <rule1> \\n \\[rule2] ...',
		privilege = 3,
		interior = true,

		action = function(msg, group)
			local input = msg.text:match('^/setrules[@'..bot.username..']* (.+)')
			if not input then
				sendReply(msg, '/setrules [rule]\n<rule>\n[rule]\n...')
				return
			elseif input == '--' or input == '—' then
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
				sendReply(msg, 'Please specify the new message of the day.')
				return
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
				group.link = get_link(msg.chat.id)
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
					tg:channel_set_admin(msg.chat.id, target, 0)
				end
				group.mods[target.id_str] = nil
				sendReply(msg, target.name .. ' is no longer a moderator.')
			else
				if target.rank > 2 then
					sendReply(msg, target.name .. ' is greater than a moderator.')
					return
				end
				if group.grouptype == 'supergroup' then
					tg:channel_set_admin(msg.chat.id, target, 1)
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
					tg:channel_set_admin(msg.chat.id, target, 0)
				end
				group.govs[target.id_str] = nil
				sendReply(msg, target.name .. ' is no longer a governor.')
			else
				if target.rank > 3 then
					sendReply(msg, target.name .. ' is greater than a governor.')
					return
				end
				if target.rank == 2 then
					group.mods[target.id_str] = nil
				end
				if group.grouptype == 'supergroup' then
					tg:channel_set_admin(msg.chat.id, target, 1)
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
					kick_user(k, target.id)
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
				link = get_link(msg.chat.id),
				photo = get_photo(msg.chat.id),
				founded = os.time()
			}
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
			local input = msg.text:input()
			if input then
				if database.administration.groups[input] then
					database.administration.groups[input] = nil
					sendReply(msg, 'I am no longer administrating that group.')
				else
					sendReply(msg, 'I do not administrate that group.')
				end
			else
				if database.administration.groups[msg.chat.id_str] then
					database.administration.groups[msg.chat.id_str] = nil
					sendReply(msg, 'I am no longer administrating this group.')
				else
					sendReply(msg, 'I do not administrate this group.')
				end
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
				if tonumber(k) then
					sendMessage(k, input, true, nil, true)
				end
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
	database.administration.help[i] = {}
end
for i,v in ipairs(commands) do
	if v.command then
		table.insert(database.administration.help[v.privilege], v.command)
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
	tg = sender(localhost, config.cli_port)
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
