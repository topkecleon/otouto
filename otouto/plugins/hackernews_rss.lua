--[[
    hackernews-rss.lua
    RSS-using alternative to hackernews.lua. Should be much faster, but depends
    on feedparser, which depends on luaexpat, which depends on libexpat.

    To install on Ubuntu, run (as root):
        apt-get install libexpat1-dev
        luarocks install feedparser

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local https = require('ssl.https')
local feedparser = require('feedparser')

local hn = {}

function hn:init()
    assert(not self.named_plugins.hackernews)
    hn.feed_url = 'https://news.ycombinator.com/rss'
    hn.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('hackernews', true):t('hn', true).table
    hn.command = 'hackernews'
    hn.doc = [[Returns a list of top stories from Hacker News.
Alias: ]] .. self.config.cmd_pat .. 'hn'
end

function hn:action(msg)
    local res, code = https.request(hn.feed_url)
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end
    local parsed = feedparser.parse(res, hn.feed_url)
    local results = {}
    for i = 1, msg.chat.id == msg.from.id and self.config.hackernews.private_count or self.config.hackernews.group_count do
        local entry = parsed.entries[i]
        local url = entry.summary:match('"(.+)"')
        table.insert(results, string.format(
            '• <code>[</code><a href="%s">%s</a><code>]</code> <a href="%s">%s</a>',
            utilities.html_escape(url),
            url:match('%d+$'),
            -- We don't want the title to be linked if it's a "self" post.
            -- Pass an empty string for the URL if the link is the comment page.
            url == entry.link and '' or utilities.html_escape(entry.link),
            utilities.html_escape(entry.title)
        ))
    end
    local output = '<b>Top Posts from Hacker News:</b>\n' .. table.concat(results, '\n')
    utilities.send_message(msg.chat.id, output, true, nil, 'html')
end

return hn
