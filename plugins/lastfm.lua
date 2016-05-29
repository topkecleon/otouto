 -- TODO: Add support for librefm API.
 -- Just kidding, nobody actually uses that.

local lastfm = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('utilities')

function lastfm:init()
	if not self.config.lastfm_api_key then
		print('Missing config value: lastfm_api_key.')
		print('lastfm.lua will not be enabled.')
		return
	end

	lastfm.triggers = utilities.triggers(self.info.username):t('lastfm', true):t('np', true):t('fmset', true).table
end

lastfm.command = 'lastfm'
lastfm.doc = [[```
/np [username]
Returns what you are or were last listening to. If you specify a username, info will be returned for that username.

/fmset <username>
Sets your last.fm username. Otherwise, /np will use your Telegram username. Use "/fmset --" to delete it.
```]]

function lastfm:action(msg)

	local input = utilities.input(msg.text)

	if string.match(msg.text, '^/lastfm') then
		utilities.send_message(self, msg.chat.id, lastfm.doc, true, msg.message_id, true)
		return
	elseif string.match(msg.text, '^/fmset') then
		if not input then
			utilities.send_message(self, msg.chat.id, lastfm.doc, true, msg.message_id, true)
		elseif input == '--' or input == utilities.char.em_dash then
			self.database.users[msg.from.id_str].lastfm = nil
			utilities.send_reply(self, msg, 'Your last.fm username has been forgotten.')
		else
			self.database.users[msg.from.id_str].lastfm = input
			utilities.send_reply(self, msg, 'Your last.fm username has been set to "' .. input .. '".')
		end
		return
	end

	local url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&api_key=' .. self.config.lastfm_api_key .. '&user='

	local username
	local alert = ''
	if input then
		username = input
	elseif self.database.users[msg.from.id_str].lastfm then
		username = self.database.users[msg.from.id_str].lastfm
	elseif msg.from.username then
		username = msg.from.username
		alert = '\n\nYour username has been set to ' .. username .. '.\nTo change it, use /fmset <username>.'
		self.database.users[msg.from.id_str].lastfm = username
	else
		utilities.send_reply(self, msg, 'Please specify your last.fm username or set it with /fmset.')
		return
	end

	url = url .. URL.escape(username)

	local jstr, res
	utilities.with_http_timeout(
		1, function ()
			jstr, res = HTTP.request(url)
	end)
	if res ~= 200 then
		utilities.send_reply(self, msg, self.config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.error then
		utilities.send_reply(self, msg, 'Please specify your last.fm username or set it with /fmset.')
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
