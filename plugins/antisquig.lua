 -- Put this at the very top of your plugin list, even before blacklist.lua.

antisquig = {}

local triggers = {
	'[\216-\219][\128-\191]'
}

local action = function(msg)

	local moddat = load_data('moderation.json')

	if not moddat[msg.chat.id_str] then
		return true
	end

	if moddat[msg.chat.id_str][msg.from.id_str] or config.moderation.admins[msg.from.id_str] then
		return true
	end

	if antisquig[msg.from.id] == true then
		return
	end
	antisquig[msg.from.id] = true

	sendReply(msg, config.errors.antisquig)
	sendMessage(config.moderation.admin_group, '/kick ' .. msg.from.id .. ' from ' .. math.abs(msg.chat.id))
	sendMessage(config.moderation.admin_group, 'ANTISQUIG: ' .. msg.from.first_name .. ' kicked from ' .. msg.chat.title .. '.')

end

 -- When a user is kicked for squigglies, his ID is added to this table.
 -- That user will not be kicked again as long as his ID is in the table.
 -- The table is emptied every five seconds.
 -- Thus the bot will not spam the group or admin group when a user posts more than one infringing messages.
local cron = function()

	antisquig = {}

end

return {
	action = action,
	triggers = triggers,
	cron = cron
}
