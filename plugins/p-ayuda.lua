local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[ayuda [comando]
	Recibe una lista basica con todos los comandos, o documentacion mas detallada sobre un comando especifico.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'ayuda',
	'^' .. config.COMMAND_START .. 'start',
	'^' .. config.COMMAND_START .. 'help',
	'^' .. config.COMMAND_START .. 'h$'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	if(msg.from.id == 11987707) then
		return send_msg(msg, 'Mario, ¿no te cansas de hacer el tonto?')
	end

	if input then
		for i,v in ipairs(plugins) do
			if v.doc then
				if '/' .. input == trim_string(first_word(v.doc)) then
					return send_msg(msg, v.doc)
				end
			end
		end
	end
	
	local ayuda = 'Comandos disponibles:\n'
	for i,v in ipairs(plugins) do
		if v.doc then
			local a = string.sub(v.doc, 1, string.find(v.doc, '\n')-1)
			print(a)
			ayuda = ayuda .. ' - ' .. a .. '\n'
		end
	end
	ayuda = ayuda .. '\n*Argumentos: <obligatorio> [opcional]\nUsa "/ayuda <comando>" para información especifica.\n\n'
	ayuda = ayuda .. 'otouto v' .. VERSION .. ' por @topkecleon y modificado por @luksi_reiku.'

	if msg.from.id ~= msg.chat.id then
		if not send_message(msg.from.id, ayuda, true, msg.message_id) then
			return send_msg(msg, ayuda) -- Unable to PM user who hasn't PM'd first.
		end
		return send_msg(msg, 'He enviado la ayuda en un mensaje privado.')
	else
		return send_msg(msg, ayuda)
	end

end

return PLUGIN
