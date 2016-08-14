local time = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

time.command = 'time <location>'
time.base_url = 'https://maps.googleapis.com/maps/api/timezone/json?location=%s,%s&timestamp=%s'

function time:init(config)
    time.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('time', true).table
    time.doc = config.cmd_pat .. [[time <location>
Returns the time, date, and timezone for the given location.]]
end

function time:action(msg, config)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(self, msg, time.doc, true)
        return
    end

    local coords = utilities.get_coords(input, config)
    if type(coords) == 'string' then
        utilities.send_reply(self, msg, coords)
        return
    end

    local now = os.time()
    local utc = os.time(os.date('!*t', now))
    local url = time.base_url:format(coords.lat, coords.lon, utc)
    local jstr, code = HTTPS.request(url)
    if code ~= 200 then
        utilities.send_reply(self, msg, config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    if data.status == 'ZERO_RESULTS' then
        utilities.send_reply(self, msg, config.errors.results)
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
    utilities.send_reply(self, msg, output, true)
end

return time
