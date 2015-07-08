local PLUGIN = {}

PLUGIN.triggers = {
	'^[^' .. config.COMMAND_START .. ']',
}

function esc(x)
	return (x:gsub('%%', '%%%%')
		:gsub('%^', '%%%^')
		:gsub('%$', '%%%$')
		:gsub('%(', '%%%(')
		:gsub('%)', '%%%)')
		:gsub('%.', '%%%.')
		:gsub('%[', '%%%[')
		:gsub('%]', '%%%]')
		:gsub('%*', '%%%*')
		:gsub('%+', '%%%+')
		:gsub('%-', '%%%-')
		:gsub('%?', '%%%?'))
end

function PLUGIN.action(msg)

	if msg then
		if string.match(string.lower(msg.text), string.lower(bot.username))
		--if string.match(esc(string.lower(msg.text)), esc(string.lower(bot.username)))
		or string.match(string.lower(msg.text), string.lower(bot.first_name))
		--or string.match(esc(string.lower(msg.text)), esc(string.lower(bot.first_name)))
		or msg.from.id == msg.chat.id
		or msg.reply_to_message and msg.reply_to_message.from.id == bot.id
		then

		else
			return
		end
	end
	
	local input = msg.text

	local url = 'http://www.simsimi.com/requestChat?lc=es&ft=1.0&req=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_message(msg.chat.id, "...")
	end

	local jdat = JSON.decode(jstr)

	if string.match(jdat.res, '^I HAVE NO RESPONSE.') then
		jdat.res = "Nani...? 😥"
	end

	local message = jdat.res:gsub('simsimi', 'clive')
	local message = message:gsub("^%l", string.upper)
	--if not string.match(message, '%p$') then
	--	message = message .. '.'
	--end

	send_message(msg.chat.id, message)
end

return PLUGIN
