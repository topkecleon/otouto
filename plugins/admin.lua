local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.admin.command
}

function PLUGIN.action(msg)

	if msg.date < os.time() - 1 then return end

	local input = get_input(msg.text)

	local message = locale.inv_arg

	local sudo = 0
	for i,v in ipairs(config.admins) do
		if msg.from.id == v then
			sudo = v
		end
	end

	if sudo == 0 then
		message = locale.no_perm

	elseif string.lower(first_word(input)) == 'run' then

		local output = string.sub(input, 5)
		local output = io.popen(output)
		message = output:read('*all')
		output:close()

	elseif string.lower(first_word(input)) == 'reload' then

		bot_init()
		message = locale.admin.reload

	elseif string.lower(first_word(input)) == 'halt' then

		is_started = false
		message = locale.admin.halt

	end

	send_msg(msg, message)

end

return PLUGIN
