--[[
    youtube.lua
    Returns a YouTube result for the given query.

    Requires a Google API key.

    Original plugin written by TiagoDanin.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local youtube = {}

function youtube:init()
    assert(
        self.config.google_api_key,
        'youtube.lua requires a Google API key from http://console.developers.google.com.'
    )

    youtube.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('youtube', true):t('yt', true).table
    youtube.doc = self.config.cmd_pat .. [[youtube <query>
Returns the top result from YouTube.
Alias: ]] .. self.config.cmd_pat .. 'yt'
    youtube.command = 'youtube <query>'
end

function youtube:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, youtube.doc, 'html')
        return
    end

    local url = 'https://www.googleapis.com/youtube/v3/search?key=' .. self.config.google_api_key .. '&type=video&part=snippet&maxResults=4&q=' .. URL.escape(input)

    local jstr, res = HTTPS.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)
    if jdat.pageInfo.totalResults == 0 then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local vid_url = 'https://www.youtube.com/watch?v=' .. jdat.items[1].id.videoId
    local vid_title = jdat.items[1].snippet.title
    vid_title = vid_title:gsub('%(.+%)',''):gsub('%[.+%]','')
    local output = '[' .. vid_title .. '](' .. vid_url .. ')'

    utilities.send_message(msg.chat.id, output, false, nil, true)

end

return youtube
