local PLUGIN = {}

PLUGIN.triggers = {
	'^!admin '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	local message = 'Command not found.'

	if msg.from.id ~= config.ADMIN_ID then
		message = 'Permission denied.'

	elseif string.lower(first_word(input)) == 'run' then

		local output = string.sub(input, 5)
		local output = io.popen(output)
		message = output:read('*all')
		output:close()

	elseif string.lower(first_word(input)) == 'reload' then

		bot_init()
		message = 'Bot reloaded!'

	elseif string.lower(first_word(input)) == 'halt' then

		is_started = false
		message = 'Shutting down...'

	end

	send_msg(msg, message)

end

return PLUGIN
