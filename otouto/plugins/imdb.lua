--[[
    imdb.lua
    Returns the IMDb entry for a given query.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

local imdb = {}

function imdb:init()
    imdb.command = 'imdb <query>'
    imdb.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('imdb', true).table
    imdb.doc = self.config.cmd_pat .. 'imdb <query> \nReturns an IMDb entry.'
end

function imdb:action(msg)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(msg, imdb.doc, 'html')
        return
    end

    local url = 'http://www.omdbapi.com/?t=' .. URL.escape(input)

    local jstr, res = HTTP.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, self.config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)

    if jdat.Response ~= 'True' then
        utilities.send_reply(msg, self.config.errors.results)
        return
    end

    local output = '*' .. jdat.Title .. ' ('.. jdat.Year ..')*\n'
    output = output .. jdat.imdbRating ..'/10 | '.. jdat.Runtime ..' | '.. jdat.Genre ..'\n'
    output = output .. '_' .. jdat.Plot .. '_\n'
    output = output .. '[Read more.](http://imdb.com/title/' .. jdat.imdbID .. ')'

    utilities.send_message(msg.chat.id, output, true, nil, true)

end

return imdb
