 -- This plugin will allow the admin to blacklist users who will be unable to
 -- use the bot. This plugin should be at the top of your plugin list in config.

if not database.blacklist then
	database.blacklist = {}
end

local triggers = {
	''
}

 local action = function(msg)

	if database.blacklist[msg.from.id_str] then return end
	if database.blacklist[msg.chat.id_str] then return end
	if not msg.text:match('^/blacklist') then return true end
	if msg.from.id ~= config.admin then return end

	local target = user_from_message(msg)
	if target.err then
		sendReply(msg, target.err)
		return
	end

	if tonumber(target.id) < 0 then
		target.name = 'Group'
	end

	if database.blacklist[tostring(target.id)] then
		database.blacklist[tostring(target.id)] = nil
		sendReply(msg, target.name .. ' has been removed from the blacklist.')
	else
		database.blacklist[tostring(target.id)] = true
		sendReply(msg, target.name .. ' has been added to the blacklist.')
	end

 end

 return {
	action = action,
	triggers = triggers
}
