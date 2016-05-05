 -- Put this absolutely at the end, even after greetings.lua.

if not config.simsimi_key then
	print('Missing config value: simsimi_key.')
	print('chatter.lua will not be enabled.')
	return
end

local triggers = {
	'',
	'^' .. bot.first_name .. ',',
	'^@' .. bot.username .. ','
}

local action = function(msg)

	if msg.text == '' then return end

	-- This is awkward, but if you have a better way, please share.
	if msg.text_lower:match('^' .. bot.first_name .. ',') then
	elseif msg.text_lower:match('^@' .. bot.username .. ',') then
	elseif msg.text:match('^/') then
		return true
	-- Uncomment the following line for Al Gore-like reply chatter.
	-- elseif msg.reply_to_message and msg.reply_to_message.from.id == bot.id then
	elseif msg.from.id == msg.chat.id then
	else
		return true
	end

	sendChatAction(msg.chat.id, 'typing')

	local input = msg.text_lower
	input = input:gsub(bot.first_name, 'simsimi')
	input = input:gsub('@'..bot.username, 'simsimi')

	if config.simsimi_trial then
		sandbox = 'sandbox.'
	else
		sandbox = '' -- NO Sandbox
	end

	local url = 'http://' ..sandbox.. 'api.simsimi.com/request.p?key=' ..config.simsimi_key.. '&lc=' ..config.lang.. '&ft=1.0&text=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendMessage(msg.chat.id, config.errors.chatter_connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if not jdat.response then
		sendMessage(msg.chat.id, config.errors.chatter_response)
		return
	end
	local output = jdat.response

	if output:match('^I HAVE NO RESPONSE.') then
		output = config.errors.chatter_response
	end

	-- Let's clean up the response a little. Capitalization & punctuation.
	local filter = {
		['%aimi?%aimi?'] = bot.first_name,
		['^%s*(.-)%s*$'] = '%1',
		['^%l'] = string.upper,
		['USER'] = msg.from.first_name
	}

	for k,v in pairs(filter) do
		output = string.gsub(output, k, v)
	end

	if not string.match(output, '%p$') then
		output = output .. '.'
	end

	sendMessage(msg.chat.id, output, true,msg.message_id,false) --Reply to writing

end

return {
	action = action,
	triggers = triggers
}
