local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('btc.COMMAND') .. ' <' .. I18N('btc.ARG_CURRENCY') .. '> [' .. I18N('btc.ARG_AMOUNT') .. ']' .. '\n' .. I18N('btc.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('btc.COMMAND')
}

function PLUGIN.action(msg)

	local url = nil
	local arg1 = 'USD'
	local arg2 = 1

	local jstr, res = HTTPS.request('https://api.bitcoinaverage.com/ticker/global/')

	if res ~= 200 then
		return send_msg(msg, I18N('CONNECTION_ERROR'))
	end

	local jdat = JSON.decode(jstr)

	if string.len(msg.text) > 6 then
		arg1 = string.upper(string.sub(msg.text, 6, 8))
	end
	if string.len(msg.text) > 9 then
		arg2 = string.sub(msg.text, 10)
		if not tonumber(arg2) then
			return send_msg(msg, I18N('INVALID_ARGUMENT'))
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
		return send_msg(msg, I18N('btc.CURRENCY_NOT_FOUND'))
	end

	jdat = JSON.decode(jstr)
	local m = arg2 .. ' BTC = ' .. jdat['24h_avg']*arg2 ..' '.. arg1 .. '\n'
	m = m .. arg2 ..' '.. arg1 .. ' = ' .. string.format("%.8f", arg2/jdat['24h_avg']) .. ' BTC'

	send_msg(msg, m)

end

return PLUGIN
