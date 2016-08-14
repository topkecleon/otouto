 -- Credit to Heitor (tg:Wololo666; gh:heitorPB) for this plugin.

local apod = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local URL = require('socket.url')
local utilities = require('otouto.utilities')

apod.command = 'apod [date]'

function apod:init(config)
    apod.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('apod', true).table
    apod.doc = [[
/apod [YYYY-MM-DD]
Returns the Astronomy Picture of the Day.
Source: nasa.gov
    ]]
    apod.doc = apod.doc:gsub('/', config.cmd_pat)
    apod.base_url = 'https://api.nasa.gov/planetary/apod?api_key=' .. (config.nasa_api_key or 'DEMO_KEY')
end

function apod:action(msg, config)
    local input = utilities.input(msg.text)
    local url = apod.base_url
    local date = os.date('%F')
    if input then
        if input:match('^(%d+)%-(%d+)%-(%d+)$') then
            url = url .. '&date=' .. URL.escape(input)
            date = input
        end
    end

    local jstr, code = HTTPS.request(url)
    if code ~= 200 then
        utilities.send_reply(self, msg, config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    if data.error then
        utilities.send_reply(self, msg, config.errors.results)
        return
    end

    local output = string.format(
        '<b>%s (</b><a href="%s">%s</a><b>)</b>\n%s',
        utilities.html_escape(data.title),
        utilities.html_escape(data.hdurl or data.url),
        date,
        utilities.html_escape(data.explanation)
    )
    utilities.send_message(self, msg.chat.id, output, false, nil, 'html')
end

return apod
