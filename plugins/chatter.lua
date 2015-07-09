 -- shout-out to @luksi_reiku for showing me this site

local PLUGIN = {}

PLUGIN.triggers = {
	'^@' .. bot.username .. ', ',
	'^' .. bot.first_name .. ', '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)

	local url = 'http://www.simsimi.com/requestChat?lc=en&ft=1.0&req=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_message(msg.chat.id, I18N('chatter.CONNECTION_ERROR'))
	end

	local jdat = JSON.decode(jstr)

	if string.match(jdat.res, '^I HAVE NO RESPONSE.') then
		jdat.res = I18N('chatter.I_HAVE_NO_RESPONSE')
	end

	local message = jdat.res

	-- Let's clean up the response a little. Capitalization & punctuation.
	filter = {
		['%aim%aimi'] = bot.first_name,
		['^%s*(.-)%s*$'] = '%1',
		['^%l'] = string.upper
	}

	for k,v in pairs(filter) do
		message = string.gsub(message, k, v)
	end

	if not string.match(message, '%p$') then
		message = message .. '.'
	end

	send_message(msg.chat.id, message)

end

return PLUGIN
