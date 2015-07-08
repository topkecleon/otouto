local PLUGIN = {}

PLUGIN.doc = [[
	' .. config.COMMAND_START .. 'busca <consulta>
	Realiza una busqueda en Google.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'busca ',
	'^' .. config.COMMAND_START .. 'search ',
	'^' .. config.COMMAND_START .. 'g ',
	'^' .. config.COMMAND_START .. 'google',
	'^' .. config.COMMAND_START .. 'gnsfw'
}

function PLUGIN.action(msg)

	local url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0'

	if not string.match(msg.text, '^' .. config.COMMAND_START .. 'gnsfw ') then
		url = url .. '&safe=active'
	end

	if not msg.chat.title then
		url = url .. '&rsz=8'
	end

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	url = url .. '&q=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, 'No pude conectarme, ' .. msg.from.first_name .. '...  ')
	end

	local jdat = JSON.decode(jstr)

	if #jdat.responseData.results < 1 then
		return send_msg(msg, 'No pude encontrar nada, ' .. msg.from.first_name .. '...  ')
	end

	message = ''

	for i = 1, #jdat.responseData.results do
		local result_url = jdat.responseData.results[i].unescapedUrl
		local result_title = jdat.responseData.results[i].titleNoFormatting
		message = message  .. ' - ' .. result_title ..'\n'.. result_url .. '\n'
	end

	send_msg(msg, message)

end

return PLUGIN
