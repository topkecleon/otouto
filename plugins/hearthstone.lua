 -- Plugin for the Hearthstone database provided by hearthstonejson.com.

if not hs_dat then

	hs_dat = {}

	local jstr, res = HTTPS.request('http://hearthstonejson.com/json/AllSets.json')
	if res ~= 200 then
		print('Error connecting to hearthstonejson.com.')
		print('hearthstone.lua will not be enabled.')
	end
	local jdat = JSON.decode(jstr)

	for k,v in pairs(jdat) do
		for key,val in pairs(v) do
			table.insert(hs_dat, val)
		end
	end

end

local doc = [[
	/hearthstone <query>
	Returns Hearthstone card info.
]]

local triggers = {
	'^/hearthstone[@'..bot.username..']*',
	'^/hs[@'..bot.username..']*$',
	'^/hs[@'..bot.username..']* '
}

local format_card = function(card)

	local ctype = card.type
	if card.race then
		ctype = card.race
	end
	if card.rarity then
		ctype = card.rarity .. ' ' .. ctype
	end
	if card.playerClass then
		ctype = ctype .. ' (' .. card.playerClass .. ')'
	elseif card.faction then
		ctype = ctype .. ' (' .. card.faction .. ')'
	end

	local stats
	if card.cost then
		stats = card.cost .. 'c'
		if card.attack then
			stats = stats .. ' | ' .. card.attack .. 'a'
		end
		if card.health then
			stats = stats .. ' | ' .. card.health .. 'h'
		end
		if card.durability then
			stats = stats .. ' | ' .. card.durability .. 'd'
		end
	elseif card.health then
		stats = card.health .. 'h'
	end

	local info = ''
	if card.text then
		info = card.text:gsub('</?.->',''):gsub('%$','')
		if card.flavor then
			info = info .. '\n' .. card.flavor
		end
	elseif card.flavor then
		info = card.flavor
	else
		info = nil
	end

	local s = card.name .. '\n' .. ctype
	if stats then
		s = s .. '\n' .. stats
	end
	if info then
		s = s .. '\n' .. info
	end

	return s

end

local action = function(msg)

	local input = msg.text_lower:input()
	if not input then
		sendReply(msg, doc)
		return
	end

	local output = ''
	for k,v in pairs(hs_dat) do
		if string.lower(v.name):match(input) then
			output = output .. format_card(v) .. '\n\n'
		end
	end

	output = output:trim()
	if output:len() == 0 then
		sendReply(msg, config.errors.results)
		return
	end

	sendReply(msg, output)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
