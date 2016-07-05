--[[
	drua-tg
	A fork of JuanPotato's lua-tg (https://github.com/juanpotato/lua-tg),
	modified to work more naturally from an API bot.

	Usage:
		drua = require('drua-tg')
		drua.IP = 'localhost'
		drua.PORT = 4567
		drua.message(chat_id, text)
]]--

local SOCKET = require('socket')

local comtab = {
	add = { 'chat_add_user %s %s', 'channel_invite %s %s' },
	kick = { 'chat_del_user %s %s', 'channel_kick %s %s' },
	rename = { 'rename_chat %s "%s"', 'rename_channel %s "%s"' },
	link = { 'export_chat_link %s', 'export_channel_link %s' },
	photo_set = { 'chat_set_photo %s %s', 'channel_set_photo %s %s' },
	photo_get = { [0] = 'load_user_photo %s', 'load_chat_photo %s', 'load_channel_photo %s' },
	info = { [0] = 'user_info %s', 'chat_info %s', 'channel_info %s' }
}

local format_target = function(target)
	target = tonumber(target)
	if target < -1000000000000 then
		target = 'channel#' .. math.abs(target) - 1000000000000
		return target, 2
	elseif target < 0 then
		target = 'chat#' .. math.abs(target)
		return target, 1
	else
		target = 'user#' .. target
		return target, 0
	end
end

local escape = function(text)
	text = text:gsub('\\', '\\\\')
	text = text:gsub('\n', '\\n')
	text = text:gsub('\t', '\\t')
	text = text:gsub('"', '\\"')
	return text
end

local drua = {
	IP = 'localhost',
	PORT = 4567
}

drua.send = function(command, do_receive)
	local s = SOCKET.connect(drua.IP, drua.PORT)
	assert(s, '\nUnable to connect to tg session.')
	s:send(command..'\n')
	local output
	if do_receive then
		output = string.match(s:receive('*l'), 'ANSWER (%d+)')
		output = s:receive(tonumber(output)):gsub('\n$', '')
	end
	s:close()
	return output
end

drua.message = function(target, text)
	target = format_target(target)
	text = escape(text)
	local command = 'msg %s "%s"'
	command = command:format(target, text)
	return drua.send(command)
end

drua.send_photo = function(target, photo)
	target = format_target(target)
	local command = 'send_photo %s %s'
	command = command:format(target, photo)
	return drua.send(command)
end

drua.add_user = function(chat, target)
	local a
	chat, a = format_target(chat)
	target = format_target(target)
	local command = comtab.add[a]:format(chat, target)
	return drua.send(command)
end

drua.kick_user = function(chat, target)
	-- Get the group info so tg will recognize the target.
	drua.get_info(chat)
	local a
	chat, a = format_target(chat)
	target = format_target(target)
	local command = comtab.kick[a]:format(chat, target)
	return drua.send(command)
end

drua.rename_chat = function(chat, name)
	local a
	chat, a = format_target(chat)
	local command = comtab.rename[a]:format(chat, name)
	return drua.send(command)
end

drua.export_link = function(chat)
	local a
	chat, a = format_target(chat)
	local command = comtab.link[a]:format(chat)
	return drua.send(command, true)
end

drua.get_photo = function(chat)
	local a
	chat, a = format_target(chat)
	local command = comtab.photo_get[a]:format(chat)
	local output = drua.send(command, true)
	if output:match('FAIL') then
		return false
	else
		return output:match('Saved to (.+)')
	end
end

drua.set_photo = function(chat, photo)
	local a
	chat, a = format_target(chat)
	local command = comtab.photo_set[a]:format(chat, photo)
	return drua.send(command)
end

drua.get_info = function(target)
	local a
	target, a = format_target(target)
	local command = comtab.info[a]:format(target)
	return drua.send(command, true)
end

drua.channel_set_admin = function(chat, user, rank)
	chat = format_target(chat)
	user = format_target(user)
	local command = 'channel_set_admin %s %s %s'
	command = command:format(chat, user, rank)
	return drua.send(command)
end

drua.channel_set_about = function(chat, text)
	chat = format_target(chat)
	text = escape(text)
	local command = 'channel_set_about %s "%s"'
	command = command:format(chat, text)
	return drua.send(command)
end

drua.block = function(user)
	return drua.send('block_user user#' .. user)
end

drua.unblock = function(user)
	return drua.send('unblock_user user#' .. user)
end

return drua
