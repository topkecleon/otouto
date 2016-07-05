 -- TODO: Add support for librefm API.
 -- Just kidding, nobody actually uses that.

local lastfm = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

function lastfm:init(config)
	if not config.lastfm_api_key then
		print('Missing config value: lastfm_api_key.')
		print('lastfm.lua will not be enabled.')
		return
	end

	lastfm.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('lastfm', true):t('np', true):t('fmset', true).table
	lastfm.doc = [[```
]]..config.cmd_pat..[[np [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

]]..config.cmd_pat..[[fmset <username>
Sets your last.fm username. Otherwise, ]]..config.cmd_pat..[[np will use your Telegram username. Use "]]..config.cmd_pat..[[fmset --" to delete it.
```]]
end

lastfm.command = 'lastfm'

function lastfm:action(msg, config)

	local input = utilities.input(msg.text)
	local from_id_str = tostring(msg.from.id)
	self.database.userdata[from_id_str] = self.database.userdata[from_id_str] or {}

	if string.match(msg.text, '^'..config.cmd_pat..'lastfm') then
		utilities.send_message(self, msg.chat.id, lastfm.doc, true, msg.message_id, true)
		return
	elseif string.match(msg.text, '^'..config.cmd_pat..'fmset') then
		if not input then
			utilities.send_message(self, msg.chat.id, lastfm.doc, true, msg.message_id, true)
		elseif input == '--' or input == utilities.char.em_dash then
			self.database.userdata[from_id_str].lastfm = nil
			utilities.send_reply(self, msg, 'Your last.fm username has been forgotten.')
		else
			self.database.userdata[from_id_str].lastfm = input
			utilities.send_reply(self, msg, 'Your last.fm username has been set to "' .. input .. '".')
		end
		return
	end

	local url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. config.lastfm_api_key .. '&user='

	local username
	local alert = ''
	if input then
		username = input
	elseif self.database.userdata[from_id_str].lastfm then
		username = self.database.userdata[from_id_str].lastfm
	elseif msg.from.username then
		username = msg.from.username
		alert = '\n\nYour username has been set to ' .. username .. '.\nTo change it, use '..config.cmd_pat..'fmset <username>.'
		self.database.userdata[from_id_str].lastfm = username
	else
		utilities.send_reply(self, msg, 'Please specify your last.fm username or set it with '..config.cmd_pat..'fmset.')
		return
	end

	url = url .. URL.escape(username)

	local jstr, res
	utilities.with_http_timeout(
		1, function ()
			jstr, res = HTTP.request(url)
	end)
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.error then
		utilities.send_reply(self, msg, 'Please specify your last.fm username or set it with '..config.cmd_pat..'fmset.')
		return
	end

	jdat = jdat.recenttracks.track[1] or jdat.recenttracks.track
	if not jdat then
		utilities.send_reply(self, msg, 'No history for this user.' .. alert)
		return
	end

	local output = input or msg.from.first_name
	output = '🎵  ' .. output

	if jdat['@attr'] and jdat['@attr'].nowplaying then
		output = output .. ' is currently listening to:\n'
	else
		output = output .. ' last listened to:\n'
	end

	local title = jdat.name or 'Unknown'
	local artist = 'Unknown'
	if jdat.artist then
		artist = jdat.artist['#text']
	end

	output = output .. title .. ' - ' .. artist .. alert
	utilities.send_message(self, msg.chat.id, output)

end

return lastfm
