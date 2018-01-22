--[[
    rmspic.lua
    Returns a photo of Dr. Richard Matthew Stallman.

    Pictures from rms.sexy.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local https = require('ssl.https')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local rms = {}

function rms:init()
    rms.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('rms').table
    rms.command = 'rms'
    rms.BASE_URL = 'https://rms.sexy/img/'
    rms.LIST = {}
    local s, r = https.request(rms.BASE_URL)
    if r ~= 200 then
        print('Error connecting to rms.sexy.\nrmspic.lua will not be enabled.')
        rms.triggers = {}
    end
    for link in s:gmatch('<a href=".-%.%a%a%a">(.-)</a>') do
        table.insert(rms.LIST, rms.BASE_URL .. link)
    end
end

function rms:action(msg)
    bindings.sendPhoto{chat_id = msg.chat.id, photo = rms.LIST[math.random(#rms.LIST)]}
end

return rms
