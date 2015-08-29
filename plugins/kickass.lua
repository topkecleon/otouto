 -- Kickass Torrents
 -- Based on @Imandaneshi's torrent.lua
 -- https://github.com/Imandaneshi/Jack/blob/master/plugins/torrent.lua

local doc = [[
	/torrent <query>
	Search Kickass Torrents. Results may be NSFW.
]]

local triggers = {
	'^/torrent',
	'^/kickass'
}

local action = function(msg)

	local url = 'http://kat.cr/json.php?q='

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, doc)
	end

	local jstr, res = HTTP.request(url..URL.escape(input))
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)
	if #jdat.total_results == 0 then
		return send_msg(msg, config.locale.errors.results)
	end

	local limit = 4 -- If the request is made in a PM, send 8 results instead of 4.
	if msg.chat.id == msg.from.id then
		limit = 8
	end
	if #jdat.total_results < limit then -- If there are not that many results, do as many as possible.
		limit = #jdat.total_results
	end

	for i,v in ipairs(jdat.list) do -- Remove any entries that have zero seeds.
		if v.seeds == 0 then
			table.remove(jdat.list, i)
		end
	end

	if #jdat.list == 0 then
		return send_msg(msg, config.locale.errors.results)
	end

	local message = ''
	for i = 1, limit do
		local torrenturl = jdat.list[i].torrentLink:sub(1, jdat.list[i].torrentLink:find('?')-1) -- Clean up the torrent link.
		message = message .. jdat.list[i].title .. '\n' .. jdat.list[i].category .. ' | ' .. string.format('%.3f', jdat.list[i].size/1000000) .. 'MB | ' .. jdat.list[i].seeds .. 'S/' .. jdat.list[i].peers .. 'L\n' .. torrenturl .. '\n\n'
	end

	message = message:gsub('&amp;', '&')

	send_msg(msg, message)

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	typing = true
}
