local gMaps = {}

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

gMaps.command = 'location <query>'

function gMaps:init(config)
    gMaps.triggers = utilities.triggers(self.info.username, config.cmd_pat)
        :t('location', true):t('loc', true).table
    gMaps.doc = [[
/location <query>
Returns a location from Google Maps.
Alias: /loc
    ]]
    gMaps.doc = gMaps.doc:gsub('/', config.cmd_pat)
end

function gMaps:action(msg, config)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, gMaps.doc, true)
        return
    end

    local coords = utilities.get_coords(input, config)
    if type(coords) == 'string' then
        utilities.send_reply(msg, coords)
    end

    bindings.sendLocation{
        chat_id = msg.chat.id,
        latitude = coords.lat,
        longitude = coords.lon,
        reply_to_message_id = msg.message_id
    }
end

return gMaps
