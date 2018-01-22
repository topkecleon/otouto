--[[
    reddit.lua
    Returns the top posts for a given subreddit or query or r/all.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')
local HTTPS = require('ssl.https')

local reddit = {}

function reddit:init()
    reddit.command = 'reddit [r/subreddit | query]'
    reddit.triggers = utilities.triggers(self.info.username, self.config.cmd_pat, {'^/r/'}):t('reddit', true):t('r', true):t('r/', true).table
    reddit.doc = self.config.cmd_pat .. [[reddit [r/subreddit | query]
Returns the top posts or results for a given subreddit or query. If no argument is given, returns the top posts from r/all. Querying specific subreddits is not supported.
Aliases: ]] .. self.config.cmd_pat .. 'r, /r/subreddit'
    reddit.subreddit_url = 'http://www.reddit.com/%s/.json?limit='
    reddit.search_url = 'http://www.reddit.com/search.json?q=%s&limit='
    reddit.rall_url = 'http://www.reddit.com/.json?limit='
end

local function format_results(posts)
    local output = ''
    for _,v in ipairs(posts) do
        local post = v.data
        local title = post.title:gsub('%[', '('):gsub('%]', ')'):gsub('&amp;', '&')
        if title:len() > 256 then
            title = title:sub(1, 253)
            title = utilities.trim(title) .. '...'
        end
        local short_url = 'redd.it/' .. post.id
        local s = '[' .. title .. '](' .. short_url .. ')'
        if post.domain and not post.is_self and not post.over_18 then
            s = '`[`[' .. post.domain .. '](' .. post.url:gsub('%)', '\\)') .. ')`]` ' .. s
        end
        output = output .. '• ' .. s .. '\n'
    end
    return output
end

function reddit:action(msg)
    -- Eight results in PM, four results elsewhere.
    local limit = msg.chat.type == 'private' and 8 or 4
    local text = msg.text_lower
    if text:match('^/r/.') then
        -- Normalize input so this hack works easily.
        text = msg.text_lower:gsub('^/r/', self.config.cmd_pat..'r r/')
    end
    local input = utilities.input(text)
    local source, url
    if input then
        if input:match('^r/.') then
            input = utilities.get_word(input, 1)
            url = reddit.subreddit_url:format(input) .. limit
            source = '*/' .. utilities.md_escape(input) .. '*\n'
        else
            input = utilities.input(msg.text)
            source = '*Results for* _' .. utilities.md_escape(input) .. '_ *:*\n'
            input = URL.escape(input)
            url = reddit.search_url:format(input) .. limit
        end
    else
        url = reddit.rall_url .. limit
        source = '*/r/all*\n'
    end
    local jstr, res = HTTPS.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
    else
        local jdat = JSON.decode(jstr)
        if #jdat.data.children == 0 then
            utilities.send_reply(msg, self.config.errors.results)
        else
            local output = format_results(jdat.data.children)
            output = source .. output
            utilities.send_message(msg.chat.id, output, true, nil, true)
        end
    end
end

return reddit
