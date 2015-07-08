local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'tutorial',
	'^' .. config.COMMAND_START .. 'info',
	'^' .. config.COMMAND_START .. 'reglas',
	'^' .. config.COMMAND_START .. 'grupos'
}

function PLUGIN.action(msg)

	local input = string.lower(msg.text)

	if msg.chat.id  ~= -1091482 then
		return
	end
	
	if string.match(input, PLUGIN.triggers[1]) or msg.new_chat_participant then
	
		send_msg(msg, 'Bienvenidos a la República de Brovrasħgĸa')
		--send_msg(msg, 'Tutorial básico de Brovrasħgĸa.\n1- Corre. Rápido.')
		--send_msg(msg, 'Tutorial básico de Brovrasħgĸa.\n2- El que no escribe, reenvía.')
		--send_msg(msg, 'Tutorial básico de Brovrasħgĸa.\n3- Whatsapp da sidita, Telegram lo cura.')
		--send_msg(msg, 'Tutorial básico de Brovrasħgĸa.\n4- Amaras y respetaras a Peto-tan sobre todas las cosas.')

		send_msg(msg, 'Tutorial básico de Brovrasħgĸa:\n1- Corre. Rápido.\n2- El que no escribe, reenvía.\n3- Whatsapp da sidita, Telegram lo cura.\n4- Amaras y respetaras a Peto-tan sobre todas las cosas.')

	elseif string.match(input, PLUGIN.triggers[2]) then
	
		send_msg(msg, 'http://brovrashgka.org\nhttp://facebook.com/brovrashgka\nhttp://twitter.com/brovrashgka')
	
	elseif string.match(input, PLUGIN.triggers[3]) then
		send_msg(msg, '1) Peto-tan mola!\n2) Cazar almas es divertido.\n3) Pensabas que era una regla, pero era yo, Dio!\n4) Mario no se puede quejar. (ni huir)')
	end
end

return PLUGIN
