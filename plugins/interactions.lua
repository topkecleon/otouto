local PLUGIN = {}

PLUGIN.triggers = {
	bot.first_name .. '%p?$',
	'^tadaima%p?$',
	'^i\'m home%p?$',
	'^i\'m back%p?$'
}

function PLUGIN.action(msg)

	local input = string.lower(msg.text)

	local data = load_data('nicknames.json')
	local id = tostring(msg.from.id)
	local nick = msg.from.first_name

	if data[id] then nick = data[id] end

	for i = 2, #PLUGIN.triggers do
		if string.match(input, PLUGIN.triggers[i]) then
			return send_message(msg.chat.id, 'Welcome back, ' .. nick .. '!')
		end
	end

	for k,v in pairs(config.locale.interactions) do
		for key,val in pairs(v) do
			if input:match(val..',? '..bot.first_name) then
				return send_message(msg.chat.id, latcyr(k:gsub('#NAME', nick)))
			end
		end
	end

end

return PLUGIN
