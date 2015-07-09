local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('admin.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	local message = I18N('COMMAND_NOT_FOUND')

	local sudo = 0
	for i,v in ipairs(config.admins) do
		if msg.from.id == v then
			sudo = v
		end
	end

	if sudo == 0 then
		message = I18N('PERMISSION_DENIED')

	elseif string.lower(first_word(input)) == 'run' then

		local output = string.sub(input, 5)
		local output = io.popen(output)
		message = output:read('*all')
		output:close()

	elseif string.lower(first_word(input)) == 'reload' then

		bot_init()
		message = I18N('admin.BOT_RELOAD')

	elseif string.lower(first_word(input)) == 'halt' then

		is_started = false
		message = I18N('admin.BOT_SHUTDOWN')

	end

	send_msg(msg, message)

end

return PLUGIN
