floodcontrol = {}

local triggers = {
	'/floodcontrol'
}

local action = function(msg)

	local input, output

	if msg.from.id ~= 100547061 then -- Only acknowledge Liberbot.
		if not config.admins[msg.from.id] then -- or an admin. :)
			return
		end
	end
	input = get_input(msg.text) -- Remove the first word from the input.
	input = JSON.decode(input) -- Parse the JSON into a table.
	if not input.groupid then return end -- If no group is specified, end.

	if not input.duration then -- If no duration is specified, set it to 5min.
		input.duration = 600
	end

	floodcontrol[input.groupid] = os.time() + input.duration

	local s = input.groupid .. ' silenced for ' .. input.duration .. ' seconds.'

	send_message(-34496439, s) -- Set this to whatever, or comment it out. I use it to send this data to my private bot group.

end

local cron = function()

	for k,v in pairs(floodcontrol) do
		if os.time() > v then
			floodcontrol[k] = nil
		end
	end

end

return {
	triggers = triggers,
	action = action,
	cron = cron
}
