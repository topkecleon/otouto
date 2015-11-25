 -- Liberbot-compliant floodcontrol.
 -- Put this after moderation.lua or blacklist.lua.

floodcontrol = floodcontrol or {}

local triggers = {
	''
}

local action = function(msg)

	if floodcontrol[-msg.chat.id] then
		return
	end

	local input = msg.text_lower:match('^/floodcontrol[@'..bot.username..']* (.+)')
	if not input then return true end

	if msg.from.id ~= 100547061 and msg.from.id ~= config.admin then
		return -- Only run for Liberbot or the admin.
	end

	input = JSON.decode(input)

	if not input.groupid then
		return
	end
	if not input.duration then
		input.duration = 600
	end

	floodcontrol[input.groupid] = os.time() + input.duration

	print(input.groupid .. ' silenced for ' .. input.duration .. ' seconds.')

end

local cron = function()

	for k,v in pairs(floodcontrol) do
		if os.time() > v then
			floodcontrol[k] = nil
		end
	end

end

return {
	action = action,
	triggers = triggers,
	cron = cron
}
