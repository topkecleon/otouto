local gMaps = {}

local bindings = require('bindings')
local utilities = require('utilities')

gMaps.command = 'location <query>'
gMaps.doc = [[```
/location <query>
Returns a location from Google Maps.
Alias: /loc
```]]

function gMaps:init()
	gMaps.triggers = utilities.triggers(self.info.username):t('location', true):t('loc', true).table
end

function gMaps:action(msg)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			bindings.sendMessage(self, msg.chat.id, gMaps.doc, true, msg.message_id, true)
			return
		end
	end

	local coords = utilities.get_coords(self, input)
	if type(coords) == 'string' then
		bindings.sendReply(self, msg, coords)
		return
	end

	bindings.sendLocation(self, msg.chat.id, coords.lat, coords.lon, msg.message_id)

end

return gMaps
