local PLUGIN = {}

PLUGIN.doc = [[
	/torrent <query>
	Search for torrent !
]]

PLUGIN.triggers = {

	'^/torrent'
}

function PLUGIN.action(msg)

	local url = 'http://kat.cr/json.php'


	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			msg = msg.reply_to_message
			input = msg.text
		else
			return send_msg(msg, PLUGIN.doc)
		end
	end

	url = url .. '?q=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)

	if #jdat.total_results < 1 then
		return send_msg(msg, config.locale.errors.results)
	end

	local message = ''

	for i = 1, #jdat.total_results do
		local result_url = jdat.list[i].torrentLink
		local result_title = jdat.list[i].title
		local result_category = jdat.list[i].category
		local result_peers = jdat.list[i].peers
		local result_seeds = jdat.list[i].seeds
		local result_size = jdat.list[i].size
		local result_guid = jdat.list[i].guid
		message = message  .. ' - ' .. result_title ..'\n'.. result_url .. '\n'..'ategory:'..result_category..'\n'..'Peers:'..result_peers..'\n'..'Seeds:'..result_seeds..'\n'..'Size:'..result_size..'\n'..'Guid:'..result_guid..'\n'
	end

	local message = message:gsub('&amp;', '&') -- blah

	send_msg(msg, message)

end

return PLUGIN
