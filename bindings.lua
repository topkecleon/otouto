-- bindings.lua
-- Bindings for the Telegram bot API.
-- https://core.telegram.org/bots/api

assert(HTTPS)
assert(JSON)
assert(URL)

local BASE_URL = 'https://api.telegram.org/bot' .. config.bot_api_key

if config.bot_api_key == '' then
	error('You did not set your bot token in config.lua!')
end

sendRequest = function(url)

	local dat, res = HTTPS.request(url)

	local tab = JSON.decode(dat)

	if not tab.ok then
		return false, tab.description
	end

	return tab

end

getMe = function()

	local url = BASE_URL .. '/getMe'
	return sendRequest(url)

end

getUpdates = function(offset)

	local url = BASE_URL .. '/getUpdates?timeout=20'

	if offset then
		url = url .. '&offset=' .. offset
	end

	return sendRequest(url)

end

sendMessage = function(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown, disable_notification)

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

sendReply = function(msg, text)

	return sendMessage(msg.chat.id, text, true, msg.message_id)

end

sendChatAction = function(chat_id, action)
 -- Support actions are typing, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location

	local url = BASE_URL .. '/sendChatAction?chat_id=' .. chat_id .. '&action=' .. action
	return sendRequest(url)

end

sendLocation = function(chat_id, latitude, longitude, reply_to_message_id, disable_notification)

	if latitude == 0 then latitude = 0.001 end
	if longitude == 0 then longitude = 0.001 end

	local url = BASE_URL .. '/sendLocation?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

sendVenue = function(chat_id, latitude, longitude, title, address, foursquare_id, reply_to_message_id, disable_notification)

	if latitude == 0 then latitude = 0.001 end
	if longitude == 0 then longitude = 0.001 end

	local url = BASE_URL .. '/sendVenue?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude .. '&title=' .. title .. '&address=' .. address

	if foursquare_id then
		url = url .. '&foursquare_id=' .. foursquare_id
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

sendContact = function(chat_id, phone_number, first_name, last_name, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendContact?chat_id=' .. chat_id .. '&phone_number=' .. phone_number .. '&first_name=' .. first_name

	if last_name then
		url = url .. '&last_name=' .. last_name
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

forwardMessage = function(chat_id, from_chat_id, message_id, disable_notification)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

kickChatMember = function(chat_id, user_id)
	local url = BASE_URL .. '/kickChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
	return sendRequest(url)
end

unbanChatMember = function(chat_id, user_id)
	local url = BASE_URL .. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
	return sendRequest(url)
end

 -- TODO: More of this.

sendPhotoID = function(chat_id, file_id, caption, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id

	if caption then
		url = url .. '&caption=' .. URL.escape(caption)
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

curlRequest = function(curl_command)
 -- Use at your own risk. Will not check for success.

	io.popen(curl_command)

end

sendPhoto = function(chat_id, photo, caption, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendPhoto'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end

sendDocument = function(chat_id, document, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end

sendSticker = function(chat_id, sticker, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendSticker'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end

sendAudio = function(chat_id, audio, reply_to_message_id, duration, performer, title, disable_notification)

	local url = BASE_URL .. '/sendAudio'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "audio=@' .. audio .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	if performer then
		curl_command = curl_command .. ' -F "performer=' .. performer .. '"'
	end

	if title then
		curl_command = curl_command .. ' -F "title=' .. title .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end

sendVideo = function(chat_id, video, reply_to_message_id, duration, caption, disable_notification)

	local url = BASE_URL .. '/sendVideo'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "video=@' .. video .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end

sendVoice = function(chat_id, voice, reply_to_message_id, duration, disable_notification)

	local url = BASE_URL .. '/sendVoice'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "voice=@' .. voice .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return curlRequest(curl_command)

end
