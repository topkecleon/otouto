local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'get.text$',
	'^' .. config.COMMAND_START .. 'get.date$',
	'^' .. config.COMMAND_START .. 'get.from.id$',
	'^' .. config.COMMAND_START .. 'get.from.username$',
	'^' .. config.COMMAND_START .. 'get.from.first_name$',
	'^' .. config.COMMAND_START .. 'get.bot.id$',
	'^' .. config.COMMAND_START .. 'get.bot.username$',
	'^' .. config.COMMAND_START .. 'get.bot.first_name$'
}

function PLUGIN.action(msg)

	local input = msg.text
	if msg.reply_to_message then
		if string.match(input, PLUGIN.triggers[1]) then
			local message = msg.reply_to_message.text
			send_msg(msg, message)
		elseif string.match(input, PLUGIN.triggers[2]) then
			local message = msg.reply_to_message.date
			send_msg(msg, message)
		elseif string.match(input, PLUGIN.triggers[3]) then
			local message = msg.reply_to_message.from.id
			send_msg(msg, message)
		elseif string.match(input, PLUGIN.triggers[4]) then
			local message = msg.reply_to_message.from.username
			send_msg(msg, message)
		elseif string.match(input, PLUGIN.triggers[5]) then
			local message = msg.reply_to_message.from.first_name
			send_msg(msg, message)
		end
	end

	if string.match(input, PLUGIN.triggers[6]) then
		local message = bot.id
		send_msg(msg, message)
	elseif string.match(input, PLUGIN.triggers[7]) then
	        local message = bot.username
	        send_msg(msg, message)
	elseif string.match(input, PLUGIN.triggers[8]) then
	        local message = bot.first_name
	        send_msg(msg, message)
	end
end

return PLUGIN
