local PLUGIN = {}

PLUGIN.doc = [[
	/xkcd [search]
	This command returns an xkcd strip, its number, and its "secret" text. You may search for a specific strip or get a random one.
]]

PLUGIN.triggers = {
	'^/xkcd'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	local url = 'http://xkcd.com/info.0.json'
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local latest = JSON.decode(jstr).num
	local jdat

	if input then
		url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=active&q=site%3axkcd%2ecom%20' .. URL.escape(input)
		local jstr, res = HTTP.request(url)
		if res ~= 200 then
			print('here')
			return send_msg(msg, config.locale.errors.connection)
		end
		jdat = JSON.decode(jstr)
		if #jdat.responseData.results == 0 then
			return send_msg(msg, config.locale.errors.results)
		end
		url = jdat.responseData.results[1].url .. 'info.0.json'
	else
		math.randomseed(os.time())
		url = 'http://xkcd.com/' .. math.random(latest) .. '/info.0.json'
	end

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	jdat = JSON.decode(jstr)

	local message = '[' .. jdat.num .. '] ' .. jdat.alt .. '\n' .. jdat.img

	send_message(msg.chat.id, message, false, msg.message_id)

end

return PLUGIN
