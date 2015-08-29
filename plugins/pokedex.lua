local PLUGIN = {}

PLUGIN.doc = [[
	/dex <pokemon>
	Get Pokedex information for a given Pokemon.
	Includes national ID number, type, height, weight, and a description from a random regional dex.
]]

PLUGIN.triggers = {
	'^/dex'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text:lower())
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local base_url = 'http://pokeapi.co'
	local poke_type = nil

	local dex_url = base_url .. '/api/v1/pokemon/' .. input
	local dex_jstr, res = HTTP.request(dex_url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.results)
	end

	local dex_jdat = JSON.decode(dex_jstr)

	local desc_url = base_url .. dex_jdat.descriptions[math.random(#dex_jdat.descriptions)].resource_uri
	local desc_jstr, res = HTTP.request(desc_url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local desc_jdat = JSON.decode(desc_jstr)

	for k,v in pairs(dex_jdat.types) do
		local type_name = v.name:gsub("^%l", string.upper)
		if not poke_type then
			poke_type = type_name
		else
			poke_type = poke_type .. ' / ' .. type_name
		end
	end
	poke_type = poke_type .. ' type'

	local info_line = 'Height: ' .. dex_jdat.height/10 .. 'm, Weight: ' .. dex_jdat.weight/10 .. 'kg'

	local m = dex_jdat.name ..' #'.. dex_jdat.national_id ..'\n'.. poke_type ..'\n'.. info_line ..'\n'.. desc_jdat.description:gsub('POKMON', 'POKeMON')

	send_msg(msg, m)

end

return PLUGIN
