-- utilities.lua
-- Functions shared among plugins.

local utilities = {}

local HTTP = require('socket.http')
local ltn12 = require('ltn12')
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local bindings = require('bindings')

 -- For the sake of ease to new contributors and familiarity to old contributors,
 -- we'll provide a couple of aliases to real bindings here.
function utilities:send_message(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)
	return bindings.request(self, 'sendMessage', {
		chat_id = chat_id,
		text = text,
		disable_web_page_preview = disable_web_page_preview,
		reply_to_message_id = reply_to_message_id,
		parse_mode = use_markdown and 'Markdown' or nil
	} )
end

function utilities:send_reply(old_msg, text, use_markdown)
	return bindings.request(self, 'sendMessage', {
		chat_id = old_msg.chat.id,
		text = text,
		disable_web_page_preview = true,
		reply_to_message_id = old_msg.message_id,
		parse_mode = use_markdown and 'Markdown' or nil
	} )
end

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

-- Calculates the length of the given string as UTF-8 characters
function utilities.utf8_len(s)
    local chars = 0
    for i = 1, string.len(s) do
        local b = string.byte(s, i)
        if b < 128 or b >= 192 then
            chars = chars + 1
        end
    end
    return chars
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
 -- Alternatively, abuse it to concat two strings like I do.
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

function utilities:user_from_message(msg, no_extra)

	local input = utilities.input(msg.text_lower)
	local target = {}
	if msg.reply_to_message then
		for k,v in pairs(self.database.users[msg.reply_to_message.from.id_str]) do
			target[k] = v
		end
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

	if not no_extra then
		if target.id then
			target.id_str = tostring(target.id)
		end
		if not target.first_name then
			target.first_name = 'User'
		end
		target.name = utilities.build_name(target.first_name, target.last_name)
	end

	return target

end

function utilities:handle_exception(err, message)

	if not err then err = '' end

	local output = '\n[' .. os.date('%F %T', os.time()) .. ']\n' .. self.info.username .. ': ' .. err .. '\n' .. message .. '\n'

	if self.config.log_chat then
		output = '```' .. output .. '```'
		utilities.send_message(self, self.config.log_chat, output, true, nil, true)
	else
		print(output)
	end

end

function utilities.download_file(url, filename)
	if not filename then
		filename = url:match('.+/(.-)$') or os.time()
		filename = '/tmp/' .. filename
	end
	local body = {}
	local doer = HTTP
	local do_redir = true
	if url:match('^https') then
		doer = HTTPS
		do_redir = false
	end
	local _, res = doer.request{
		url = url,
		sink = ltn12.sink.table(body),
		redirect = do_redir
	}
	if res ~= 200 then return false end
	local file = io.open(filename, 'w+')
	file:write(table.concat(body))
	file:close()
	return filename
end

function utilities.markdown_escape(text)
	text = text:gsub('_', '\\_')
	text = text:gsub('%[', '\\[')
	text = text:gsub('%]', '\\]')
	text = text:gsub('%*', '\\*')
	text = text:gsub('`', '\\`')
	return text
end

utilities.md_escape = utilities.markdown_escape

utilities.INVOCATION_PATTERN = '/'

utilities.triggers_meta = {}
utilities.triggers_meta.__index = utilities.triggers_meta
function utilities.triggers_meta:t(pattern, has_args)
	local username = self.username:lower()
	table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'$')
	table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'@'..username..'$')
	if has_args then
		table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'%s+[^%s]*')
		table.insert(self.table, '^'..utilities.INVOCATION_PATTERN..pattern..'@'..username..'%s+[^%s]*')
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

function utilities.pretty_float(x)
	if x % 1 == 0 then
		return tostring(math.floor(x))
	else
		return tostring(x)
	end
end

function utilities:create_user_entry(user)
	local id = tostring(user.id)
	-- Clear things that may no longer exist, or create a user entry.
	if self.database.users[id] then
		self.database.users[id].username = nil
		self.database.users[id].last_name = nil
	else
		self.database.users[id] = {}
	end
	-- Add all the user info to the entry.
	for k,v in pairs(user) do
		self.database.users[id][k] = v
	end
end

 -- This table will store unsavory characters that are not properly displayed,
 -- or are just not fun to type.
utilities.char = {
	zwnj = '‌',
	arabic = '[\216-\219][\128-\191]',
	rtl_override = '‮',
	rtl_mark = '‏',
	em_dash = '—'
}

return utilities
