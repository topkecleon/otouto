local gMaps = {}

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

gMaps.command = 'location <query>'

function gMaps:init(config)
	gMaps.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('location', true):t('loc', true).table
	gMaps.doc = [[```
]]..config.cmd_pat..[[location <query>
Returns a location from Google Maps.
Alias: ]]..config.cmd_pat..[[loc
```]]
end

function gMaps:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, gMaps.doc, true, msg.message_id, true)
			return
		end
	end

	local coords = utilities.get_coords(input, config)
	if type(coords) == 'string' then
		utilities.send_reply(self, msg, coords)
		return
	end

	bindings.sendLocation(self, {
		chat_id = msg.chat.id,
		latitude = coords.lat,
		longitude = coords.lon,
		reply_to_message_id = msg.message_id
	} )

end

return gMaps
