local https = require('ssl.https')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local rms = {}

function rms:init(config)
	rms.BASE_URL = 'https://rms.sexy/img/'
	rms.LIST = {}
	local s, r = https.request(rms.BASE_URL)
	if r ~= 200 then
		print('Error connecting to rms.sexy.\nrmspic.lua will not be enabled.')
		return
	end
	for link in s:gmatch('<a href=".-%.%a%a%a">(.-)</a>') do
		table.insert(rms.LIST, link)
	end
	rms.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('rms').table
end

function rms:action(msg, config)
	bindings.sendChatAction(self, { chat_id = msg.chat.id, action = 'upload_photo' })
	local choice = rms.LIST[math.random(#rms.LIST)]
	local filename = '/tmp/' .. choice
	local image_file = io.open(filename)
	if image_file then
		image_file:close()
	else
		utilities.download_file(rms.BASE_URL .. choice, filename)
	end
	bindings.sendPhoto(self, { chat_id = msg.chat.id }, { photo = filename })
end

return rms
