-- utilities.lua
-- Functions shared among plugins.

local utilities = {}

local HTTP = require('socket.http')
local ltn12 = require('ltn12')
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('cjson')
local bindings = require('bindings')

 -- get the indexed word in a string
function utilities.get_word(s, i)

	s = s or ''
	i = i or 1

	local t = {}
	for w in s:gmatch('%g+') do
		table.insert(t, w)
	end

	return t[i] or false

end

 -- Like get_word(), but better.
 -- Returns the actual index.
function utilities.index(s)
	local t = {}
	for w in s:gmatch('%g+') do
		table.insert(t, w)
	end
	return t
end

 -- Returns the string after the first space.
function utilities.input(s)
	if not s:find(' ') then
		return false
	end
	return s:sub(s:find(' ')+1)
end

 -- I swear, I copied this from PIL, not yago! :)
function utilities.trim(str) -- Trims whitespace from a string.
	local s = str:gsub('^%s*(.-)%s*$', '%1')
	return s
end

local lc_list = {
-- Latin = 'Cyrillic'
	['A'] = 'А',
	['B'] = 'В',
	['C'] = 'С',
	['E'] = 'Е',
	['I'] = 'І',
	['J'] = 'Ј',
	['K'] = 'К',
	['M'] = 'М',
	['H'] = 'Н',
	['O'] = 'О',
	['P'] = 'Р',
	['S'] = 'Ѕ',
	['T'] = 'Т',
	['X'] = 'Х',
	['Y'] = 'Ү',
	['a'] = 'а',
	['c'] = 'с',
	['e'] = 'е',
	['i'] = 'і',
	['j'] = 'ј',
	['o'] = 'о',
	['s'] = 'ѕ',
	['x'] = 'х',
	['y'] = 'у',
	['!'] = 'ǃ'
}

 -- Replaces letters with corresponding Cyrillic characters.
function utilities.latcyr(str)
	for k,v in pairs(lc_list) do
		str = str:gsub(k, v)
	end
	return str
end

 -- Loads a JSON file as a table.
function utilities.load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

 -- Saves a table to a JSON file.
function utilities.save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end

 -- Gets coordinates for a location. Used by gMaps.lua, time.lua, weather.lua.
function utilities:get_coords(input)

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return self.config.errors.connection
	end

	local jdat = JSON.decode(jstr)
	if jdat.status == 'ZERO_RESULTS' then
		return self.config.errors.results
	end

	return {
		lat = jdat.results[1].geometry.location.lat,
		lon = jdat.results[1].geometry.location.lng
	}

end

 -- Get the number of values in a key/value table.
function utilities.table_size(tab)

	local i = 0
	for _,_ in pairs(tab) do
		i = i + 1
	end
	return i

end

 -- Just an easy way to get a user's full name.
function utilities.build_name(first, last)
	if last then
		return first .. ' ' .. last
	else
		return first
	end
end

function utilities:resolve_username(input)

	input = input:gsub('^@', '')
	for _,v in pairs(self.database.users) do
		if v.username and v.username:lower() == input:lower() then
			return v
		end
	end

end

function utilities:user_from_message(msg)

	local input = utilities.input(msg.text_lower)
	local target = {}
	if msg.reply_to_message then
		target = msg.reply_to_message.from
	elseif input and tonumber(input) then
		target.id = tonumber(input)
		if self.database.users[input] then
			for k,v in pairs(self.database.users[input]) do
				target[k] = v
			end
		end
	elseif input and input:match('^@') then
		local uname = input:gsub('^@', '')
		for _,v in pairs(self.database.users) do
			if v.username and uname == v.username:lower() then
				for key, val in pairs(v) do
					target[key] = val
				end
			end
		end
		if not target.id then
			target.err = 'Sorry, I don\'t recognize that username.'
		end
	else
		target.err = 'Please specify a user via reply, ID, or username.'
	end

	if target.id then
		target.id_str = tostring(target.id)
	end

	if not target.first_name then target.first_name = 'User' end

	target.name = utilities.build_name(target.first_name, target.last_name)

	return target

end

function utilities:handle_exception(err, message)

	if not err then err = '' end

	local output = '\n[' .. os.date('%F %T', os.time()) .. ']\n' .. self.info.username .. ': ' .. err .. '\n' .. message .. '\n'

	if self.config.log_chat then
		output = '```' .. output .. '```'
		bindings.sendMessage(self, self.config.log_chat, output, true, nil, true)
	else
		print(output)
	end

end

 -- Okay, this one I actually did copy from yagop.
 -- https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
function utilities.download_file(url, filename)

	local respbody = {}
	local options = {
		url = url,
		sink = ltn12.sink.table(respbody),
		redirect = true
	}

	local response

	if url:match('^https') then
		options.redirect = false
		response = { HTTPS.request(options) }
	else
		response = { HTTP.request(options) }
	end

	local code = response[2]
	local headers = response[3]
	local status = response[4]

	if code ~= 200 then return false end

	filename = filename or '/tmp/' .. os.time()

	local file = io.open(filename, 'w+')
	file:write(table.concat(respbody))
	file:close()

	return filename

end

function utilities.markdown_escape(text)

	text = text:gsub('_', '\\_')
	text = text:gsub('%[', '\\[')
	text = text:gsub('%*', '\\*')
	text = text:gsub('`', '\\`')
	return text

end

function utilities.md_escape(s)
	s = s:gsub('_', '\\_')
	s = s:gsub('%[', '\\[')
	s = s:gsub('%*', '\\*')
	s = s:gsub('`', '\\`')
	return s
end

utilities.INVOCATION_PATTERN = '/'

utilities.triggers_meta = {}
utilities.triggers_meta.__index = utilities.triggers_meta
function utilities.triggers_meta:t(pattern, has_args)
	table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'$')
	table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'@'..self.username..'$')
	if has_args then
		table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'%s+[^%s]*')
		table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'@'..self.username..'%s+[^%s]*')
	end
	return self
end

function utilities.triggers(username, trigger_table)
	local self = setmetatable({}, utilities.triggers_meta)
	self.username = username
	self.table = trigger_table or {}
	return self
end

function utilities.with_http_timeout(timeout, fun)
	local original = HTTP.TIMEOUT
	HTTP.TIMEOUT = timeout
	fun()
	HTTP.TIMEOUT = original
end

function utilities.enrich_user(user)
	user.id_str = tostring(user.id)
	user.name = utilities.build_name(user.first_name, user.last_name)
	return user
end

function utilities.enrich_message(msg)
	if not msg.text then msg.text = msg.caption or '' end
	msg.text_lower = msg.text:lower()
	msg.from = utilities.enrich_user(msg.from)
	msg.chat.id_str = tostring(msg.chat.id)
	if msg.reply_to_message then
		if not msg.reply_to_message.text then
			msg.reply_to_message.text = msg.reply_to_message.caption or ''
		end
		msg.reply_to_message.text_lower = msg.reply_to_message.text:lower()
		msg.reply_to_message.from = utilities.enrich_user(msg.reply_to_message.from)
		msg.reply_to_message.chat.id_str = tostring(msg.reply_to_message.chat.id)
	end
	if msg.forward_from then
		msg.forward_from = utilities.enrich_user(msg.forward_from)
	end
	if msg.new_chat_participant then
		msg.new_chat_participant = utilities.enrich_user(msg.new_chat_participant)
	end
	if msg.left_chat_participant then
		msg.left_chat_participant = utilities.enrich_user(msg.left_chat_participant)
	end
	return msg
end

return utilities
