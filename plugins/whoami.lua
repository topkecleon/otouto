local PLUGIN = {}

PLUGIN.doc = [[
	/whoami
	Get the user ID for yourself and the group. Use it in a reply to get info for the sender of the original message.
]]

PLUGIN.triggers = {
	'^/whoami',
	'^/ping',
	'^/who$'
}

function PLUGIN.action(msg)

	if msg.from.id == msg.chat.id then
		to_name = '@' .. bot.username .. ' (' .. bot.id .. ')'
	else
		to_name = string.gsub(msg.chat.title, '_', ' ') .. ' (' .. string.gsub(msg.chat.id, '-', '') .. ')'
	end

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	local from_name = msg.from.first_name
	if msg.from.last_name then
		from_name = from_name .. ' ' .. msg.from.last_name
	end
	if msg.from.username then
		from_name = '@' .. msg.from.username .. ', AKA ' .. from_name
	end
	from_name = from_name .. ' (' .. msg.from.id .. ')'

	local message = 'You are ' .. from_name .. ' and you are messaging ' .. to_name .. '.'

	send_msg(msg, message)

end

return PLUGIN
