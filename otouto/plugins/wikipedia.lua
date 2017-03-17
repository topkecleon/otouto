--[[
    wikipedia.lua
    Returns a Wikipedia result for a given query.

    Uses config.lang for article language.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local wikipedia = {}

function wikipedia:init()
    wikipedia.command = 'wikipedia <query>'
    wikipedia.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('wikipedia', true):t('wiki', true):t('w', true).table
    wikipedia.doc = self.config.cmd_pat .. [[wikipedia <query>
Returns an article from Wikipedia.
Aliases: ]] .. self.config.cmd_pat .. 'w, ' .. self.config.cmd_pat .. 'wiki'
    wikipedia.search_url = 'https://' .. self.config.lang .. '.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch='
    wikipedia.res_url = 'https://' .. self.config.lang .. '.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exchars=4000&explaintext=&titles='
    wikipedia.art_url = 'https://' .. self.config.lang .. '.wikipedia.org/wiki/'
end

function wikipedia:action(msg)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, wikipedia.doc, 'html')
        return
    end

    local jstr, code = HTTPS.request(wikipedia.search_url .. URL.escape(input))
    if code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    if not data.query or data.query.searchinfo.totalhits == 0 then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local title
    for _, v in ipairs(data.query.search) do
        if not v.snippet:match('may refer to:') then
            title = v.title
            break
        end
    end
    if not title then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local res_jstr, res_code = HTTPS.request(wikipedia.res_url .. URL.escape(title))
    if res_code ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local _, text = next(JSON.decode(res_jstr).query.pages)
    if not text then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    text = text.extract
    local l = text:find('\n')
    if l then
        text = text:sub(1, l-1)
    end
    local url = wikipedia.art_url .. URL.escape(title)
    title = utilities.html_escape(title)
    -- If the beginning of the article is the title, embolden that.
    -- Otherwise, we'll add a title in bold.
    local short_title = title:gsub('%(.+%)', '')
    local combined_text, count = text:gsub('^'..short_title, '<b>'..short_title..'</b>')
    local body
    if count == 1 then
        body = combined_text
    else
        body = '<b>' .. title .. '</b>\n' .. text
    end
    local output = string.format(
        '%s\n<a href="%s">Read more.</a>',
        body,
        utilities.html_escape(url)
    )
    utilities.send_message(msg.chat.id, output, true, nil, 'html')
end

return wikipedia
