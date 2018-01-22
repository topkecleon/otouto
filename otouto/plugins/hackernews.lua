--[[
    hackernews.lua
    Returns four or eight of the top posts from Hacker News.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

local hackernews = {}

local function get_hackernews_results(count)
    local results = {}
    local jstr, code = HTTPS.request(hackernews.topstories_url)
    if code ~= 200 then return end
    local data = JSON.decode(jstr)
    for i = 1, count do
        local ijstr, icode = HTTPS.request(hackernews.res_url:format(data[i]))
        if icode ~= 200 then return end
        local idata = JSON.decode(ijstr)
        local result
        if idata.url then
            result = string.format(
                '\n• <code>[</code><a href="%s">%s</a><code>]</code> <a href="%s">%s</a>',
                utilities.html_escape(hackernews.art_url:format(idata.id)),
                idata.id,
                utilities.html_escape(idata.url),
                utilities.html_escape(idata.title)
            )
        else
            result = string.format(
                '\n• <code>[</code><a href="%s">%s</a><code>]</code> %s',
                utilities.html_escape(hackernews.art_url:format(idata.id)),
                idata.id,
                utilities.html_escape(idata.title)
            )
        end
        table.insert(results, result)
    end
    return results
end

function hackernews:init()
    hackernews.command = 'hackernews'
    hackernews.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('hackernews', true):t('hn', true).table
    hackernews.doc = [[Returns four (if group) or eight (if private message) top stories from Hacker News.
Alias: ]] .. self.config.cmd_pat .. 'hn'
    hackernews.topstories_url = 'https://hacker-news.firebaseio.com/v0/topstories.json'
    hackernews.res_url = 'https://hacker-news.firebaseio.com/v0/item/%s.json'
    hackernews.art_url = 'https://news.ycombinator.com/item?id=%s'
    hackernews.last_update = 0
    if self.config.hackernews.on_start == true then
        hackernews.results = get_hackernews_results(self.config.hackernews.private_count)
        if hackernews.results then hackernews.last_update = os.time() / 60 end
    end
end

function hackernews:action(msg)
    local now = os.time() / 60
    if not hackernews.results or hackernews.last_update + self.config.hackernews.interval < now then
        bindings.sendChatAction{chat_id = msg.chat.id, action = 'typing'}
        hackernews.results = get_hackernews_results(self.config.hackernews.private_count)
        if not hackernews.results then
            utilities.send_reply(msg, self.config.errors.connection)
            return
        end
        hackernews.last_update = now
    end
    -- Four results in a group, eight in private.
    local res_count = msg.chat.id == msg.from.id and self.config.hackernews.private_count or self.config.hackernews.group_count
    local output = '<b>Top Stories from Hacker News:</b>'
    for i = 1, res_count do
        output = output .. hackernews.results[i]
    end
    utilities.send_message(msg.chat.id, output, true, nil, 'html')
end

return hackernews
