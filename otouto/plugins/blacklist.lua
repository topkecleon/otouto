 -- This plugin will allow the admin to blacklist users who will be unable to
 -- use the bot. This plugin should be at the top of your plugin list in config.

local blacklist = {}

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

function blacklist:init()
	if not self.database.blacklist then
		self.database.blacklist = {}
	end
end

blacklist.triggers = {
	''
}

blacklist.error = false

function blacklist:action(msg, config)
	if self.database.blacklist[tostring(msg.from.id)] then
		return
	elseif self.database.blacklist[tostring(msg.chat.id)] then
		bindings.leaveChat(self, { chat_id = msg.chat.id })
		return
	end
	if not (
		msg.from.id == config.admin
		and (
			msg.text:match('^'..config.cmd_pat..'blacklist')
			or msg.text:match('^'..config.cmd_pat..'unblacklist')
		)
	) then
		return true
	end
	local targets = {}
	if msg.reply_to_message then
		table.insert(targets, {
			id = msg.reply_to_message.from.id,
			id_str = tostring(msg.reply_to_message.from.id),
			name = utilities.build_name(msg.reply_to_message.from.first_name, msg.reply_to_message.from.last_name)
		})
	else
		local input = utilities.input(msg.text)
		if input then
			for _, user in ipairs(utilities.index(input)) do
				if self.database.users[user] then
					table.insert(targets, {
						id = self.database.users[user].id,
						id_str = tostring(self.database.users[user].id),
						name = utilities.build_name(self.database.users[user].first_name, self.database.users[user].last_name)
					})
				elseif tonumber(user) then
					local t = {
						id_str = user,
						id = tonumber(user)
					}
					if tonumber(user) < 0 then
						t.name = 'Group (' .. user .. ')'
					else
						t.name = 'Unknown (' .. user .. ')'
					end
					table.insert(targets, t)
				elseif user:match('^@') then
					local u = utilities.resolve_username(self, user)
					if u then
						table.insert(targets, {
							id = u.id,
							id_str = tostring(u.id),
							name = utilities.build_name(u.first_name, u.last_name)
						})
					else
						table.insert(targets, { err = 'Sorry, I do not recognize that username ('..user..').' })
					end
				else
					table.insert(targets, { err = 'Invalid username or ID ('..user..').' })
				end
			end
		else
			utilities.send_reply(self, msg, 'Please specify a user or users via reply, username, or ID, or a group or groups via ID.')
			return
		end
	end
	local output = ''
	if msg.text:match('^'..config.cmd_pat..'blacklist') then
		for _, target in ipairs(targets) do
			if target.err then
				output = output .. target.err .. '\n'
			elseif self.database.blacklist[target.id_str] then
				output = output .. target.name .. ' is already blacklisted.\n'
			else
				self.database.blacklist[target.id_str] = true
				output = output .. target.name .. ' is now blacklisted.\n'
				if config.drua_block_on_blacklist and target.id > 0 then
					require('drua-tg').block(target.id)
				end
			end
		end
	elseif msg.text:match('^'..config.cmd_pat..'unblacklist') then
		for _, target in ipairs(targets) do
			if target.err then
				output = output .. target.err .. '\n'
			elseif not self.database.blacklist[target.id_str] then
				output = output .. target.name .. ' is not blacklisted.\n'
			else
				self.database.blacklist[target.id_str] = nil
				output = output .. target.name .. ' is no longer blacklisted.\n'
				if config.drua_block_on_blacklist and target.id > 0 then
					require('drua-tg').unblock(target.id)
				end
			end
		end
	end
	utilities.send_reply(self, msg, output)
end

return blacklist
