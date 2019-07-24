--[[
    lastfm.lua
    Returns "now playing" info from last.fm.

    Copyright 2019 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local url = require('socket.url')
local http = require('socket.http')
local json = require('dkjson')

local utilities = require('otouto.utilities')
local bindings = require('extern.bindings')

local p = {}

function p:init(bot)
    assert(bot.config.lastfm_api_key,
        'Missing config value: lastfm_api_key. user.lastfm will not work \z
        without a last.fm API key.')
    self.url = 'http://ws.audioscrobbler.com/2.0/?method=user.getRecentTracks&api_key=' ..
        bot.config.lastfm_api_key .. '&format=json&limit=1&user='
    self.test_url = 'http://ws.audioscrobbler.com/2.0/?method=user.getInfo&api_key=' ..
        bot.config.lastfm_api_key .. '&format=json&user='

    self.command = 'np [username]'
    self.doc = "Shows the currently playing or last played track \z
        from last.fm.\nYou may specify your last.fm username after the \z
        command. After that, it will be stored. Otherwise, your Telegram \z
        username will be tried. You may delete your stored last.fm username \z
        with " .. bot.config.cmd_pat .. "np --."
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('np', true).table

    if not bot.database.userdata.lastfm then
        bot.database.userdata.lastfm = {}
    end

    self.notices = {
        deleted = 'Your last.fm username has been deleted.',
        invalid = 'Invalid last.fm username.',
        specify = 'Please specify your last.fm username, eg ' ..
        bot.config.cmd_pat .. 'np durov'
    }
end

function p:test_username(uname)
    local jstr, res = http.request(self.test_url .. url.escape(uname))
    if res == 200 then
        if json.decode(jstr).error then
            return false
        else
            return true
        end
    else
        return false
    end
end

function p.format_track(track, dname)
    return string.format(
        '<b>Now Playing for %s</b>\n🎵 <a href="%s">%s</a>\n👤 %s\n💿 %s',
        utilities.html_escape(dname),
        track.url,
        utilities.html_escape(track.name),
        utilities.html_escape(track.artist["#text"]),
        utilities.html_escape(track.album["#text"])
    )
end

function p.format_error(data)
    return string.format(
        '<b>Error %s:</b> %s',
        data.error,
        data.message
    )
end

 -- returns text and optional image URL
 -- Whether or not the URL is returned determines whether sendMessage is used
 -- or sendPhoto is used.
function p:fetch(uname, dname)
    local jstr, res = http.request(self.url .. url.escape(uname))
    local output, img_url
    if res == 200 then
        local data = json.decode(jstr)
        if data.recenttracks then
            local track = data.recenttracks.track[1]
            for _, image in pairs(track.image) do
                if image.size == 'extralarge' then
                    img_url = image["#text"]
                    break
                end
            end
            output = self.format_track(track, dname)
        elseif data.error then
            output = self.format_error(data)
        else
            error("Unknown response from last.fm API.\n" .. jstr)
        end
    else
        output = false
    end
    return output, img_url
end

function p:action(bot, msg, _, user)
    local input = utilities.input(msg.text)
    local dname = user:display_name()
    -- Returned by self.fetch. If img_url is present, sendPhoto is used.
    local output, img_url

    -- Delete username.
    if input == '--' or input == utilities.char.em_dash then
        user.data.lastfm = nil
        output = self.notices.deleted

    -- Set username to input, or to TG username if user.data.lastfm not set.
    elseif input or (msg.from.username and not user.data.lastfm) then
        -- err if invalid username
        local new_username = input or msg.from.username
        local valid_username = self:test_username(new_username)
        if valid_username then
            user.data.lastfm = new_username
            output, img_url = self:fetch(new_username, dname)
            output = output .. "\n\nYour last.fm username has been set to <b>" ..
                utilities.html_escape(new_username) .. "</b>. You may change \z
                it by specifying your last.fm username in the command, eg " ..
                bot.config.cmd_pat .. "np durov"
        elseif input then
            output = self.notices.invalid
        else
            output = self.notices.specify
        end

    -- Use user.data.lastfm.
    elseif user.data.lastfm then -- results
        output, img_url = self:fetch(user.data.lastfm, dname)

    else
        output = self.notices.specify
    end

    if img_url then
        bindings.sendPhoto{
            photo = img_url,
            caption = output,
            parse_mode = 'html',
            chat_id = msg.chat.id
        }
    elseif output then
        bindings.sendMessage{
            text = output,
            parse_mode = 'html',
            chat_id = msg.chat.id,
            disable_web_page_preview = true
        }
    else
        bindings.sendMessage{
            text = bot.config.errors.connection,
            chat_id = msg.chat.id,
            reply_to_message_id = msg.reply_to_message.message_id
        }
    end
end

return p