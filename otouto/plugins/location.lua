--[[
    location.lua
    Returns the coordinates of a given location.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local location = {}

function location:init()
    location.command = 'location <query>'
    location.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('location', true):t('loc', true).table
    location.doc = self.config.cmd_pat .. [[location <query>
Returns a location from Google Maps.
Alias: ]] .. self.config.cmd_pat .. 'loc'
end

function location:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, location.doc, 'html')
        return
    end

    local lat, lon = utilities.get_coords(input)
    if lat == nil then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    elseif lat == false then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    bindings.sendLocation{
        chat_id = msg.chat.id,
        latitude = lat,
        longitude = lon,
        reply_to_message_id = msg.message_id
    }
end

return location
