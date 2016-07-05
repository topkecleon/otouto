--[[
	administration.lua
	Version 1.11
	Part of the otouto project.
	© 2016 topkecleon <drew@otou.to>
	GNU General Public License, version 2

	This plugin provides self-hosted, single-realm group administration.
	It requires tg (http://github.com/vysheng/tg) with supergroup support.
	For more documentation, read the the manual (otou.to/rtfm).

	Remember to load this before blacklist.lua.

	Important notices about updates will be here!

	1.11 - Removed /kickme and /broadcast. Users should leave manually, and
	 announcements should be made via channel rather than spam. /setqotd now
	 handles forwarded messages correctly. /kick, /ban, /hammer, /mod, /admin
	 now support multiple arguments. Added get_targets function. No migration is
	 necessary.

]]--

local JSON = require('dkjson')
local drua = dofile('drua-tg.lua')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local administration = {}

function administration:init(config)
	-- Build the administration db if nonexistent.
	if not self.database.administration then
		self.database.administration = {
			admins = {},
			groups = {},
			activity = {},
			autokick_timer = os.date('%d')
		}
	end

	self.admin_temp = {
		help = {},
		flood = {}
	}

	drua.PORT = config.cli_port or 4567

	administration.flags = administration.init_flags(config.cmd_pat)
	administration.init_command(self, config)

	administration.doc = '`Returns a list of administrated groups.\nUse '..config.cmd_pat..'ahelp for more administrative commands.`'
	administration.command = 'groups [query]'

	-- In the worst case, don't send errors in reply to random messages.
	administration.error = false

end

function administration.init_flags(cmd_pat) return {
	[1] = {
		name = 'unlisted',
		desc = 'Removes this group from the group listing.',
		short = 'This group is unlisted.',
		enabled = 'This group is no longer listed in '..cmd_pat..'groups.',
		disabled = 'This group is now listed in '..cmd_pat..'groups.'
	},
	[2] = {
		name = 'antisquig',
		desc = 'Automatically removes users who post Arabic script or RTL characters.',
		short = 'This group does not allow Arabic script or RTL characters.',
		enabled = 'Users will now be removed automatically for posting Arabic script and/or RTL characters.',
		disabled = 'Users will no longer be removed automatically for posting Arabic script and/or RTL characters.',
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
		enabled = 'Users will now be removed automatically for excessive messages. Use '..cmd_pat..'antiflood to configure limits.',
		disabled = 'Users will no longer be removed automatically for excessive messages.',
		kicked = 'You were automatically kicked from GROUPNAME for flooding.'
	},
	[6] = {
		name = 'antihammer',
		desc = 'Allows globally banned users to enter this group. Note that users hammered in this group will also be banned locally.',
		short = 'This group does not acknowledge global bans.',
		enabled = 'This group will no longer remove users for being globally banned.',
		disabled = 'This group will now remove users for being globally banned.'
	}
} end

administration.antiflood = {
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

administration.ranks = {
	[0] = 'Banned',
	[1] = 'Users',
	[2] = 'Moderators',
	[3] = 'Governors',
	[4] = 'Administrators',
	[5] = 'Owner'
}

function administration:get_rank(user_id_str, chat_id_str, config)

	user_id_str = tostring(user_id_str)
	local user_id = tonumber(user_id_str)
	chat_id_str = tostring(chat_id_str)

	-- Return 5 if the user_id_str is the bot or its owner.
	if user_id == config.admin or user_id == self.info.id then
		return 5
	end

	-- Return 4 if the user_id_str is an administrator.
	if self.database.administration.admins[user_id_str] then
		return 4
	end

	if chat_id_str and self.database.administration.groups[chat_id_str] then
		-- Return 3 if the user_id_str is the governor of the chat_id_str.
		if self.database.administration.groups[chat_id_str].governor == user_id then
			return 3
		-- Return 2 if the user_id_str is a moderator of the chat_id_str.
		elseif self.database.administration.groups[chat_id_str].mods[user_id_str] then
			return 2
		-- Return 0 if the user_id_str is banned from the chat_id_str.
		elseif self.database.administration.groups[chat_id_str].bans[user_id_str] then
			return 0
		-- Return 1 if antihammer is enabled.
		elseif self.database.administration.groups[chat_id_str].flags[6] then
			return 1
		end
	end

	-- Return 0 if the user_id_str is blacklisted (and antihammer is not enabled).
	if self.database.blacklist[user_id_str] then
		return 0
	end

	-- Return 1 if the user_id_str is a regular user.
	return 1

end

-- Returns an array of "user" tables.
function administration:get_targets(msg, config)
	if msg.reply_to_message then
		local target = {}
		for k,v in pairs(msg.reply_to_message.from) do
			target[k] = v
		end
		target.name = utilities.build_name(target.first_name, target.last_name)
		target.id_str = tostring(target.id)
		target.rank = administration.get_rank(self, target.id, msg.chat.id, config)
		return { target }
	else
		local input = utilities.input(msg.text)
		if input then
			local t = {}
			for _, user in ipairs(utilities.index(input)) do
				if self.database.users[user] then
					local target = {}
					for k,v in pairs(self.database.users[user]) do
						target[k] = v
					end
					target.name = utilities.build_name(target.first_name, target.last_name)
					target.id_str = tostring(target.id)
					target.rank = administration.get_rank(self, target.id, msg.chat.id, config)
					table.insert(t, target)
				elseif tonumber(user) then
					local target = {
						id = tonumber(user),
						id_str = user,
						name = 'Unknown ('..user..')',
						rank = administration.get_rank(self, user, msg.chat.id, config)
					}
					table.insert(t, target)
				elseif user:match('^@') then
					local target = utilities.resolve_username(self, user)
					if target then
						target.rank = administration.get_rank(self, target.id, msg.chat.id, config)
						target.id_str = tostring(target.id)
						target.name = utilities.build_name(target.first_name, target.last_name)
						table.insert(t, target)
					else
						table.insert(t, { err = 'Sorry, I do not recognize that username ('..user..').' })
					end
				else
					table.insert(t, { err = 'Invalid username or ID ('..user..').' })
				end
			end
			return t
		else
			return false
		end
	end
end

function administration:mod_format(id)
	id = tostring(id)
	local user = self.database.users[id] or { first_name = 'Unknown' }
	local name = utilities.build_name(user.first_name, user.last_name)
	name = utilities.markdown_escape(name)
	local output = '• ' .. name .. ' `[' .. id .. ']`\n'
	return output
end

function administration:get_desc(chat_id, config)

	local group = self.database.administration.groups[tostring(chat_id)]
	local t = {}
	if group.link then
		table.insert(t, '*Welcome to* [' .. group.name .. '](' .. group.link .. ')*!*')
	else
		table.insert(t, '*Welcome to ' .. group.name .. '!*')
	end
	if group.motd then
		table.insert(t, '*Message of the Day:*\n' .. group.motd)
	end
	if #group.rules > 0 then
		local rulelist = '*Rules:*\n'
		for i = 1, #group.rules do
			rulelist = rulelist .. '*' .. i .. '.* ' .. group.rules[i] .. '\n'
		end
		table.insert(t, utilities.trim(rulelist))
	end
	local flaglist = ''
	for i = 1, #administration.flags do
		if group.flags[i] then
			flaglist = flaglist .. '• ' .. administration.flags[i].short .. '\n'
		end
	end
	if flaglist ~= '' then
		table.insert(t, '*Flags:*\n' .. utilities.trim(flaglist))
	end
	if group.governor then
		local gov = self.database.users[tostring(group.governor)]
		local s
		if gov then
			s = utilities.md_escape(utilities.build_name(gov.first_name, gov.last_name)) .. ' `[' .. gov.id .. ']`'
		else
			s = 'Unknown `[' .. group.governor .. ']`'
		end
		table.insert(t, '*Governor:* ' .. s)
	end
	local modstring = ''
	for k,_ in pairs(group.mods) do
		modstring = modstring .. administration.mod_format(self, k)
	end
	if modstring ~= '' then
		table.insert(t, '*Moderators:*\n' .. utilities.trim(modstring))
	end
	table.insert(t, 'Run '..config.cmd_pat..'ahelp@' .. self.info.username .. ' for a list of commands.')
	return table.concat(t, '\n\n')

end

function administration:update_desc(chat, config)
	local group = self.database.administration.groups[tostring(chat)]
	local desc = 'Welcome to ' .. group.name .. '!\n'
	if group.motd then desc = desc .. group.motd .. '\n' end
	if group.governor then
		local gov = self.database.users[tostring(group.governor)]
		desc = desc .. '\nGovernor: ' .. utilities.build_name(gov.first_name, gov.last_name) .. ' [' .. gov.id .. ']\n'
	end
	local s = '\n'..config.cmd_pat..'desc@' .. self.info.username .. ' for more information.'
	desc = desc:sub(1, 250-s:len()) .. s
	drua.channel_set_about(chat, desc)
end

function administration:kick_user(chat, target, reason, config)
	drua.kick_user(chat, target)
	local victim = target
	if self.database.users[tostring(target)] then
		victim = utilities.build_name(
				self.database.users[tostring(target)].first_name,
				self.database.users[tostring(target)].last_name
			) .. ' [' .. victim .. ']'
	end
	local group = self.database.administration.groups[tostring(chat)].name
	utilities.handle_exception(self, victim..' kicked from '..group, reason, config)
end

function administration.init_command(self_, config_)
	administration.commands = {

		{ -- generic, mostly autokicks
			triggers = { '' },

			privilege = 0,
			interior = true,

			action = function(self, msg, group, config)

				local rank = administration.get_rank(self, msg.from.id, msg.chat.id, config)
				local user = {}
				local from_id_str = tostring(msg.from.id)
				local chat_id_str = tostring(msg.chat.id)

				if rank < 2 then
					local from_name = utilities.build_name(msg.from.first_name, msg.from.last_name)

					-- banned
					if rank == 0 then
						user.do_kick = true
						user.dont_unban = true
						user.reason = 'banned'
						user.output = 'Sorry, you are banned from ' .. msg.chat.title .. '.'
					elseif group.flags[2] and ( -- antisquig
						msg.text:match(utilities.char.arabic)
						or msg.text:match(utilities.char.rtl_override)
						or msg.text:match(utilities.char.rtl_mark)
					) then
						user.do_kick = true
						user.reason = 'antisquig'
						user.output = administration.flags[2].kicked:gsub('GROUPNAME', msg.chat.title)
					elseif group.flags[3] and ( -- antisquig++
						from_name:match(utilities.char.arabic)
						or from_name:match(utilities.char.rtl_override)
						or from_name:match(utilities.char.rtl_mark)
					) then
						user.do_kick = true
						user.reason = 'antisquig++'
						user.output = administration.flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
					end

					-- antiflood
					if group.flags[5] then
						if not group.antiflood then
							group.antiflood = JSON.decode(JSON.encode(administration.antiflood))
						end
						if not self.admin_temp.flood[chat_id_str] then
							self.admin_temp.flood[chat_id_str] = {}
						end
						if not self.admin_temp.flood[chat_id_str][from_id_str] then
							self.admin_temp.flood[chat_id_str][from_id_str] = 0
						end
						if msg.sticker then -- Thanks Brazil for discarding switches.
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.sticker
						elseif msg.photo then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.photo
						elseif msg.document then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.document
						elseif msg.audio then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.audio
						elseif msg.contact then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.contact
						elseif msg.video then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.video
						elseif msg.location then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.location
						elseif msg.voice then
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.voice
						else
							self.admin_temp.flood[chat_id_str][from_id_str] = self.admin_temp.flood[chat_id_str][from_id_str] + group.antiflood.text
						end
						if self.admin_temp.flood[chat_id_str][from_id_str] > 99 then
							user.do_kick = true
							user.reason = 'antiflood'
							user.output = administration.flags[5].kicked:gsub('GROUPNAME', msg.chat.title)
							self.admin_temp.flood[chat_id_str][from_id_str] = nil
						end
					end

				end

				local new_user = user
				local new_rank = rank

				if msg.new_chat_member then

					-- I hate typing this out.
					local noob = msg.new_chat_member
					local noob_name = utilities.build_name(noob.first_name, noob.last_name)

					-- We'll make a new table for the new guy, unless he's also
					-- the original guy.
					if msg.new_chat_member.id ~= msg.from.id then
						new_user = {}
						new_rank = administration.get_rank(self,noob.id, msg.chat.id, config)
					end

					if new_rank == 0 then
						new_user.do_kick = true
						new_user.dont_unban = true
						new_user.reason = 'banned'
						new_user.output = 'Sorry, you are banned from ' .. msg.chat.title .. '.'
					elseif new_rank == 1 then
						if group.flags[3] and ( -- antisquig++
							noob_name:match(utilities.char.arabic)
							or noob_name:match(utilities.char.rtl_override)
							or noob_name:match(utilities.char.rtl_mark)
						) then
							new_user.do_kick = true
							new_user.reason = 'antisquig++'
							new_user.output = administration.flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
						elseif ( -- antibot
							group.flags[4]
							and noob.username
							and noob.username:match('bot$')
							and rank < 2
						) then
							new_user.do_kick = true
							new_user.reason = 'antibot'
						end
					else
						-- Make the new user a group admin if he's a mod or higher.
						if msg.chat.type == 'supergroup' then
							drua.channel_set_admin(msg.chat.id, msg.new_chat_member.id, 2)
						end
					end

				elseif msg.new_chat_title then
					if rank < 3 then
						drua.rename_chat(msg.chat.id, group.name)
					else
						group.name = msg.new_chat_title
						if group.grouptype == 'supergroup' then
							administration.update_desc(self, msg.chat.id, config)
						end
					end
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
				end

				if new_user ~= user and new_user.do_kick then
					administration.kick_user(self, msg.chat.id, msg.new_chat_member.id, new_user.reason, config)
					if new_user.output then
						utilities.send_message(self, msg.new_chat_member.id, new_user.output)
					end
					if not new_user.dont_unban and msg.chat.type == 'supergroup' then
						bindings.unbanChatMember(self, { chat_id = msg.chat.id, user_id = msg.from.id } )
					end
				end

				if group.flags[5] and user.do_kick and not user.dont_unban then
					if group.autokicks[from_id_str] then
						group.autokicks[from_id_str] = group.autokicks[from_id_str] + 1
					else
						group.autokicks[from_id_str] = 1
					end
					if group.autokicks[from_id_str] >= group.autoban then
						group.autokicks[from_id_str] = 0
						group.bans[from_id_str] = true
						user.dont_unban = true
						user.reason = 'antiflood autoban: ' .. user.reason
						user.output = user.output .. '\nYou have been banned for being autokicked too many times.'
					end
				end

				if user.do_kick then
					administration.kick_user(self, msg.chat.id, msg.from.id, user.reason, config)
					if user.output then
						utilities.send_message(self, msg.from.id, user.output)
					end
					if not user.dont_unban and msg.chat.type == 'supergroup' then
						bindings.unbanChatMember(self, { chat_id = msg.chat.id, user_id = msg.from.id } )
					end
				end

				if msg.new_chat_member and not new_user.do_kick then
					local output = administration.get_desc(self, msg.chat.id, config)
					utilities.send_message(self, msg.new_chat_member.id, output, true, nil, true)
				end

				-- Last active time for group listing.
				if msg.text:len() > 0 then
					for i,v in pairs(self.database.administration.activity) do
						if v == chat_id_str then
							table.remove(self.database.administration.activity, i)
							table.insert(self.database.administration.activity, 1, chat_id_str)
						end
					end
				end

				return true

			end
		},

		{ -- /groups
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('groups', true).table,

			command = 'groups \\[query]',
			privilege = 1,
			interior = false,
			doc = 'Returns a list of groups matching the query, or a list of all administrated groups.',

			action = function(self, msg, _, config)
				local input = utilities.input(msg.text)
				local search_res = ''
				local grouplist = ''
				for _, chat_id_str in ipairs(self.database.administration.activity) do
					local group = self.database.administration.groups[chat_id_str]
					if (not group.flags[1]) and group.link then -- no unlisted or unlinked groups
						grouplist = grouplist .. '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
						if input and string.match(group.name:lower(), input:lower()) then
							search_res = search_res .. '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
						end
					end
				end
				local output
				if search_res ~= '' then
					output = '*Groups matching* _' .. input .. '_ *:*\n' .. search_res
				elseif grouplist ~= '' then
					output = '*Groups:*\n' .. grouplist
				else
					output = 'There are currently no listed groups.'
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /ahelp
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('ahelp', true).table,

			command = 'ahelp \\[command]',
			privilege = 1,
			interior = false,
			doc = 'Returns a list of realm-related commands for your rank (in a private message), or command-specific help.',

			action = function(self, msg, group, config)
				local rank = administration.get_rank(self, msg.from.id, msg.chat.id, config)
				local input = utilities.get_word(msg.text_lower, 2)
				if input then
					input = input:gsub('^'..config.cmd_pat..'', '')
					local doc
					for _,action in ipairs(administration.commands) do
						if action.keyword == input then
							doc = ''..config.cmd_pat..'' .. action.command:gsub('\\','') .. '\n' .. action.doc
							break
						end
					end
					if doc then
						local output = '*Help for* _' .. input .. '_ :\n```\n' .. doc .. '\n```'
						utilities.send_message(self, msg.chat.id, output, true, nil, true)
					else
						local output = 'Sorry, there is no help for that command.\n'..config.cmd_pat..'ahelp@'..self.info.username
						utilities.send_reply(self, msg, output)
					end
				else
					local output = '*Commands for ' .. administration.ranks[rank] .. ':*\n'
					for i = 1, rank do
						for _, val in ipairs(self.admin_temp.help[i]) do
							output = output .. '• ' .. config.cmd_pat .. val .. '\n'
						end
					end
					output = output .. 'Arguments: <required> \\[optional]'
					if utilities.send_message(self, msg.from.id, output, true, nil, true) then
						if msg.from.id ~= msg.chat.id then
							utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
						end
					else
						utilities.send_message(self, msg.chat.id, output, true, nil, true)
					end
				end
			end
		},

		{ -- /ops
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('ops'):t('oplist').table,

			command = 'ops',
			privilege = 1,
			interior = true,
			doc = 'Returns a list of moderators and the governor for the group.',

			action = function(self, msg, group, config)
				local modstring = ''
				for k,_ in pairs(group.mods) do
					modstring = modstring .. administration.mod_format(self, k)
				end
				if modstring ~= '' then
					modstring = '*Moderators for ' .. msg.chat.title .. ':*\n' .. modstring
				end
				local govstring = ''
				if group.governor then
					local gov = self.database.users[tostring(group.governor)]
					if gov then
						govstring = '*Governor:* ' .. utilities.md_escape(utilities.build_name(gov.first_name, gov.last_name)) .. ' `[' .. gov.id .. ']`'
					else
						govstring = '*Governor:* Unknown `[' .. group.governor .. ']`'
					end
				end
				local output = utilities.trim(modstring) ..'\n\n' .. utilities.trim(govstring)
				if output == '\n\n' then
					output = 'There are currently no moderators for this group.'
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end

		},

		{ -- /desc
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('desc'):t('description').table,

			command = 'description',
			privilege = 1,
			interior = true,
			doc = 'Returns a description of the group (in a private message), including its motd, rules, flags, governor, and moderators.',

			action = function(self, msg, group, config)
				local output = administration.get_desc(self, msg.chat.id, config)
				if utilities.send_message(self, msg.from.id, output, true, nil, true) then
					if msg.from.id ~= msg.chat.id then
						utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
					end
				else
					utilities.send_message(self, msg.chat.id, output, true, nil, true)
				end
			end
		},

		{ -- /rules
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('rules?', true).table,

			command = 'rules \\[i]',
			privilege = 1,
			interior = true,
			doc = 'Returns the group\'s list of rules, or a specific rule.',

			action = function(self, msg, group, config)
				local output
				local input = utilities.get_word(msg.text_lower, 2)
				input = tonumber(input)
				if #group.rules > 0 then
					if input and group.rules[input] then
						output = '*' .. input .. '.* ' .. group.rules[input]
					else
						output = '*Rules for ' .. msg.chat.title .. ':*\n'
						for i,v in ipairs(group.rules) do
							output = output .. '*' .. i .. '.* ' .. v .. '\n'
						end
					end
				else
					output = 'No rules have been set for ' .. msg.chat.title .. '.'
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /motd
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('motd').table,

			command = 'motd',
			privilege = 1,
			interior = true,
			doc = 'Returns the group\'s message of the day.',

			action = function(self, msg, group, config)
				local output = 'No MOTD has been set for ' .. msg.chat.title .. '.'
				if group.motd then
					output = '*MOTD for ' .. msg.chat.title .. ':*\n' .. group.motd
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /link
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('link').table,

			command = 'link',
			privilege = 1,
			interior = true,
			doc = 'Returns the group\'s link.',

			action = function(self, msg, group, config)
				local output = 'No link has been set for ' .. msg.chat.title .. '.'
				if group.link then
					output = '[' .. msg.chat.title .. '](' .. group.link .. ')'
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /kick
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('kick', true).table,

			command = 'kick <user>',
			privilege = 2,
			interior = true,
			doc = 'Removes a user from the group. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif target.rank >= administration.get_rank(self, msg.from.id, msg.chat.id, config) then
							output = output .. target.name .. ' is too privileged to be kicked.\n'
						else
							administration.kick_user(self, msg.chat.id, target.id, 'kicked by ' .. utilities.build_name(msg.from.first_name, msg.from.last_name), config)
							output = output .. target.name .. ' has been kicked.\n'
							if msg.chat.type == 'supergroup' then
								bindings.unbanChatMember(self, { chat_id = msg.chat.id, user_id = target.id } )
							end
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /ban
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('ban', true).table,

			command = 'ban <user>',
			privilege = 2,
			interior = true,
			doc = 'Bans a user from the group. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif group.bans[target.id_str] then
							output = output .. target.name .. ' is already banned.\n'
						elseif target.rank >= administration.get_rank(self, msg.from.id, msg.chat.id, config) then
							output = output .. target.name .. ' is too privileged to be banned.\n'
						else
							administration.kick_user(self, msg.chat.id, target.id, 'banned by ' .. utilities.build_name(msg.from.first_name, msg.from.last_name), config)
							output = output .. target.name .. ' has been banned.\n'
							group.mods[target.id_str] = nil
							group.bans[target.id_str] = true
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /unban
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('unban', true).table,

			command = 'unban <user>',
			privilege = 2,
			interior = true,
			doc = 'Unbans a user from the group. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						else
							if not group.bans[target.id_str] then
								output = output .. target.name .. ' is not banned.\n'
							else
								output = output .. target.name .. ' has been unbanned.\n'
								group.bans[target.id_str] = nil
							end
							if msg.chat.type == 'supergroup' then
								bindings.unbanChatMember(self, { chat_id = msg.chat.id, user_id = target.id } )
							end
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /setmotd
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('setmotd', true):t('setqotd', true).table,

			command = 'setmotd <motd>',
			privilege = 2,
			interior = true,
			doc = 'Sets the group\'s message of the day. Markdown is supported. Pass "--" to delete the message.',

			action = function(self, msg, group, config)
				local input = utilities.input(msg.text)
				local quoted = utilities.build_name(msg.from.first_name, msg.from.last_name)
				if msg.reply_to_message and #msg.reply_to_message.text > 0 then
					input = msg.reply_to_message.text
					if msg.reply_to_message.forward_from then
						quoted = utilities.build_name(msg.reply_to_message.forward_from.first_name, msg.reply_to_message.forward_from.last_name)
					else
						quoted = utilities.build_name(msg.reply_to_message.from.first_name, msg.reply_to_message.from.last_name)
					end
				end
				if input then
					if input == '--' or input == utilities.char.em_dash then
						group.motd = nil
						utilities.send_reply(self, msg, 'The MOTD has been cleared.')
					else
						if msg.text:match('^/setqotd') then
							input = '_' .. utilities.md_escape(input) .. '_\n - ' .. utilities.md_escape(quoted)
						end
						group.motd = input
						local output = '*MOTD for ' .. msg.chat.title .. ':*\n' .. input
						utilities.send_message(self, msg.chat.id, output, true, nil, true)
					end
					if group.grouptype == 'supergroup' then
						administration.update_desc(self, msg.chat.id, config)
					end
				else
					utilities.send_reply(self, msg, 'Please specify the new message of the day.')
				end
			end
		},

		{ -- /setrules
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('setrules', true).table,

			command = 'setrules <rules>',
			privilege = 3,
			interior = true,
			doc = 'Sets the group\'s rules. Rules will be automatically numbered. Separate rules with a new line. Markdown is supported. Pass "--" to delete the rules.',

			action = function(self, msg, group, config)
				local input = msg.text:match('^'..config.cmd_pat..'setrules[@'..self.info.username..']*(.+)')
				if input == ' --' or input == ' ' .. utilities.char.em_dash then
					group.rules = {}
					utilities.send_reply(self, msg, 'The rules have been cleared.')
				elseif input then
					group.rules = {}
					input = utilities.trim(input) .. '\n'
					local output = '*Rules for ' .. msg.chat.title .. ':*\n'
					local i = 1
					for l in input:gmatch('(.-)\n') do
						output = output .. '*' .. i .. '.* ' .. l .. '\n'
						i = i + 1
						table.insert(group.rules, utilities.trim(l))
					end
					utilities.send_message(self, msg.chat.id, output, true, nil, true)
				else
					utilities.send_reply(self, msg, 'Please specify the new rules.')
				end
			end
		},

		{ -- /changerule
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('changerule', true).table,

			command = 'changerule <i> <rule>',
			privilege = 3,
			interior = true,
			doc = 'Changes a single rule. Pass "--" to delete the rule. If i is a number for which there is no rule, adds a rule by the next incremented number.',

			action = function(self, msg, group, config)
				local input = utilities.input(msg.text)
				local output = 'usage: `'..config.cmd_pat..'changerule <i> <newrule>`'
				if input then
					local rule_num = tonumber(input:match('^%d+'))
					local new_rule = utilities.input(input)
					if not rule_num then
						output = 'Please specify which rule you want to change.'
					elseif not new_rule then
						output = 'Please specify the new rule.'
					elseif new_rule == '--' or new_rule == utilities.char.em_dash then
						if group.rules[rule_num] then
							table.remove(group.rules, rule_num)
							output = 'That rule has been deleted.'
						else
							output = 'There is no rule with that number.'
						end
					else
						if not group.rules[rule_num] then
							rule_num = #group.rules + 1
						end
						group.rules[rule_num] = new_rule
						output = '*' .. rule_num .. '*. ' .. new_rule
					end
				end
				utilities.send_reply(self, msg, output, true)
			end
		},

		{ -- /setlink
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('setlink', true).table,

			command = 'setlink <link>',
			privilege = 3,
			interior = true,
			doc = 'Sets the group\'s join link. Pass "--" to regenerate the link.',

			action = function(self, msg, group, config)
				local input = utilities.input(msg.text)
				if input == '--' or input == utilities.char.em_dash then
					group.link = drua.export_link(msg.chat.id)
					utilities.send_reply(self, msg, 'The link has been regenerated.')
				elseif input then
					group.link = input
					local output = '[' .. msg.chat.title .. '](' .. input .. ')'
					utilities.send_message(self, msg.chat.id, output, true, nil, true)
				else
					utilities.send_reply(self, msg, 'Please specify the new link.')
				end
			end
		},

		{ -- /alist
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('alist').table,

			command = 'alist',
			privilege = 3,
			interior = true,
			doc = 'Returns a list of administrators. Owner is denoted with a star character.',

			action = function(self, msg, group, config)
				local output = '*Administrators:*\n'
				output = output .. administration.mod_format(self, config.admin):gsub('\n', ' ★\n')
				for id,_ in pairs(self.database.administration.admins) do
					output = output .. administration.mod_format(self, id)
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /flags
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('flags?', true).table,

			command = 'flag \\[i] ...',
			privilege = 3,
			interior = true,
			doc = 'Returns a list of flags or toggles the specified flags.',

			action = function(self, msg, group, config)
				local output = ''
				local input = utilities.input(msg.text)
				if input then
					local index = utilities.index(input)
					for _, i in ipairs(index) do
						local n = tonumber(i)
						if n and administration.flags[n] then
							if group.flags[n] == true then
								group.flags[n] = false
								output = output .. administration.flags[n].disabled .. '\n'
							else
								group.flags[n] = true
								output = output .. administration.flags[n].enabled .. '\n'
							end
						end
					end
					if output == '' then
						input = false
					end
				end
				if not input then
					output = '*Flags for ' .. msg.chat.title .. ':*\n'
					for i, flag in ipairs(administration.flags) do
						local status = group.flags[i] or false
						output = output .. '*' .. i .. '. ' .. flag.name .. '* `[' .. tostring(status) .. ']`\n• ' .. flag.desc .. '\n'
					end
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /antiflood
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('antiflood', true).table,

			command = 'antiflood \\[<type> <i>]',
			privilege = 3,
			interior = true,
			doc = 'Returns a list of antiflood values or sets one.',

			action = function(self, msg, group, config)
				if not group.flags[5] then
					utilities.send_message(self, msg.chat.id, 'antiflood is not enabled. Use `'..config.cmd_pat..'flag 5` to enable it.', true, nil, true)
				else
					if not group.antiflood then
						group.antiflood = JSON.decode(JSON.encode(administration.antiflood))
					end
					local input = utilities.input(msg.text_lower)
					local output
					if input then
						local key, val = input:match('(%a+) (%d+)')
						if not key or not val or not tonumber(val) then
							output = 'Not a valid message type or number.'
						elseif key == 'autoban' then
							group.autoban = tonumber(val)
							output = 'Users will now be autobanned after *' .. val .. '* autokicks.'
						else
							group.antiflood[key] = tonumber(val)
							output = '*' .. key:gsub('^%l', string.upper) .. '* messages are now worth *' .. val .. '* points.'
						end
					else
						output = 'usage: `'..config.cmd_pat..'antiflood <type> <i>`\nexample: `'..config.cmd_pat..'antiflood text 5`\nUse this command to configure the point values for each message type. When a user reaches 100 points, he is kicked. The points are reset each minute. The current values are:\n'
						for k,v in pairs(group.antiflood) do
							output = output .. '*'..k..':* `'..v..'`\n'
						end
						output = output .. 'Users will be banned automatically after *' .. group.autoban .. '* autokicks. Configure this with the *autoban* keyword.'
					end
					utilities.send_message(self, msg.chat.id, output, true, msg.message_id, true)
				end
			end
		},

		{ -- /mod
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('mod', true).table,

			command = 'mod <user>',
			privilege = 3,
			interior = true,
			doc = 'Promotes a user to a moderator. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						else
							if target.rank > 1 then
								output = output .. target.name .. ' is already a moderator or greater.\n'
							else
								output = output .. target.name .. ' is now a moderator.\n'
								group.mods[target.id_str] = true
								group.bans[target.id_str] = nil
							end
							if group.grouptype == 'supergroup' then
								drua.channel_set_admin(msg.chat.id, target.id, 2)
							end
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /demod
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('demod', true).table,

			command = 'demod <user>',
			privilege = 3,
			interior = true,
			doc = 'Demotes a moderator to a user. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						else
							if not group.mods[target.id_str] then
								output = output .. target.name .. ' is not a moderator.\n'
							else
								output = output .. target.name .. ' is no longer a moderator.\n'
								group.mods[target.id_str] = nil
							end
							if group.grouptype == 'supergroup' then
								drua.channel_set_admin(msg.chat.id, target.id, 0)
							end
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /gov
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('gov', true).table,

			command = 'gov <user>',
			privilege = 4,
			interior = true,
			doc = 'Promotes a user to the governor. The current governor will be replaced. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local target = targets[1]
					if target.err then
						utilities.send_reply(self, msg, target.err)
					else
						if group.governor == target.id then
							utilities.send_reply(self, msg, target.name .. ' is already the governor.')
						else
							group.bans[target.id_str] = nil
							group.mods[target.id_str] = nil
							group.governor = target.id
							utilities.send_reply(self, msg, target.name .. ' is the new governor.')
						end
						if group.grouptype == 'supergroup' then
							drua.channel_set_admin(msg.chat.id, target.id, 2)
							administration.update_desc(self, msg.chat.id, config)
						end
					end
				else
					utilities.send_reply(self, msg, 'Please specify a user via reply, username, or ID.')
				end
			end
		},

		{ -- /degov
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('degov', true).table,

			command = 'degov <user>',
			privilege = 4,
			interior = true,
			doc = 'Demotes the governor to a user. The administrator will become the new governor. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local target = targets[1]
					if target.err then
						utilities.send_reply(self, msg, target.err)
					else
						if group.governor ~= target.id then
							utilities.send_reply(self, msg, target.name .. ' is not the governor.')
						else
							group.governor = msg.from.id
							utilities.send_reply(self, msg, target.name .. ' is no longer the governor.')
						end
						if group.grouptype == 'supergroup' then
							drua.channel_set_admin(msg.chat.id, target.id, 0)
							administration.update_desc(self, msg.chat.id, config)
						end
					end
				else
					utilities.send_reply(self, msg, 'Please specify a user via reply, username, or ID.')
				end
			end
		},

		{ -- /hammer
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('hammer', true).table,

			command = 'hammer <user>',
			privilege = 4,
			interior = false,
			doc = 'Bans a user from all groups. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif self.database.blacklist[target.id_str] then
							output = output .. target.name .. ' is already globally banned.\n'
						elseif target.rank >= administration.get_rank(self, msg.from.id, msg.chat.id, config) then
							output = output .. target.name .. ' is too privileged to be globally banned.\n'
						else
							administration.kick_user(self, msg.chat.id, target.id, 'hammered by ' .. utilities.build_name(msg.from.first_name, msg.from.last_name), config)
							if #targets == 1 then
								for k,v in pairs(self.database.administration.groups) do
									if not v.flags[6] then
										v.mods[target.id_str] = nil
										drua.kick_user(k, target.id)
									end
								end
							end
							self.database.blacklist[target.id_str] = true
							if group.flags[6] == true then
								group.mods[target.id_str] = nil
								group.bans[target.id_str] = true
								output = output .. target.name .. ' has been globally and locally banned.\n'
							else
								output = output .. target.name .. ' has been globally banned.\n'
							end
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /unhammer
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('unhammer', true).table,

			command = 'unhammer <user>',
			privilege = 4,
			interior = false,
			doc = 'Removes a global ban. The target may be specified via reply, username, or ID.',

			action = function(self, msg, group, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif not self.database.blacklist[target.id_str] then
							output = output .. target.name .. ' is not globally banned.\n'
						else
							self.database.blacklist[target.id_str] = nil
							output = output .. target.name .. ' has been globally unbanned.\n'
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /admin
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('admin', true).table,

			command = 'admin <user>',
			privilege = 5,
			interior = false,
			doc = 'Promotes a user to an administrator. The target may be specified via reply, username, or ID.',

			action = function(self, msg, _, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif target.rank >= 4 then
							output = output .. target.name .. ' is already an administrator or greater.\n'
						else
							for _, group in pairs(self.database.administration.groups) do
								group.mods[target.id_str] = nil
							end
							self.database.administration.admins[target.id_str] = true
							output = output .. target.name .. ' is now an administrator.\n'
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /deadmin
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('deadmin', true).table,

			command = 'deadmin <user>',
			privilege = 5,
			interior = false,
			doc = 'Demotes an administrator to a user. The target may be specified via reply, username, or ID.',

			action = function(self, msg, _, config)
				local targets = administration.get_targets(self, msg, config)
				if targets then
					local output = ''
					for _, target in ipairs(targets) do
						if target.err then
							output = output .. target.err .. '\n'
						elseif target.rank ~= 4 then
							output = output .. target.name .. ' is not an administrator.\n'
						else
							for chat_id, group in pairs(self.database.administration.groups) do
								if group.grouptype == 'supergroup' then
									drua.channel_set_admin(chat_id, target.id, 0)
								end
							end
							self.database.administration.admins[target.id_str] = nil
							output = output .. target.name .. ' is no longer an administrator.\n'
						end
					end
					utilities.send_reply(self, msg, output)
				else
					utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID.')
				end
			end
		},

		{ -- /gadd
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('gadd', true).table,

			command = 'gadd \\[i] ...',
			privilege = 5,
			interior = false,
			doc = 'Adds a group to the administration system. Pass numbers as arguments to enable those flags immediately.\nExample usage:\n\t/gadd 1 4 5\nThis would add a group and enable the unlisted flag, antibot, and antiflood.',

			action = function(self, msg, group, config)
				if msg.chat.id == msg.from.id then
					utilities.send_message(self, msg.chat.id, 'No.')
				elseif group then
					utilities.send_reply(self, msg, 'I am already administrating this group.')
				else
					local output = 'I am now administrating this group.'
					local flags = {}
					for i = 1, #administration.flags do
						flags[i] = false
					end
					local input = utilities.input(msg.text)
					if input then
						local index = utilities.index(input)
						for _, i in ipairs(index) do
							local n = tonumber(i)
							if n and administration.flags[n] and flags[n] ~= true then
								flags[n] = true
								output = output .. '\n' .. administration.flags[n].short
							end
						end
					end
					self.database.administration.groups[tostring(msg.chat.id)] = {
						mods = {},
						governor = msg.from.id,
						bans = {},
						flags = flags,
						rules = {},
						grouptype = msg.chat.type,
						name = msg.chat.title,
						link = drua.export_link(msg.chat.id),
						photo = drua.get_photo(msg.chat.id),
						founded = os.time(),
						autokicks = {},
						autoban = 3
					}
					administration.update_desc(self, msg.chat.id, config)
					table.insert(self.database.administration.activity, tostring(msg.chat.id))
					utilities.send_reply(self, msg, output)
					drua.channel_set_admin(msg.chat.id, self.info.id, 2)
				end
			end
		},

		{ -- /grem
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('grem', true):t('gremove', true).table,

			command = 'gremove \\[chat]',
			privilege = 5,
			interior = false,
			doc = 'Removes a group from the administration system.',

			action = function(self, msg)
				local input = utilities.input(msg.text) or tostring(msg.chat.id)
				local output
				if self.database.administration.groups[input] then
					local chat_name = self.database.administration.groups[input].name
					self.database.administration.groups[input] = nil
					for i,v in ipairs(self.database.administration.activity) do
						if v == input then
							table.remove(self.database.administration.activity, i)
						end
					end
					output = 'I am no longer administrating _' .. utilities.md_escape(chat_name) .. '_.'
				else
					if input == tostring(msg.chat.id) then
						output = 'I do not administrate this group.'
					else
						output = 'I do not administrate that group.'
					end
				end
				utilities.send_message(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- /glist
			triggers = utilities.triggers(self_.info.username, config_.cmd_pat):t('glist', false).table,

			command = 'glist',
			privilege = 5,
			interior = false,
			doc = 'Returns a list (in a private message) of all administrated groups with their governors and links.',

			action = function(self, msg, group, config)
				local output = ''
				if utilities.table_size(self.database.administration.groups) > 0 then
					for k,v in pairs(self.database.administration.groups) do
						output = output .. '[' .. utilities.md_escape(v.name) .. '](' .. v.link .. ') `[' .. k .. ']`\n'
						if v.governor then
							local gov = self.database.users[tostring(v.governor)]
							output = output .. '★ ' .. utilities.md_escape(utilities.build_name(gov.first_name, gov.last_name)) .. ' `[' .. gov.id .. ']`\n'
						end
					end
				else
					output = 'There are no groups.'
				end
				if utilities.send_message(self, msg.from.id, output, true, nil, true) then
					if msg.from.id ~= msg.chat.id then
						utilities.send_reply(self, msg, 'I have sent you the requested information in a private message.')
					end
				end
			end
		}

	}

	administration.triggers = {''}

	-- Generate help messages and ahelp keywords.
	self_.database.administration.help = {}
	for i,_ in ipairs(administration.ranks) do
		self_.admin_temp.help[i] = {}
	end
	for _,v in ipairs(administration.commands) do
		if v.command then
			table.insert(self_.admin_temp.help[v.privilege], v.command)
			if v.doc then
				v.keyword = utilities.get_word(v.command, 1)
			end
		end
	end
end

function administration:action(msg, config)
	for _,command in ipairs(administration.commands) do
		for _,trigger in pairs(command.triggers) do
			if msg.text_lower:match(trigger) then
				if
					(command.interior and not self.database.administration.groups[tostring(msg.chat.id)])
					or administration.get_rank(self, msg.from.id, msg.chat.id, config) < command.privilege
				then
					break
				end
				local res = command.action(self, msg, self.database.administration.groups[tostring(msg.chat.id)], config)
				if res ~= true then
					return res
				end
			end
		end
	end
	return true
end

function administration:cron()
	self.admin_temp.flood = {}
	if os.date('%d') ~= self.database.administration.autokick_timer then
		self.database.administration.autokick_timer = os.date('%d')
		for _,v in pairs(self.database.administration.groups) do
			v.autokicks = {}
		end
	end
end

return administration
