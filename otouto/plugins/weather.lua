--[[
    weather.lua
    Returns the weather for a given location.

    Uses OpenWeatherMap.org for weather information.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local weather = {}

function weather:init()
    assert(
        self.config.owm_api_key,
        'weather.lua requires an OpenWeatherMap API key from http://openweathermap.org/API.'
    )

    weather.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('weather', true).table
    weather.doc = self.config.cmd_pat .. [[weather <location>
Returns the current weather conditions for a given location.]]
    weather.command = 'weather <location>'
end

function weather:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, weather.doc, 'html')
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

    local url = 'http://api.openweathermap.org/data/2.5/weather?APPID=' .. self.config.owm_api_key .. '&lat=' .. lat .. '&lon=' .. lon

    local old = HTTP.TIMEOUT
    HTTP.TIMEOUT = 2
    local jstr, res = HTTP.request(url)
    HTTP.TIMEOUT = old
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)
    if jdat.cod ~= 200 then
        utilities.send_reply(msg, 'Error: City not found.')
        return
    end

    local celsius = string.format('%.2f', jdat.main.temp - 273.15)
    local fahrenheit = string.format('%.2f', celsius * (9/5) + 32)
    local output = '`' .. celsius .. '°C | ' .. fahrenheit .. '°F, ' .. jdat.weather[1].description .. '.`'

    utilities.send_reply(msg, output, true)

end

return weather
