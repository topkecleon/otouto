--[[
    lastfm.lua
    Returns the currently-playing or last-played song for a given last.fm user.
    Allows users to store their last.fm usernames.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local lastfm = {}

function lastfm:init()
    assert(
        self.config.lastfm_api_key,
        'lastfm.lua requires a last.fm API key from http://last.fm/api.'
    )

    self.database.userdata.lastfm = self.database.userdata.lastfm or {}
    lastfm.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('lastfm', true):t('np', true):t('npfull', true):t('fmset', true).table
    lastfm.doc = [[/np [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

/npfull [username]
Works like /np, but returns more info, differently formatted and including album art, if available.

/fmset <username>
Sets your last.fm username. Otherwise, /np will use your Telegram username. Use "/fmset --" to delete it.]]
    lastfm.doc = lastfm.doc:gsub('/', self.config.cmd_pat)
    lastfm.command = 'lastfm'
    lastfm.base_url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. self.config.lastfm_api_key .. '&user='
end

function lastfm:action(msg)

    local input = utilities.input(msg.text)
    local id_str = tostring(msg.from.id)

    if string.match(msg.text_lower, '^'..self.config.cmd_pat..'lastfm') then
        utilities.send_message(msg.chat.id, lastfm.doc, true, msg.message_id, 'html')
        return
    elseif string.match(msg.text_lower, '^'..self.config.cmd_pat..'fmset') then
        if not input then
            utilities.send_message(msg.chat.id, lastfm.doc, true, msg.message_id, 'html')
        elseif input == '--' or input == utilities.char.em_dash then
            self.database.userdata.lastfm[id_str] = nil
            utilities.send_reply(msg, 'Your last.fm username has been forgotten.')
        else
            self.database.userdata.lastfm[id_str] = input
            utilities.send_reply(msg, 'Your last.fm username has been set to "' .. input .. '".')
        end
        return
    end

    local username
    local alert = ''
    if input then
        username = input
    elseif self.database.userdata.lastfm[id_str] then
        username = self.database.userdata.lastfm[id_str]
    elseif msg.from.username then
        username = msg.from.username
        alert = '\n\nYour username has been set to ' .. utilities.html_escape(username) .. '.\nTo change it, use '..self.config.cmd_pat..'fmset &lt;username&gt;.'
        self.database.userdata.lastfm[id_str] = username
    else
        utilities.send_reply(msg, 'Please specify your last.fm username or set it with '..self.config.cmd_pat..'fmset.')
        return
    end

    local orig = HTTP.TIMEOUT
    HTTP.TIMEOUT = 1
    local jstr, res = HTTP.request(lastfm.base_url .. URL.escape(username))
    HTTP.TIMEOUT = orig

    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)
    if jdat.error then
        utilities.send_reply(msg, 'Please specify your last.fm username or set it with '..self.config.cmd_pat..'fmset.')
        return
    end

    local track = jdat.recenttracks.track[1] or jdat.recenttracks.track
    if not track then
        utilities.send_reply(msg, 'No history for this user.' .. alert)
        return
    end

    local output = utilities.html_escape(input or msg.from.first_name)
    if track['@attr'] and track['@attr'].nowplaying then
        output = output .. ' is currently listening to:'
    else
        output = output .. ' last listened to:'
    end

    if msg.text_lower:match('^' .. self.config.cmd_pat .. 'npfull') then

        output = '<b>' .. utilities.html_escape(output) .. '</b>'
        if track.name and #track.name > 0 then
            output = output .. '\n🎵 ' .. utilities.html_escape(track.name)
        else
            output = output .. '\n🎵 Unknown'
        end
        if track.artist and track.artist['#text'] and #track.artist['#text'] > 0 then
            output = output .. '\n👤 ' .. utilities.html_escape(track.artist['#text'])
        end
        if track.album and track.album['#text'] and #track.album['#text'] > 0 then
            output = output .. '\n💿 ' .. utilities.html_escape(track.album['#text'])
        end
        -- album art
        if track.image and track.image[3] and #track.image[3]['#text'] > 0 then
            output = '<a href="' .. utilities.html_escape(track.image[3]['#text']) .. '">' .. utilities.char.zwnj .. '</a>' .. output
        end

    else

        output = output .. '\n'
        if track.artist and track.artist['#text'] and #track.artist['#text'] > 0 then
            output = output .. utilities.html_escape(track.artist['#text']) .. ' - '
        end
        output = output .. utilities.html_escape((track.name or 'Unknown'))

    end

    output = output .. alert

    utilities.send_message(msg.chat.id, output, nil, nil, 'html')

end

return lastfm
