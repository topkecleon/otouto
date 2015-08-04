local PLUGIN = {}

PLUGIN.triggers = {
	'^/admin '
}

PLUGIN.no_typing = true

function PLUGIN.action(msg)

	if msg.date < os.time() - 1 then return end

	local input = get_input(msg.text)

	local message = config.locale.errors.argument

	if not config.admins[msg.from.id] then
		return send_msg(msg, 'Permission denied.')
	end

	if string.lower(first_word(input)) == 'run' then

		local output = get_input(input)
		if not output then
			return send_msg(msg, config.locale.errors.argument)
		end
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
