local triggers = {
	'^/index',
	'^/listgroups'
}

local dgmp_index = function(msg)

	local dgmp = load_data('dgmp.json')

	local input = get_input(msg.text)
	if not input then return end

	input = JSON.decode(input)
	if not input then return end

	local id = tostring(input.chatid)

	if not dgmp[id] then
		dgmp[id] = {}
	end
	group = dgmp[id]

	group.chatname = input.chatname
	if input.usercount then
		group.usercount = input.usercount
	end
	if input.description then
		group.description = input.description
	end
	if input.joininstructions then
		group.joininstructions = input.joininstructions
	end

	save_data('dgmp.json', dgmp)

end

local dgmp_list = function(msg)

	local dgmp = load_data('dgmp.json')

	local input = get_input(msg.text)
	if not input then
		input = ''
	else
		input = string.lower(input)
	end

	local output = ''
	for k,v in pairs(dgmp) do
		if string.find(string.lower(v.chatname), input) then
			output = output .. v.chatname .. ' (' .. k .. ')\n'
			if v.description then
				output = output .. v.description .. '\n'
			end
			if v.usercount then
				output = output .. 'Users: ' .. v.usercount .. '\n'
			end
			if v.joininstructions then
				output = output .. 'How to join: ' .. v.joininstructions .. '\n'
			end
			output = output .. '\n'
		end
	end

	if string.len(output) > 4000 then
		output = 'List is too long! Please use a (better) search query.'
	end

	output = trim_string(output)
	if string.len(output) == 0 then
		output = 'No results found.'
	end

	send_msg(msg, output)

end

local action = function(msg)

	if string.match(msg.text, '^/index') then
		dgmp_index(msg)
	elseif string.match(msg.text, '^/listgroups') then
		dgmp_list(msg)
	end

end

return {
	triggers = triggers,
	action = action
}
