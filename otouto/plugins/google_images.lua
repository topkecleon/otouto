--[[
    google_images.lua
    Returns results from Google Images.

    You need a Google API key and a Google Custom Search Engine set up to use
    this, in config.google_api_key and config.google_cse_key, respectively. You
    must also sign up for the CSE in the Google Developer Console, and enable
    image results.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local gImages = {}

function gImages:init()
    assert(
        self.config.google_api_key and self.config.google_cse_key,
        'gImages.lua requires a Google API key from http://console.developers.google.com and a Google Custom Search Engine key from http://cse.google.com/cse.'
    )

    gImages.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('image', true):t('i', true):t('insfw', true).table
    gImages.doc = self.config.cmd_pat .. [[image <query>
Returns a randomized top result from Google Images. Safe search is enabled by default; use "]] .. self.config.cmd_pat .. [[insfw" to disable it. NSFW results will not display an image preview.
Alias: ]] .. self.config.cmd_pat .. 'i'
    gImages.search_url = 'https://www.googleapis.com/customsearch/v1?&searchType=image&imgSize=xlarge&alt=json&num=8&start=1&key=' .. self.config.google_api_key .. '&cx=' .. self.config.google_cse_key
    -- Put this up here in case config changes after triggers are generated.
    gImages.nsfw_trigger = '^' .. self.config.cmd_pat .. 'insfw'
end

gImages.command = 'image <query>'

function gImages:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, gImages.doc, 'html')
        return
    end

    local url = gImages.search_url

    if not string.match(msg.text, '^'..self.config.cmd_pat..'i[mage]*nsfw') then
        url = url .. '&safe=high'
    end

    url = url .. '&q=' .. URL.escape(input)

    local jstr, res = HTTPS.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)
    if jdat.searchInformation.totalResults == '0' then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local i = math.random(jdat.queries.request[1].count)
    local img_url = jdat.items[i].link
    local img_title = jdat.items[i].title

    if msg.text_lower:match(gImages.nsfw_trigger) then
        local output = '[' .. img_title .. '](' .. img_url .. ')'
        utilities.send_message(msg.chat.id, '*NSFW*\n'..output, true, msg.message_id, true)
    else
        bindings.sendPhoto{chat_id = msg.chat.id, photo = img_url, caption = img_title}
    end

end

return gImages
