local weather = {}

local HTTP = require('socket.http')
HTTP.TIMEOUT = 2
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

function weather:init(config)
    assert(config.owm_api_key,
        'weather.lua requires an OpenWeatherMap API key from http://openweathermap.org/API.'
    )

    weather.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('weather', true).table
    weather.doc = config.cmd_pat .. [[weather <location>
Returns the current weather conditions for a given location.]]
end

weather.command = 'weather <location>'

function weather:action(msg, config)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, weather.doc, true)
        return
    end

    local coords = utilities.get_coords(input, config)
    if type(coords) == 'string' then
        utilities.send_reply(msg, coords)
        return
    end

    local url = 'http://api.openweathermap.org/data/2.5/weather?APPID=' .. config.owm_api_key .. '&lat=' .. coords.lat .. '&lon=' .. coords.lon

    local jstr, res = HTTP.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, config.errors.connection)
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
