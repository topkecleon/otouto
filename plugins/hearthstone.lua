 -- Get info for a hearthstone card.

local jstr, res = HTTP.request('http://hearthstonejson.com/json/AllSets.json')
if res ~= 200 then
	return print('Error connecting to the Hearthstone database. hearthstone.lua will not be enabled.')
end
jdat = JSON.decode(jstr)
hs_dat = {}

for k,v in pairs(jdat) do
	for key,val in pairs(v) do
		table.insert(hs_dat, val)
	end
end

local doc = [[
	/hearthstone <card>
	Get information about a Hearthstone card.
]]

local triggers = {
	'^/hearthstone',
	'^/hs'
}

local fmt_card = function(card)

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

	local input = get_input(msg.text)
	if not input then return send_msg(msg, doc) end
	input = string.lower(input)

	local output = ''
	for k,v in pairs(hs_dat) do
		if string.match(string.lower(v.name), input) then
			output = output .. fmt_card(v) .. '\n\n'
		end
	end

	output = trim_string(output)
	if string.len(output) == 0 then
		return send_msg(msg, config.locale.errors.results)
	end

	send_msg(msg, output)

end

return {
	doc = doc,
	triggers = triggers,
	action = action
}
