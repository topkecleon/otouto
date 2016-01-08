local doc = [[
	/pokedex <query>
	Returns a Pokedex entry from pokeapi.co.
]]

local triggers = {
	'^/pokedex[@'..bot.username..']*',
	'^/dex[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text_lower:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendReply(msg, doc)
			return
		end
	end

	local url = 'http://pokeapi.co'

	local dex_url = url .. '/api/v1/pokemon/' .. input
	local dex_jstr, res = HTTP.request(dex_url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local dex_jdat = JSON.decode(dex_jstr)

	local desc_url = url .. dex_jdat.descriptions[math.random(#dex_jdat.descriptions)].resource_uri
	local desc_jstr, res = HTTP.request(desc_url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local desc_jdat = JSON.decode(desc_jstr)

	local poke_type
	for i,v in ipairs(dex_jdat.types) do
		local type_name = v.name:gsub("^%l", string.upper)
		if not poke_type then
			poke_type = type_name
		else
			poke_type = poke_type .. ' / ' .. type_name
		end
	end
	poke_type = poke_type .. ' type'

	local message = dex_jdat.name .. ' #' .. dex_jdat.national_id .. '\n' .. poke_type .. '\nHeight: ' .. dex_jdat.height/10 .. 'm, Weight: ' .. dex_jdat.weight/10 .. 'kg\n' .. desc_jdat.description:gsub('POKMON', 'POKeMON')

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
