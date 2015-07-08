local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[yo
	Obtiene datos del usuario y del chat.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'yo',
}

function PLUGIN.action(msg)

	local from_name = msg.from.first_name
	if msg.from.last_name then
		from_name = from_name .. ' ' .. msg.from.last_name
	end
	if msg.from.username then
		from_name = from_name .. ' (@' .. msg.from.username .. ')'
	end
	from_name = from_name .. ' [' .. msg.from.id .. ']'
	
	if msg.from.id == msg.chat.id then
		to_name = '@' .. bot.username .. ' [' .. bot.id .. ']'
	else
		to_name = string.gsub(msg.chat.title, '_', ' ') .. ' [' .. string.gsub(msg.chat.id, '-', '') .. ']'
	end
	
	local message = 'Eres ' .. from_name .. ' y estas en el chat ' .. to_name .. '.'
	
	send_msg(msg, message)

end

return PLUGIN
