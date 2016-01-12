-- utilities.lua
-- Functions shared among plugins.

 -- get the indexed word in a string
get_word = function(s, i)

	s = s or ''
	i = i or 1

	local t = {}
	for w in s:gmatch('%g+') do
		table.insert(t, w)
	end

	return t[i] or false

end

 -- Returns the string after the first space.
function string:input()
	if not self:find(' ') then
		return false
	end
	return self:sub(self:find(' ')+1)
end

 -- I swear, I copied this from PIL, not yago! :)
function string:trim() -- Trims whitespace from a string.
	local s = self:gsub('^%s*(.-)%s*$', '%1')
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
latcyr = function(str)
	for k,v in pairs(lc_list) do
		str = string.gsub(str, k, v)
	end
	return str
end

 -- Loads a JSON file as a table.
load_data = function(filename)

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
save_data = function(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end

 -- Gets coordinates for a location. Used by gMaps.lua, time.lua, weather.lua.
get_coords = function(input)

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return config.errors.connection
	end

	local jdat = JSON.decode(jstr)
	if jdat.status == 'ZERO_RESULTS' then
		return config.errors.results
	end

	return {
		lat = jdat.results[1].geometry.location.lat,
		lon = jdat.results[1].geometry.location.lng
	}

end

 -- Get the number of values in a key/value table.
table_size = function(tab)

	local i = 0
	for k,v in pairs(tab) do
		i = i + 1
	end
	return i

end

resolve_username = function(target)
 -- If $target is a known username, returns associated ID.
 -- If $target is an unknown username, returns nil.
 -- If $target is a number, returns that number.
 -- Otherwise, returns false.

	local input = tostring(target):lower()
	if input:match('^@') then
		local uname = input:gsub('^@', '')
		return usernames[uname]
	else
		return tonumber(target) or false
	end

end
