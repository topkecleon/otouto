-- bindings.lua
-- Functions for the Telegram API.
-- Requires ssl.https ('HTTPS'), socket.url ('URL'), and a json decoder ('JSON').
-- Also requires config.bot_api_key.

local BASE_URL = 'https://api.telegram.org/bot' .. config.bot_api_key .. '/'

local function send_request(url)

	local dat, res = HTTPS.request(url)
	local tab = JSON.decode(dat)

	if res ~= 200 then
		print('Connection error.')
		return false
	end

	if not tab.ok then
		print(tab.description)
		return false
	end

	return tab

end

function get_me()

	local url = BASE_URL .. 'getMe'
	return send_request(url)

end

function get_updates(offset)

	local url = BASE_URL .. 'getUpdates'

	if offset then
		url = url .. '?offset=' .. offset
	end

	return send_request(url)

end

function send_message(chat_id, text, disable_web_page_preview, reply_to_message_id)

	local url = BASE_URL .. 'sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	return send_request(url)

end

function send_chat_action(chat_id, action)

	local url = BASE_URL .. 'sendChatAction?chat_id=' .. chat_id .. '&action=' .. action
	return send_request(url)

end

function send_location(chat_id, latitude, longitude, reply_to_message_id)

	local url = BASE_URL .. 'sendLocation?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	return send_request(url)

end

function forward_message(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. 'forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return send_request(url)

end
