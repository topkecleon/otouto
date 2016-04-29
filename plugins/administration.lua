--[[
	administration.lua
	Version 1.8.2
	Part of the otouto project.
	© 2016 topkecleon <drew@otou.to>
	GNU General Public License, version 2

	This plugin provides self-hosted, single-realm group administration.
	It requires tg (http://github.com/vysheng/tg) with supergroup support.
	For more documentation, view the readme or the manual (otou.to/rtfm).

	Remember to load this before blacklist.lua.

	Important notices about updates will be here!

	1.7 - Added antiflood (flag 5). Fixed security flaw. Renamed flag 3
	("antisquig Strict" -> "antisquig++"). Added /alist for governors to list
	administrators. Back to single-governor groups as originally intended. Auto-
	matic migration through 1.8.

	1.8 - Group descriptions will be updated automatically. Fixed markdown
	stuff. Removed /kickme.

	1.8.1 - /rule <i> will return that numbered rule, if it exists.

	1.8.2 - Will now attempt to unban users kicked from supergroups. Other small
	changes.

]]--

local JSON = require('dkjson')
local drua = dofile('drua-tg/drua-tg.lua')
local bindings = require('bindings')
local utilities = require('utilities')

local administration = {}

function administration:init()
	-- Build the administration db if nonexistent.
	if not self.database.administration then
		self.database.administration = {
			admins = {},
			groups = {},
			activity = {}
		}
	end

	self.admin_temp = {
		help = {},
		flood = {}
	}

	-- Migration code: Remove this in v1.9.
	-- Groups have single governors now.
	for _,group in pairs(self.database.administration.groups) do
		if group.govs then
			for gov, _ in pairs(group.govs) do
				group.governor = gov
				break
			end
		end
		group.govs = nil
	end

	drua.PORT = self.config.cli_port or 4567

	administration.init_command(self)

end

administration.flags = {
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

function administration:get_rank(target, chat)

	target = tostring(target)
	if chat then
		chat = tostring(chat)
	end

	if tonumber(target) == self.config.admin or tonumber(target) == self.info.id then
		return 5
	end

	if self.database.administration.admins[target] then
		return 4
	end

	if chat and self.database.administration.groups[chat] then
		if self.database.administration.groups[chat].governor == tonumber(target) then
			return 3
		elseif self.database.administration.groups[chat].mods[target] then
			return 2
		elseif self.database.administration.groups[chat].bans[target] then
			return 0
		end
	end

	if self.database.blacklist[target] then
		return 0
	end

	return 1

end

function administration:get_target(msg)

	local target = utilities.user_from_message(self, msg)
	if target.id then
		target.rank = administration.get_rank(self, target.id, msg.chat.id)
	end
	return target

end

function administration:mod_format(id)
	id = tostring(id)
	local user = self.database.users[id] or { first_name = 'Unknown' }
	local name = utilities.build_name(user.first_name, user.last_name)
	name = utilities.markdown_escape(name)
	local output = '• ' .. name .. ' `[' .. id .. ']`\n'
	return output
end

function administration:get_desc(chat_id)

	local group = self.database.administration.groups[tostring(chat_id)]
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
		local s = utilities.md_escape(utilities.build_name(gov.first_name, gov.last_name)) .. ' `[' .. gov.id .. ']`'
		table.insert(t, '*Governor:* ' .. s)
	end
	local modstring = ''
	for k,_ in pairs(group.mods) do
		modstring = modstring .. administration.mod_format(self, k)
	end
	if modstring ~= '' then
		table.insert(t, '*Moderators:*\n' .. utilities.trim(modstring))
	end
	return table.concat(t, '\n\n')

end

function administration:update_desc(chat)
	local group = self.database.administration.groups[tostring(chat)]
	local desc = 'Welcome to ' .. group.name .. '!\n'
	if group.motd then desc = desc .. group.motd .. '\n' end
	if group.governor then
		local gov = self.database.users[tostring(group.governor)]
		desc = desc .. '\nGovernor: ' .. utilities.build_name(gov.first_name, gov.last_name) .. ' [' .. gov.id .. ']\n'
	end
	local s = '\n/desc@' .. self.info.username .. ' for more information.'
	desc = desc:sub(1, 250-s:len()) .. s
	drua.channel_set_about(chat, desc)
end

function administration.init_command(self_)
	administration.commands = {

		{ -- antisquig
			triggers = {
				'[\216-\219][\128-\191]', -- arabic
				'‮', -- rtl
				'‏', -- other rtl
			},

			privilege = 0,
			interior = true,

			action = function(self, msg, group)
				if administration.get_rank(self, msg.from.id, msg.chat.id) > 1 then
					return true
				end
				if not group.flags[2] then
					return true
				end
				drua.kick_user(msg.chat.id, msg.from.id)
				if msg.chat.type == 'supergroup' then
					bindings.unbanChatMember(self, msg.chat.id, msg.from.id)
				end
				local output = administration.flags[2].kicked:gsub('GROUPNAME', msg.chat.title)
				bindings.sendMessage(self, msg.from.id, output)
			end
		},

		{ -- generic
			triggers = { '' },

			privilege = 0,
			interior = true,

			action = function(self, msg, group)

				local rank = administration.get_rank(self, msg.from.id, msg.chat.id)

				-- banned
				if rank == 0 then
					drua.kick_user(msg.chat.id, msg.from.id)
					bindings.sendMessage(self, msg.from.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
					return
				end

				if rank < 2 then

					-- antisquig Strict
					if group.flags[3] == true then
						if msg.from.name:match('[\216-\219][\128-\191]') or msg.from.name:match('‮') or msg.from.name:match('‏') then
							drua.kick_user(msg.chat.id, msg.from.id)
							if msg.chat.type == 'supergroup' then
								bindings.unbanChatMember(self, msg.chat.id, msg.from.id)
							end
							local output = administration.flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
							bindings.sendMessage(self, msg.from.id, output)
							return
						end
					end

					-- antiflood
					if group.flags[5] == true then
						if not group.antiflood then
							group.antiflood = JSON.decode(JSON.encode(administration.antiflood))
						end
						if not self.admin_temp.flood[msg.chat.id_str] then
							self.admin_temp.flood[msg.chat.id_str] = {}
						end
						if not self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = 0
						end
						if msg.sticker then -- Thanks Brazil for discarding switches.
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.sticker
						elseif msg.photo then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.photo
						elseif msg.document then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.document
						elseif msg.audio then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.audio
						elseif msg.contact then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.contact
						elseif msg.video then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.video
						elseif msg.location then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.location
						elseif msg.voice then
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.voice
						else
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] + group.antiflood.text
						end
						if self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] > 99 then
							drua.kick_user(msg.chat.id, msg.from.id)
							if msg.chat.type == 'supergroup' then
								bindings.unbanChatMember(self, msg.chat.id, msg.from.id)
							end
							local output = administration.flags[5].kicked:gsub('GROUPNAME', msg.chat.title)
							bindings.sendMessage(self, msg.from.id, output)
							self.admin_temp.flood[msg.chat.id_str][msg.from.id_str] = nil
							return
						end
					end

				end

				if msg.new_chat_participant then

					msg.new_chat_participant.name = utilities.build_name(msg.new_chat_participant.first_name, msg.new_chat_participant.last_name)

					-- banned
					if administration.get_rank(self, msg.new_chat_participant.id, msg.chat.id) == 0 then
						drua.kick_user(msg.chat.id, msg.new_chat_participant.id)
						bindings.sendMessage(self, msg.new_chat_participant.id, 'Sorry, you are banned from ' .. msg.chat.title .. '.')
						return
					end

					-- antisquig Strict
					if group.flags[3] == true then
						if msg.new_chat_participant.name:match('[\216-\219][\128-\191]') or msg.new_chat_participant.name:match('‮') or msg.new_chat_participant.name:match('‏') then
							drua.kick_user(msg.chat.id, msg.new_chat_participant.id)
							if msg.chat.type == 'supergroup' then
								bindings.unbanChatMember(self, msg.chat.id, msg.from.id)
							end
							local output = administration.flags[3].kicked:gsub('GROUPNAME', msg.chat.title)
							bindings.sendMessage(self, msg.new_chat_participant.id, output)
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
						local output = administration.get_desc(self, msg.chat.id)
						bindings.sendMessage(self, msg.new_chat_participant.id, output, true, nil, true)
						return
					end

				elseif msg.new_chat_title then

					if rank < 3 then
						drua.rename_chat(msg.chat.id, group.name)
					else
						group.name = msg.new_chat_title
						if group.grouptype == 'supergroup' then
							administration.update_desc(self, msg.chat.id)
						end
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
				if msg.text:len() > 0 then
					for i,v in pairs(self.database.administration.activity) do
						if v == msg.chat.id_str then
							table.remove(self.database.administration.activity, i)
							table.insert(self.database.administration.activity, 1, msg.chat.id_str)
						end
					end
				end

				return true

			end
		},

		{ -- groups
			triggers = utilities.triggers(self_.info.username):t('groups').table,

			command = 'groups',
			privilege = 1,
			interior = false,

			action = function(self, msg)
				local output = ''
				for _,v in ipairs(self.database.administration.activity) do
					local group = self.database.administration.groups[v]
					if not group.flags[1] then -- no unlisted groups
						if group.link then
							output = output ..  '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
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
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- ahelp
			triggers = utilities.triggers(self_.info.username):t('ahelp').table,

			command = 'ahelp',
			privilege = 1,
			interior = false,

			action = function(self, msg)
				local rank = administration.get_rank(self, msg.from.id, msg.chat.id)
				local output = '*Commands for ' .. administration.ranks[rank] .. ':*\n'
				for i = 1, rank do
					for _, val in ipairs(self.admin_temp.help[i]) do
						output = output .. '• /' .. val .. '\n'
					end
				end
				if bindings.sendMessage(self, msg.from.id, output, true, nil, true) then
					if msg.from.id ~= msg.chat.id then
						bindings.sendReply(self, msg, 'I have sent you the requested information in a private message.')
					end
				else
					bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
				end
			end
		},

		{ -- alist
			triggers = utilities.triggers(self_.info.username):t('ops'):t('oplist').table,

			command = 'ops',
			privilege = 1,
			interior = true,

			action = function(self, msg, group)
				local modstring = ''
				for k,_ in pairs(group.mods) do
					modstring = modstring .. administration.mod_format(self, k)
				end
				if modstring ~= '' then
					modstring = '*Moderators for* _' .. msg.chat.title .. '_ *:*\n' .. modstring
				end
				local govstring = ''
				if group.governor then
					local gov = self.database.users[tostring(group.governor)]
					govstring = '*Governor:* ' .. utilities.md_escape(utilities.build_name(gov.first_name, gov.last_name)) .. ' `[' .. gov.id .. ']`'
				end
				local output = utilities.trim(modstring) ..'\n\n' .. utilities.trim(govstring)
				if output == '\n\n' then
					output = 'There are currently no moderators for this group.'
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end

		},

		{ -- desc
			triggers = utilities.triggers(self_.info.username):t('desc'):t('description').table,

			command = 'description',
			privilege = 1,
			interior = true,

			action = function(self, msg)
				local output = administration.get_desc(self, msg.chat.id)
				if bindings.sendMessage(self, msg.from.id, output, true, nil, true) then
					if msg.from.id ~= msg.chat.id then
						bindings.sendReply(self, msg, 'I have sent you the requested information in a private message.')
					end
				else
					bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
				end
			end
		},

		{ -- rules
			triggers = utilities.triggers(self_.info.username):t('rules?', true).table,

			command = 'rules',
			privilege = 1,
			interior = true,

			action = function(self, msg, group)
				local output
				local input = utilities.get_word(msg.text_lower, 2)
				input = tonumber(input)
				if #group.rules > 0 then
					if input and group.rules[input] then
						output = '*' .. input .. '.* ' .. group.rules[input]
					else
						output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
						for i,v in ipairs(group.rules) do
							output = output .. '*' .. i .. '.* ' .. v .. '\n'
						end
					end
				else
					output = 'No rules have been set for ' .. msg.chat.title .. '.'
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- motd
			triggers = utilities.triggers(self_.info.username):t('motd').table,

			command = 'motd',
			privilege = 1,
			interior = true,

			action = function(self, msg, group)
				local output = 'No MOTD has been set for ' .. msg.chat.title .. '.'
				if group.motd then
					output = '*MOTD for* _' .. msg.chat.title .. '_ *:*\n' .. group.motd
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- link
			triggers = utilities.triggers(self_.info.username):t('link').table,

			command = 'link',
			privilege = 1,
			interior = true,

			action = function(self, msg, group)
				local output = 'No link has been set for ' .. msg.chat.title .. '.'
				if group.link then
					output = '[' .. msg.chat.title .. '](' .. group.link .. ')'
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- kickme
			triggers = utilities.triggers(self_.info.username):t('leave'):t('kickme').table,

			command = 'kickme',
			privilege = 1,
			interior = true,

			action = function(self, msg)
				if administration.get_rank(self, msg.from.id) == 5 then
					bindings.sendReply(self, msg, 'I can\'t let you do that, '..msg.from.name..'.')
					return
				end
				drua.kick_user(msg.chat.id, msg.from.id)
				if msg.chat.type == 'supergroup' then
					bindings.unbanChatMember(self, msg.chat.id, msg.from.id)
				end
			end
		},

		{ -- kick
			triggers = utilities.triggers(self_.info.username):t('kick', true).table,

			command = 'kick <user>',
			privilege = 2,
			interior = true,

			action = function(self, msg)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				elseif target.rank > 1 then
					bindings.sendReply(self, msg, target.name .. ' is too privileged to be kicked.')
					return
				end
				drua.kick_user(msg.chat.id, target.id)
				if msg.chat.type == 'supergroup' then
					bindings.unbanChatMember(self, msg.chat.id, target.id)
				end
				bindings.sendMessage(self, msg.chat.id, target.name .. ' has been kicked.')
			end
		},

		{ -- ban
			triggers = utilities.triggers(self_.info.username):t('ban', true):t('unban', true).table,

			command = 'ban <user>',
			privilege = 2,
			interior = true,

			action = function(self, msg, group)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				end
				if target.rank > 1 then
					bindings.sendReply(self, msg, target.name .. ' is too privileged to be banned.')
					return
				end
				if group.bans[target.id_str] then
					group.bans[target.id_str] = nil
					if msg.chat.type == 'supergroup' then
						bindings.unbanChatMember(self, msg.chat.id, target.id)
					end
					bindings.sendReply(self, msg, target.name .. ' has been unbanned.')
				else
					group.bans[target.id_str] = true
					drua.kick_user(msg.chat.id, target.id)
					bindings.sendReply(self, msg, target.name .. ' has been banned.')
				end
			end
		},

		{ -- changerule
			triggers = utilities.triggers(self_.info.username):t('changerule', true).table,

			command = 'changerule <i> <rule>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local usage = 'usage: `/changerule <i> <newrule>`\n`/changerule <i> -- `deletes.'
				local input = utilities.input(msg.text)
				if not input then
					bindings.sendMessage(self, msg.chat.id, usage, true, msg.message_id, true)
					return
				end
				local rule_num = input:match('^%d+')
				if not rule_num then
					local output = 'Please specify which rule you want to change.\n' .. usage
					bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)
					return
				end
				rule_num = tonumber(rule_num)
				local rule_new = utilities.input(input)
				if not rule_new then
					local output = 'Please specify the new rule.\n' .. usage
					bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)
					return
				end
				if not group.rules then
					local output = 'Sorry, there are no rules to change. Please use /setrules.\n' .. usage
					bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)
					return
				end
				if not group.rules[rule_num] then
					rule_num = #group.rules + 1
				end
				if rule_new == '--' or rule_new == '—' then
					if group.rules[rule_num] then
						table.remove(group.rules, rule_num)
						bindings.sendReply(self, msg, 'That rule has been deleted.')
					else
						bindings.sendReply(self, msg, 'There is no rule with that number.')
					end
					return
				end
				group.rules[rule_num] = rule_new
				local output = '*' .. rule_num .. '*. ' .. rule_new
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- setrules
			triggers = utilities.triggers(self_.info.username):t('setrules', true).table,

			command = 'setrules <rules>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local input = msg.text:match('^/setrules[@'..self.info.username..']*(.+)')
				if not input then
					bindings.sendMessage(self, msg.chat.id, '```\n/setrules [rule]\n<rule>\n[rule]\n...\n```', true, msg.message_id, true)
					return
				elseif input == ' --' or input == ' —' then
					group.rules = {}
					bindings.sendReply(self, msg, 'The rules have been cleared.')
					return
				end
				group.rules = {}
				input = utilities.trim(input) .. '\n'
				local output = '*Rules for* _' .. msg.chat.title .. '_ *:*\n'
				local i = 1
				for l in input:gmatch('(.-)\n') do
					output = output .. '*' .. i .. '.* ' .. l .. '\n'
					i = i + 1
					table.insert(group.rules, utilities.trim(l))
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- setmotd
			triggers = utilities.triggers(self_.info.username):t('setmotd', true).table,

			command = 'setmotd <motd>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local input = utilities.input(msg.text)
				if not input then
					if msg.reply_to_message and msg.reply_to_message.text then
						input = msg.reply_to_message.text
					else
						bindings.sendReply(self, msg, 'Please specify the new message of the day.')
						return
					end
				end
				if input == '--' or input == '—' then
					group.motd = nil
					bindings.sendReply(self, msg, 'The MOTD has been cleared.')
				else
					input = utilities.trim(input)
					group.motd = input
					local output = '*MOTD for* _' .. msg.chat.title .. '_ *:*\n' .. input
					bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
				end
				if group.grouptype == 'supergroup' then
					administration.update_desc(self, msg.chat.id)
				end
			end
		},

		{ -- setlink
			triggers = utilities.triggers(self_.info.username):t('setlink', true).table,

			command = 'setlink <link>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local input = utilities.input(msg.text)
				if not input then
					bindings.sendReply(self, msg, 'Please specify the new link.')
					return
				elseif input == '--' or input == '—' then
					group.link = drua.export_link(msg.chat.id)
					bindings.sendReply(self, msg, 'The link has been regenerated.')
					return
				end
				group.link = input
				local output = '[' .. msg.chat.title .. '](' .. input .. ')'
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- alist
			triggers = utilities.triggers(self_.info.username):t('alist').table,

			command = 'alist',
			privilege = 3,
			interior = true,

			action = function(self, msg)
				local output = '*Administrators:*\n'
				output = output .. administration.mod_format(self, self.config.admin):gsub('\n', ' ★\n')
				for id,_ in pairs(self.database.administration.admins) do
					output = output .. administration.mod_format(self, id)
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- flags
			triggers = utilities.triggers(self_.info.username):t('flags?', true).table,

			command = 'flag <i>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local input = utilities.input(msg.text)
				if input then
					input = utilities.get_word(input, 1)
					input = tonumber(input)
					if not input or not administration.flags[input] then input = false end
				end
				if not input then
					local output = '*Flags for* _' .. msg.chat.title .. '_ *:*\n'
					for i,v in ipairs(administration.flags) do
						local status = group.flags[i] or false
						output = output .. '`[' .. i .. ']` *' .. v.name .. '*` = ' .. tostring(status) .. '`\n• ' .. v.desc .. '\n'
					end
					bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
					return
				end
				if group.flags[input] == true then
					group.flags[input] = false
					bindings.sendReply(self, msg, administration.flags[input].disabled)
				else
					group.flags[input] = true
					bindings.sendReply(self, msg, administration.flags[input].enabled)
				end
			end
		},

		{ -- antiflood
			triggers = utilities.triggers(self_.info.username):t('antiflood', true).table,

			command = 'antiflood <type> <i>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				if not group.flags[5] then
					bindings.sendMessage(self, msg.chat.id, 'antiflood is not enabled. Use `/flag 5` to enable it.', true, nil, true)
					return
				end
				if not group.antiflood then
					group.antiflood = JSON.decode(JSON.encode(administration.antiflood))
				end
				local input = utilities.input(msg.text_lower)
				local output
				if input then
					local key, val = input:match('(%a+) (%d+)')
					if not group.antiflood[key] or not tonumber(val) then
						output = 'Not a valid message type or number.'
					else
						group.antiflood[key] = val
						output = '*' .. key:gsub('^%l', string.upper) .. '* messages are now worth *' .. val .. '* points.'
					end
				else
					output = 'usage: `/antiflood <type> <i>`\nexample: `/antiflood text 5`\nUse this command to configure the point values for each message type. When a user reaches 100 points, he is kicked. The points are reset each minute. The current values are:\n'
					for k,v in pairs(group.antiflood) do
						output = output .. '*'..k..':* `'..v..'`\n'
					end
				end
				bindings.sendMessage(self, msg.chat.id, output, true, msg.message_id, true)
			end
		},

		{ -- mod
			triggers = utilities.triggers(self_.info.username):t('mod', true):t('demod', true).table,

			command = 'mod <user>',
			privilege = 3,
			interior = true,

			action = function(self, msg, group)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				end
				if group.mods[target.id_str] then
					if group.grouptype == 'supergroup' then
						drua.channel_set_admin(msg.chat.id, target.id, 0)
					end
					group.mods[target.id_str] = nil
					bindings.sendReply(self, msg, target.name .. ' is no longer a moderator.')
				else
					if target.rank > 2 then
						bindings.sendReply(self, msg, target.name .. ' is greater than a moderator.')
						return
					end
					if group.grouptype == 'supergroup' then
						drua.channel_set_admin(msg.chat.id, target.id, 2)
					end
					group.mods[target.id_str] = true
					bindings.sendReply(self, msg, target.name .. ' is now a moderator.')
				end
			end
		},

		{ -- gov
			triggers = utilities.triggers(self_.info.username):t('gov', true):t('degov', true).table,

			command = 'gov <user>',
			privilege = 4,
			interior = true,

			action = function(self, msg, group)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				end
				if group.governor and group.governor == target.id then
					if group.grouptype == 'supergroup' then
						drua.channel_set_admin(msg.chat.id, target.id, 0)
					end
					group.governor = self.config.admin
					bindings.sendReply(self, msg, target.name .. ' is no longer the governor.')
				else
					if group.grouptype == 'supergroup' then
						if group.governor then
							drua.channel_set_admin(msg.chat.id, group.governor, 0)
						end
						drua.channel_set_admin(msg.chat.id, target.id, 2)
					end
					if target.rank == 2 then
						group.mods[target.id_str] = nil
					end
					group.governor = target.id
					bindings.sendReply(self, msg, target.name .. ' is the new governor.')
				end
				if group.grouptype == 'supergroup' then
					administration.update_desc(self, msg.chat.id)
				end
			end
		},

		{ -- hammer
			triggers = utilities.triggers(self_.info.username):t('hammer', true):t('unhammer', true).table,

			command = 'hammer <user>',
			privilege = 4,
			interior = false,

			action = function(self, msg)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				end
				if target.rank > 3 then
					bindings.sendReply(self, msg, target.name .. ' is too privileged to be globally banned.')
					return
				end
				if self.database.blacklist[target.id_str] then
					self.database.blacklist[target.id_str] = nil
					bindings.sendReply(self, msg, target.name .. ' has been globally unbanned.')
				else
					self.database.blacklist[target.id_str] = true
					for k,_ in pairs(self.database.administration.groups) do
						drua.kick_user(k, target.id)
					end
					bindings.sendReply(self, msg, target.name .. ' has been globally banned.')
				end
			end
		},

		{ -- admin
			triggers = utilities.triggers(self_.info.username):t('admin', true):t('deadmin', true).table,

			command = 'admin <user>',
			privilege = 5,
			interior = false,

			action = function(self, msg)
				local target = administration.get_target(self, msg)
				if target.err then
					bindings.sendReply(self, msg, target.err)
					return
				end
				if self.database.administration.admins[target.id_str] then
					self.database.administration.admins[target.id_str] = nil
					bindings.sendReply(self, msg, target.name .. ' is no longer an administrator.')
				else
					if target.rank == 5 then
						bindings.sendReply(self, msg, target.name .. ' is greater than an administrator.')
						return
					end
					for _,group in pairs(self.database.administration.groups) do
						group.mods[target.id_str] = nil
					end
					self.database.administration.admins[target.id_str] = true
					bindings.sendReply(self, msg, target.name .. ' is now an administrator.')
				end
			end
		},

		{ -- gadd
			triggers = utilities.triggers(self_.info.username):t('gadd').table,

			command = 'gadd',
			privilege = 5,
			interior = false,

			action = function(self, msg)
				if self.database.administration.groups[msg.chat.id_str] then
					bindings.sendReply(self, msg, 'I am already administrating this group.')
					return
				end
				self.database.administration.groups[msg.chat.id_str] = {
					mods = {},
					governor = msg.from.id,
					bans = {},
					flags = {},
					rules = {},
					grouptype = msg.chat.type,
					name = msg.chat.title,
					link = drua.export_link(msg.chat.id),
					photo = drua.get_photo(msg.chat.id),
					founded = os.time()
				}
				administration.update_desc(self, msg.chat.id)
				for i,_ in ipairs(administration.flags) do
					self.database.administration.groups[msg.chat.id_str].flags[i] = false
				end
				table.insert(self.database.administration.activity, msg.chat.id_str)
				bindings.sendReply(self, msg, 'I am now administrating this group.')
			end
		},

		{ -- grem
			triggers = utilities.triggers(self_.info.username):t('grem', true):t('gremove', true).table,

			command = 'gremove \\[chat]',
			privilege = 5,
			interior = false,

			action = function(self, msg)
				local input = utilities.input(msg.text) or msg.chat.id_str
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
					if input == msg.chat.id_str then
						output = 'I do not administrate this group.'
					else
						output = 'I do not administrate that group.'
					end
				end
				bindings.sendMessage(self, msg.chat.id, output, true, nil, true)
			end
		},

		{ -- glist
			triggers = utilities.triggers(self_.info.username):t('list', false).table,

			command = 'glist',
			privilege = 5,
			interior = false,

			action = function(self, msg)
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
				if bindings.sendMessage(self, msg.from.id, output, true, nil, true) then
					if msg.from.id ~= msg.chat.id then
						bindings.sendReply(self, msg, 'I have sent you the requested information in a private message.')
					end
				end
			end
		},

		{ -- broadcast
			triggers = utilities.triggers(self_.info.username):t('broadcast', true).table,

			command = 'broadcast <message>',
			privilege = 5,
			interior = false,

			action = function(self, msg)
				local input = utilities.input(msg.text)
				if not input then
					bindings.sendReply(self, msg, 'Give me something to broadcast.')
					return
				end
				input = '*Admin Broadcast:*\n' .. input
				for id,_ in pairs(self.database.administration.groups) do
					bindings.sendMessage(self, id, input, true, nil, true)
				end
			end
		}

	}

	-- Generate trigger table.
	administration.triggers = {}
	for _, command in ipairs(administration.commands) do
		for _, trigger in ipairs(command.triggers) do
			table.insert(administration.triggers, trigger)
		end
	end

	self_.database.administration.help = {}
	for i,_ in ipairs(administration.ranks) do
		self_.admin_temp.help[i] = {}
	end
	for _,v in ipairs(administration.commands) do
		if v.command then
			table.insert(self_.admin_temp.help[v.privilege], v.command)
		end
	end
end

function administration:action(msg)
	for _,command in ipairs(administration.commands) do
		for _,trigger in pairs(command.triggers) do
			if msg.text_lower:match(trigger) then
				if command.interior and not self.database.administration.groups[msg.chat.id_str] then
					break
				end
				if administration.get_rank(self, msg.from.id, msg.chat.id) < command.privilege then
					break
				end
				local res = command.action(self, msg, self.database.administration.groups[msg.chat.id_str])
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
end

administration.command = 'groups'
administration.doc = '`Returns a list of administrated groups.\nUse /ahelp for more administrative commands.`'

return administration
