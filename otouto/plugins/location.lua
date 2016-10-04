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
        utilities.send_reply(msg, gMaps.doc, 'html')
        return
    end

    local lat, lon = utilities.get_coords(input)
    if lat == nil then
        utilities.send_reply(msg, config.errors.connection)
        return
    elseif lat == false then
        utilities.send_reply(msg, config.errors.results)
        return
    end

    bindings.sendLocation{
        chat_id = msg.chat.id,
        latitude = lat,
        longitude = lon,
        reply_to_message_id = msg.message_id
    }
end

return gMaps
