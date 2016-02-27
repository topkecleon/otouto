--[[
	administration.lua
	Version 1.3
	Part of the otouto project.
	© 2016 topkecleon <drew@otou.to>
	GNU General Public License, version 2

	This plugin provides self-hosted, single-realm group administration.
	It requires tg (http://github.com/vysheng/tg) with supergroup support.
	For more documentation, view the readme or the manual (otou.to/rtfm).

	Important notices about updates will be here!
	Remember to load this before blacklist.lua.

	The global banlist has been merged with the blacklist. This merge will occur
	automatically on versions 1.1 and 1.2.

	Group rules will now be stored in tables rather than pre-numbered strings.
	Automatic migration will be in effect in versions 1.2 and 1.3.
]]--

 -- Build the administration db if nonexistent.
if not database.administration then
	database.administration = {
		global = {
			admins = {}
		}
	}
end

 -- Create the blacklist db if nonexistant.
database.blacklist = database.blacklist or {}

 -- Migration code: Remove this in v1.3.
 -- Global ban list has been merged with blacklist.
if database.administration.global.bans then
	for k in pairs(database.administration.global.bans) do
		database.blacklist[k] = true
	end
	database.administration.global.bans = nil
end

 -- Migration code: Remove this in v1.4.
 -- Rule lists have been converted from strings to tables.
for k,v in pairs(database.administration) do
	if type(v.rules) == 'string' then
		local t = {}
		for l in v.rules:gmatch('(.-)\n') do
			table.insert(t, l:sub(6))
		end
		v.rules = t
	end
end

local sender = dofile('lua-tg/sender.lua')
local tg = sender(localhost, config.cli_port)
local last_admin_cron = os.date('%M', os.time())

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
		desc = 'Prevents the addition of bots by non-moderators. Only useful in non-supergroups.',
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

	if database.administration.global.admins[target] then
		return 4
	end

	if chat and database.administration[chat] then
		if database.administration[chat].govs[target] then
			return 3
		elseif database.administration[chat].mods[target] then
			return 2
		elseif database.administration[chat].bans[target] then
			return 0
		end
	end

	if database.blacklist[target] then
		return 0
	end

	return 1

end

local get_target = function(msg)

	local target = {}
	if msg.reply_to_message then
		local user = msg.reply_to_message.from
		if msg.reply_to_message.new_chat_participant then
			user = msg.reply_to_message.new_chat_participant
		elseif msg.reply_to_message.left_chat_participant then
			user = msg.reply_to_message.left_chat_participant
		end
		target.id = user.id
		target.name = user.first_name
		if user.last_name then
			target.name = user.first_name .. ' ' .. user.last_name
		end
	else
		target.name = 'User'
		local input = get_word(msg.text, 2)
		if not input then
			target.err = 'Please provide a username or ID.'
		else
			target.id = resolve_username(input)
			if target.id == nil then
				target.err = 'Sorry, I do not recognize that username.'
			elseif target.id == false then
				target.err = 'Invalid ID or username.'
			end
		end
	end

	if target.id then
		target.id_str = tostring(target.id)
		target.rank = get_rank(target.id, msg.chat.id)
	end

	return target

end

local kick_user = function(target, chat)

	target = tonumber(target)
	chat = tostring(chat)

	if database.administration[chat].grouptype == 'group' then
		tg:chat_del_user(tonumber(chat), target)
	else
		tg:channel_kick(chat, target)
	end

end

local get_photo = function(chat)

	local filename = tg:load_chat_photo(chat)
	if filename:find('FAIL') then
		print('Error downloading photo for group ' .. chat .. '.')
		return
	end
	filename = filename:gsub('Saved to ', '')
	return filename

end

local get_desc = function(chat_id)

	local group = database.administration[tostring(chat_id)]
	local output
	if group.link then
		output = '*Welcome to* [' .. group.name .. '](' .. group.link .. ')*!*'
	else
		output = '*Welcome to* _' .. group.name .. '_*!*'
	end
	if group.motd then
		output = output .. '\n\n*Message of the Day:*\n' .. group.motd
	end
	if group.rules then
		output = output .. '\n\n*Rules:*\n'
		for i,v in ipairs(group.rules) do
			output = output .. '*' .. i .. '.* ' .. v .. '\n'
		end
	end
	if group.flags then
		output = output .. '\n*Flags:*\n'
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

		action = function(msg)
			if get_rank(msg.from.id, msg.chat.id) > 1 then
				return true
			end
			if not database.administration[msg.chat.id_str].flags[2] == true then
				return true
			end
			kick_user(msg.from.id, msg.chat.id)
			sendMessage(msg.from.id, flags[2].kicked:gsub('GROUPNAME', msg.chat.title))
		end
	},

	{ -- generic
		triggers = {
			''
		},

		privilege = 0,
		interior = true,

		action = function(msg)

			local rank = get_rank(msg.from.id, msg.chat.id)
			local group = database.administration[msg.chat.id_str]

			-- banned
			if rank == 0 then
				kick_user(msg.from.id, msg.chat.id)
				sendMessage(msg.from.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
				return
			end

			if rank < 2 then

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.from.name:match('[\216-\219][\128-\191]') or msg.from.name:match('‮') or msg.from.name:match('‏') then
						kick_user(msg.from.id, msg.chat.id)
						sendMessage(msg.from.id, flags[3].kicked:gsub('GROUPNAME', msg.chat.title))
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
					kick_user(msg.new_chat_participant.id, msg.chat.id)
					sendMessage(msg.new_chat_participant.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
					return
				end

				-- antisquig Strict
				if group.flags[3] == true then
					if msg.new_chat_participant.name:match('[\216-\219][\128-\191]') or msg.new_chat_participant.name:match('‮') or msg.new_chat_participant.name:match('‏') then
						kick_user(msg.new_chat_participant.id, msg.chat.id)
						sendMessage(msg.new_chat_participant.id, flags[3].kicked:gsub('GROUPNAME', msg.chat.title))
						return
					end
				end

				-- antibot
				if msg.new_chat_participant.username and msg.new_chat_participant.username:match('bot$') then
					if rank < 2 and group.flags[4] == true then
						kick_user(msg.new_chat_participant.id, msg.chat.id)
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
				end
				return

			elseif msg.delete_chat_photo then

				if group.grouptype == 'group' then
					if rank < 3 then
						tg:chat_set_photo(msg.chat.id, group.photo)
					else
						group.photo = nil
					end
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
			for k,v in pairs(database.administration) do
				-- no "global" or unlisted groups
				if tonumber(k) and not v.flags[1] then
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
				for ind, val in ipairs(database.administration.global.help[i]) do
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

		action = function(msg)
			local modstring = ''
			for k,v in pairs(database.administration[msg.chat.id_str].mods) do
				modstring = modstring .. '• ' .. v .. ' (' .. k .. ')\n'
			end
			if modstring ~= '' then
				modstring = '*Moderators for* _' .. msg.chat.title .. '_ *:*\n' .. modstring
			end
			local govstring = ''
			for k,v in pairs(database.administration[msg.chat.id_str].govs) do
				govstring = govstring .. '• ' .. v .. ' (' .. k .. ')\n'
			end
			if govstring ~= '' then
				govstring = '*Governors for* _' .. msg.chat.title .. '_ *:*\n' .. govstring
			end
			local adminstring = '*Administrators:*\n• ' .. config.admin_name .. ' (' .. config.admin .. ')\n'
			for k,v in pairs(database.administration.global.admins) do
				adminstring = adminstring .. '• ' .. v .. ' (' .. k .. ')\n'
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

		action = function(msg)
			local output = 'No rules have been set for ' .. msg.chat.title .. '.'
			if database.administration[msg.chat.id_str].rules then
				output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
				for i,v in ipairs(database.administration[msg.chat.id_str].rules) do
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

		action = function(msg)
			local output = 'No MOTD has been set for ' .. msg.chat.title .. '.'
			if database.administration[msg.chat.id_str].motd then
				output = '*MOTD for* _' .. msg.chat.title .. '_ *:*\n' .. database.administration[msg.chat.id_str].motd
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

		action = function(msg)
			local output = 'No link has been set for ' .. msg.chat.title .. '.'
			if database.administration[msg.chat.id_str].link then
				output = '[' .. msg.chat.title .. '](' .. database.administration[msg.chat.id_str].link .. ')'
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
				kick_user(msg.from.id, msg.chat.id)
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
			kick_user(target.id, msg.chat.id)
			sendMessage(msg.chat.id, target.name .. ' has been kicked.')
		end
	},

	{ -- ban
		triggers = {
			'^/ban[@'..bot.username..']*'
		},

		command = 'ban <user>',
		privilege = 2,
		interior = true,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if target.rank > 1 then
				sendReply(msg, target.name .. ' is too privileged to be banned.')
				return
			end
			if database.administration[msg.chat.id_str].bans[target.id_str] then
				sendReply(msg, target.name .. ' is already banned.')
				return
			end
			kick_user(target.id, msg.chat.id)
			database.administration[msg.chat.id_str].bans[target.id_str] = true
			sendMessage(msg.chat.id, target.name .. ' has been banned.')
		end
	},

	{ -- unban
		triggers = {
			'^/unban[@'..bot.username..']*'
		},

		command = 'unban <user>',
		privilege = 2,
		interior = true,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if not database.administration[msg.chat.id_str].bans[target.id_str] then
				if database.blacklist[target.id_str] then
					sendReply(msg, target.name .. ' is globally banned.')
				else
					sendReply(msg, target.name .. ' is not banned.')
				end
				return
			end
			database.administration[msg.chat.id_str].bans[target.id_str] = nil
			sendMessage(msg.chat.id, target.name .. ' has been unbanned.')
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

		action = function(msg)
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
			if not database.administration[msg.chat.id_str].rules then
				local output = 'Sorry, there are no rules to change. Please use /setrules.\n' .. usage
				sendMessage(msg.chat.id, output, true, msg.message_id, true)
				return
			end
			if not database.administration[msg.chat.id_str].rules[rule_num] then
				rule_num = #database.administration[msg.chat.id_str].rules + 1
			end
			if rule_new == '--' or rule_new == '—' then
				if database.administration[msg.chat.id_str].rules[rule_num] then
					table.remove(database.administration[msg.chat.id_str].rules, rule_num)
					sendReply(msg, 'That rule has been deleted.')
				else
					sendReply(msg, 'There is no rule with that number.')
				end
				return
			end
			database.administration[msg.chat.id_str].rules[rule_num] = rule_new
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

		action = function(msg)
			local input = msg.text:match('^/setrules[@'..bot.username..']*(.+)')
			if not input then
				sendReply(msg, '/setrules [rule]\n<rule>\n[rule]\n...')
				return
			end
			database.administration[msg.chat.id_str].rules = {}
			input = input:trim() .. '\n'
			local output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
			local i = 1
			for l in input:gmatch('(.-)\n') do
				output = output .. '*' .. i .. '.* ' .. l .. '\n'
				i = i + 1
				table.insert(database.administration[msg.chat.id_str].rules, l:trim())
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

		action = function(msg)
			local input = msg.text:input()
			if not input then
				sendReply(msg, '/' .. command)
				return
			end
			input = input:trim()
			database.administration[msg.chat.id_str].motd = input
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

		action = function(msg)
			local input = msg.text:input()
			if not input then
				sendReply(msg, '/' .. command)
				return
			end
			database.administration[msg.chat.id_str].link = input
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

		action = function(msg)
			local input = msg.text:input()
			if input then
				input = get_word(input, 1)
				input = tonumber(input)
				if not input or not flags[input] then input = false end
			end
			if not input then
				local output = '*Flags for* _' .. msg.chat.title .. '_ *:*\n'
				for i,v in ipairs(flags) do
					local status = database.administration[msg.chat.id_str].flags[i] or false
					output = output .. '`[' .. i .. ']` *' .. v.name .. '*` = ' .. tostring(status) .. '`\n• ' .. v.desc .. '\n'
				end
				sendMessage(msg.chat.id, output, true, nil, true)
				return
			end
			local output
			if database.administration[msg.chat.id_str].flags[input] == true then
				database.administration[msg.chat.id_str].flags[input] = false
				sendReply(msg, flags[input].disabled)
			else
				database.administration[msg.chat.id_str].flags[input] = true
				sendReply(msg, flags[input].enabled)
			end
		end
	},

	{ -- mod
		triggers = {
			'^/mod[@'..bot.username..']*$'
		},

		command = 'mod <user>',
		privilege = 3,
		interior = true,

		action = function(msg)
			if not msg.reply_to_message then
				sendReply(msg, 'This command must be run via reply.')
				return
			end
			local target = get_target(msg)
			if target.rank > 1 then
				sendReply(msg, target.name .. ' is already a moderator or greater.')
				return
			end
			if database.administration[msg.chat.id_str].grouptype == 'supergroup' then
				tg:channel_set_admin(msg.chat.id, target, 1)
			end
			database.administration[msg.chat.id_str].mods[target.id_str] = target.name
			sendReply(msg, target.name .. ' is now a moderator.')
		end
	},

	{ -- demod
		triggers = {
			'^/demod[@'..bot.username..']*'
		},

		command = 'demod <user>',
		privilege = 3,
		interior = true,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if target.rank ~= 2 then
				sendReply(msg, target.name .. ' is not a moderator.')
				return
			end
			if database.administration[msg.chat.id_str].grouptype == 'supergroup' then
				tg:channel_set_admin(msg.chat.id, target, 0)
			end
			database.administration[msg.chat.id_str].mods[target.id_str] = nil
			sendReply(msg, target.name .. ' is no longer a moderator.')
		end

	},

	{ -- gov
		triggers = {
			'^/gov[@'..bot.username..']*$'
		},

		command = 'gov <user>',
		privilege = 4,
		interior = true,

		action = function(msg)
			if not msg.reply_to_message then
				sendReply(msg, 'This command must be run via reply.')
				return
			end
			local target = get_target(msg)
			if target.rank > 2 then
				sendReply(msg, target.name .. ' is already a governor or greater.')
				return
			elseif target.rank == 2 then
				database.administration[msg.chat.id_str].mods[target.id_str] = nil
			end
			if database.administration[msg.chat.id_str].grouptype == 'supergroup' then
				tg:channel_set_admin(msg.chat.id, target, 1)
			end
			database.administration[msg.chat.id_str].govs[target.id_str] = target.name
			sendReply(msg, target.name .. ' is now a governor.')
		end
	},

	{ --degov
		triggers = {
			'^/degov[@'..bot.username..']*'
		},

		command = 'degov <user>',
		privilege = 4,
		interior = true,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if target.rank ~= 3 then
				sendReply(msg, target.name .. ' is not a governor.')
				return
			end
			if database.administration[msg.chat.id_str].grouptype == 'supergroup' then
				tg:channel_set_admin(msg.chat.id, target, 0)
			end
			database.administration[msg.chat.id_str].govs[target.id_str] = nil
			sendReply(msg, target.name .. ' is no longer a governor.')
		end
	},

	{ -- hammer
		triggers = {
			'^/hammer[@'..bot.username..']*',
			'^/banall[@'..bot.username..']*'
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
				sendReply(msg, target.name .. ' is already globally banned.')
				return
			end
			for k,v in pairs(database.administration) do
				if tonumber(k) then
					kick_user(target.id, k)
				end
			end
			database.blacklist[target.id_str] = true
			sendReply(msg, target.name .. ' has been globally banned.')
		end
	},

	{ -- unhammer
		triggers = {
			'^/unhammer[@'..bot.username..']*',
			'^/unbanall[@'..bot.username..']*'
		},

		command = 'unhammer <user>',
		privilege = 4,
		interior = false,

		action = function(msg)
			local target = get_target(msg)
			if target.err then
				sendReply(msg, target.err)
				return
			end
			if not database.blacklist[target.id_str] then
				sendReply(msg, target.name .. ' is not globally banned.')
				return
			end
			database.blacklist[target.id_str] = nil
			sendReply(msg, target.name .. ' has been globally unbanned.')
		end
	},

	{ -- admin
		triggers = {
			'^/admin[@'..bot.username..']*$'
		},

		command = 'admin <user>',
		privilege = 5,
		interior = false,

		action = function(msg)
			if not msg.reply_to_message then
				sendReply(msg, 'This command must be run via reply.')
				return
			end
			local target = get_target(msg)
			if target.rank > 3 then
				sendReply(msg, target.name .. ' is already an administrator or greater.')
				return
			elseif target.rank == 2 then
				database.administration[msg.chat.id_str].mods[target.id_str] = nil
			elseif target.rank == 3 then
				database.administration[msg.chat.id_str].govs[target.id_str] = nil
			end
			database.administration.global.admins[target.id_str] = target.name
			sendReply(msg, target.name .. ' is now an administrator.')
		end
	},

	{ -- deadmin
		triggers = {
			'^/deadmin[@'..bot.username..']*'
		},

		command = 'deadmin <user>',
		privilege = 5,
		interior = false,

		action = function(msg)
			local target = get_target(msg)
			if target.rank ~= 4 then
				sendReply(msg, target.name .. ' is not an administrator.')
				return
			end
			database.administration.global.admins[target.id_str] = nil
			sendReply(msg, target.name .. ' is no longer an administrator.')
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
			if database.administration[msg.chat.id_str] then
				sendReply(msg, 'I am already administrating this group.')
				return
			end
			database.administration[msg.chat.id_str] = {
				mods = {},
				govs = {},
				bans = {},
				flags = {},
				grouptype = msg.chat.type,
				name = msg.chat.title,
				founded = os.time()
			}
			if msg.chat.type == 'group' then
				database.administration[msg.chat.id_str].photo = get_photo(msg.chat.id)
				database.administration[msg.chat.id_str].link = tg:export_chat_link(msg.chat.id)
			end
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
				if database.administration[input] then
					database.administration[input] = nil
					sendReply(msg, 'I am no longer administrating that group.')
				else
					sendReply(msg, 'I do not administrate that group.')
				end
			else
				if database.administration[msg.chat.id_str] then
					database.administration[msg.chat.id_str] = nil
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
			for k,v in pairs(database.administration) do
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
	for key,val in pairs(v.triggers) do
		table.insert(triggers, val)
	end
end

database.administration.global.help = {}
for i,v in pairs(ranks) do
	database.administration.global.help[i] = {}
end
for i,v in ipairs(commands) do
	if v.command then
		table.insert(database.administration.global.help[v.privilege], v.command)
	end
end


local action = function(msg)
	for i,v in ipairs(commands) do
		for key,val in pairs(v.triggers) do
			if msg.text_lower:match(val) then
				if v.interior and not database.administration[msg.chat.id_str] then
					break
				end
				if msg.chat.type ~= 'private' and get_rank(msg.from.id, msg.chat.id) < v.privilege then
					break
				end
				local res = v.action(msg)
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
