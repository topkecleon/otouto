 -- Liberbot-compliant floodcontrol.
 -- Put this after moderation.lua or blacklist.lua.

local floodcontrol = {}

local JSON = require('dkjson')
local utilities = require('utilities')

function floodcontrol:init()
	self.floodcontrol = self.floodcontrol or {}
end

floodcontrol.triggers = {
	''
}

function floodcontrol:action(msg)

	if self.floodcontrol[-msg.chat.id] then
		return
	end

	local input = msg.text_lower:match('^/floodcontrol (.+)') or msg.text_lower:match('^/floodcontrol@'..self.info.username..' (.+)')
	if not input then return true end

	if msg.from.id ~= 100547061 and msg.from.id ~= self.config.admin then
		return -- Only run for Liberbot or the admin.
	end

	input = JSON.decode(input)

	if not input.groupid then
		return
	end
	if not input.duration then
		input.duration = 600
	end

	self.floodcontrol[input.groupid] = os.time() + input.duration

	local output = input.groupid .. ' silenced for ' .. input.duration .. ' seconds.'
	utilities.handle_exception(self, 'floodcontrol.lua', output)

end

function floodcontrol:cron()

	for k,v in pairs(self.floodcontrol) do
		if os.time() > v then
			self.floodcontrol[k] = nil
		end
	end

end

return floodcontrol
