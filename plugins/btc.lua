local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.btc.command .. '\n' .. locale.btc.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.btc.command
}

function PLUGIN.action(msg)

	local url = nil
	local arg1 = 'USD'
	local arg2 = 1

	local jstr, res = HTTPS.request('https://api.bitcoinaverage.com/ticker/global/')

	if res ~= 200 then
		return send_msg(msg, locale.conn_err)
	end

	local jdat = JSON.decode(jstr)

	local input = get_input(msg.text)
	if input then
		arg1 = string.upper(string.sub(input, 1, 3))
		arg2 = string.sub(input, 5)
		if not tonumber(arg2) then
			return send_msg(msg, locale.inv_arg)
		end
	end

	for k,v in pairs(jdat) do
		if k == arg1 then
			url = v .. '/'
			break
		end
	end

	if url then
		jstr, b = HTTPS.request(url)
	else
		return send_msg(msg, locale.noresults)
	end

	jdat = JSON.decode(jstr)
	local m = arg2 .. ' BTC = ' .. jdat['24h_avg']*arg2 ..' '.. arg1 .. '\n'
	m = m .. arg2 ..' '.. arg1 .. ' = ' .. string.format("%.8f", arg2/jdat['24h_avg']) .. ' BTC'

	send_msg(msg, m)

end

return PLUGIN
