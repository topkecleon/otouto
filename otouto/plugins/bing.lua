--[[
    bing.lua
    Return web search results from Bing.

    Credit to @JuanPotato for making this work.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local URL = require('socket.url')
local JSON = require('dkjson')
local mime = require('mime')
local https = require('ssl.https')
local ltn12 = require('ltn12')
local utilities = require('otouto.utilities')

local bing = {}

function bing:init()
    assert(
        self.config.bing_api_key,
        'bing.lua requires a Bing API key from http://datamarket.azure.com/dataset/bing/search.'
    )

    bing.headers = { ["Authorization"] = "Basic " .. mime.b64(":" .. self.config.bing_api_key) }
    bing.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('bing', true):t('g', true):t('google', true).table
    bing.doc = [[/bing <query>
Returns the top web results from Bing.
Aliases: /g, /google]]
    bing.doc = bing.doc:gsub('/', self.config.cmd_pat)
    bing.command = 'bing <query>'
    bing.search_url = 'https://api.datamarket.azure.com/Data.ashx/Bing/Search/Web?Query=\'language:' .. self.config.lang .. '%s\'&$format=json'
end

function bing:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, bing.doc, 'html')
        return
    end

    local url = bing.search_url:format('%20' .. URL.escape(input))
    local resbody = {}
    local _, code = https.request{
        url = url,
        headers = bing.headers,
        sink = ltn12.sink.table(resbody),
    }
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = JSON.decode(table.concat(resbody))
    -- Four results in a group, eight in private.
    local limit = msg.chat.type == 'private' and 8 or 4
    -- No more results than provided.
    limit = limit > #data.d.results and #data.d.results or limit
    if limit == 0 then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local reslist = {}
    for i = 1, limit do
        table.insert(reslist, string.format(
            '• <a href="%s">%s</a>',
            utilities.html_escape(data.d.results[i].Url),
            utilities.html_escape(data.d.results[i].Title)
        ))
    end
    local output = string.format(
        '<b>Search results for</b> <i>%s</i><b>:</b>\n%s',
        utilities.html_escape(input),
        table.concat(reslist, '\n')
    )
    utilities.send_message(msg.chat.id, output, true, nil, 'html')
end

return bing
