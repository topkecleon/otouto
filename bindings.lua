-- bindings.lua
-- Bindings for the Telegram bot API.
-- https://core.telegram.org/bots/api

local bindings = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local URL = require('socket.url')

function bindings.sendRequest(url)

	local dat, res = HTTPS.request(url)

	if not dat then return false, res end

	local tab = JSON.decode(dat)

	if not tab.ok then
		return false, tab.description
	end

	return tab

end

function bindings:getMe()

	local url = self.BASE_URL .. '/getMe'
	return bindings.sendRequest(url)

end

function bindings:getUpdates(offset)

	local url = self.BASE_URL .. '/getUpdates?timeout=20'

	if offset then
		url = url .. '&offset=' .. offset
	end

	return bindings.sendRequest(url)

end

function bindings:sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown, disable_notification)

	local url = self.BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

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

	return bindings.sendRequest(url)

end

function bindings:sendReply(msg, text, use_markdown, disable_notification)

	return bindings.sendMessage(self, msg.chat.id, text, true, msg.message_id, use_markdown, disable_notification)

end

function bindings:sendChatAction(chat_id, action)
 -- Support actions are typing, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location

	local url = self.BASE_URL .. '/sendChatAction?chat_id=' .. chat_id .. '&action=' .. action
	return bindings.sendRequest(url)

end

function bindings:sendLocation(chat_id, latitude, longitude, reply_to_message_id, disable_notification)

	if latitude == 0 then latitude = 0.001 end
	if longitude == 0 then longitude = 0.001 end

	local url = self.BASE_URL .. '/sendLocation?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return bindings.sendRequest(url)

end

function bindings:sendVenue(chat_id, latitude, longitude, title, address, foursquare_id, reply_to_message_id, disable_notification)

	if latitude == 0 then latitude = 0.001 end
	if longitude == 0 then longitude = 0.001 end

	local url = self.BASE_URL .. '/sendVenue?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude .. '&title=' .. title .. '&address=' .. address

	if foursquare_id then
		url = url .. '&foursquare_id=' .. foursquare_id
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return bindings.sendRequest(url)

end

function bindings.sendContact(chat_id, phone_number, first_name, last_name, reply_to_message_id, disable_notification)

	local url = self.BASE_URL .. '/sendContact?chat_id=' .. chat_id .. '&phone_number=' .. phone_number .. '&first_name=' .. first_name

	if last_name then
		url = url .. '&last_name=' .. last_name
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return bindings.sendRequest(url)

end

function bindings:forwardMessage(chat_id, from_chat_id, message_id, disable_notification)

	local url = self.BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return bindings.sendRequest(url)

end

function bindings:kickChatMember(chat_id, user_id)
	local url = self.BASE_URL .. '/kickChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
	return bindings.sendRequest(url)
end

function bindings:unbanChatMember(chat_id, user_id)
	local url = self.BASE_URL .. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
	return bindings.sendRequest(url)
end

 -- TODO: More of this.

function bindings:sendPhotoID(chat_id, file_id, caption, reply_to_message_id, disable_notification)

	local url = self.BASE_URL .. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id

	if caption then
		url = url .. '&caption=' .. URL.escape(caption)
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return bindings.sendRequest(url)

end

function bindings.curlRequest(curl_command)
 -- Use at your own risk. Will not check for success.

	io.popen(curl_command)

end

function bindings:sendPhoto(chat_id, photo, caption, reply_to_message_id, disable_notification)

	local url = self.BASE_URL .. '/sendPhoto'

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

	return bindings.curlRequest(curl_command)

end

function bindings:sendDocument(chat_id, document, reply_to_message_id, disable_notification)

	local url = self.BASE_URL .. '/sendDocument'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return bindings.curlRequest(curl_command)

end

function bindings:sendSticker(chat_id, sticker, reply_to_message_id, disable_notification)

	local url = self.BASE_URL .. '/sendSticker'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if disable_notification then
		curl_command = curl_command .. ' -F "disable_notification=true"'
	end

	return bindings.curlRequest(curl_command)

end

function bindings:sendAudio(chat_id, audio, reply_to_message_id, duration, performer, title, disable_notification)

	local url = self.BASE_URL .. '/sendAudio'

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

	return bindings.curlRequest(curl_command)

end

function bindings:sendVideo(chat_id, video, reply_to_message_id, duration, caption, disable_notification)

	local url = self.BASE_URL .. '/sendVideo'

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

	return bindings.curlRequest(curl_command)

end

function bindings:sendVoice(chat_id, voice, reply_to_message_id, duration, disable_notification)

	local url = self.BASE_URL .. '/sendVoice'

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

	return bindings.curlRequest(curl_command)

end

return bindings
