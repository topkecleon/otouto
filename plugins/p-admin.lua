local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'admin '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	local message = 'No entiendo Senpai...'

	local sudo = 0
	for i,v in ipairs(config.admins) do
		if msg.from.id == v then
			sudo = v
		end
	end

	if sudo == 0 then
		message = '¡Solo acepto ordenes de Senpai! 😣'

	elseif string.lower(first_word(input)) == 'run' then

		local output = string.sub(input, 5)
		local output = io.popen(output)
		message = output:read('*all')
		output:close()

	elseif string.lower(first_word(input)) == 'reload' then
		message = 'Mata ne! 👋'
		send_msg(msg, message)

		bot_init()
		message = 'Konnichi wa! 😊'

	elseif string.lower(first_word(input)) == 'halt' then

		is_started = false
		message = 'Oyasumi~ 😴'

	end

	send_msg(msg, message)

end

return PLUGIN
