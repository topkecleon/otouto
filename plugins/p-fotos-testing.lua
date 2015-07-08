local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'testi',
}

PLUGIN.exts = {
	'.png$',
	'.jpg$',
	'.jpeg$',
	'.jpe$',
	'.gif$'
}

function PLUGIN.action(msg)

	local url = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8'

	if (not string.match(msg.text, '^' .. config.COMMAND_START .. 'insfw ')) or (not string.match(msg.text, '^/fotonsfw ')) then
		url = url .. '&safe=active'
	end

	local input = get_input(msg.text)
	if not input then
		return
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		send_msg(msg, 'No pude conectarme, ' .. msg.from.first_name .. '...  ')
		return
	end

	local jdat = JSON.decode(jstr)

	if #jdat.responseData.results < 1 then
		send_msg(msg, 'No pude encontrar nada, ' .. msg.from.first_name .. '... 😔')
		return
	end

	is_real = false
	while is_real == false do
		local i = math.random(#jdat.responseData.results)
		result_url = jdat.responseData.results[i].url
		for i,v in pairs(PLUGIN.exts) do
			if string.match(string.lower(result_url), v) then
				is_real = true
			end
		end
	end
	
	--send the url
	send_msg(msg, result_url)
	
	--local path = download_to_file(result_url, 'photo.jpg')
	local photo = get_file('sample.jpg')
	
	--send the photo
	send_pic(msg, photo)

end

return PLUGIN
