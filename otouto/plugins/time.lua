--[[
    time.lua
    Returns the time, date, and timezone for a given location.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local time = {}

function time:init()
    time.command = 'time <location>'
    time.base_url = 'https://maps.googleapis.com/maps/api/timezone/json?location=%s,%s&timestamp=%s'
    time.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('time', true).table
    time.doc = self.config.cmd_pat .. [[time <location>
Returns the time, date, and timezone for the given location.]]
end

function time:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, time.doc, 'html')
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

    local now = os.time()
    local utc = os.time(os.date('!*t', now))
    local url = time.base_url:format(lat, lon, utc)
    local jstr, code = HTTPS.request(url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    if data.status == 'ZERO_RESULTS' then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    if not data.dstOffset then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local timestamp = now + data.rawOffset + data.dstOffset
    local utcoff = (data.rawOffset + data.dstOffset) / 3600
    if utcoff == math.abs(utcoff) then
        utcoff = '+' .. utilities.pretty_float(utcoff)
    else
        utcoff = utilities.pretty_float(utcoff)
    end
    local output = string.format('```\n%s\n%s (UTC%s)\n```',
        os.date('!%I:%M %p\n%A, %B %d, %Y', timestamp),
        data.timeZoneName,
        utcoff
    )
    utilities.send_reply(msg, output, true)
end

return time
