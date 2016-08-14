local imdb = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

imdb.command = 'imdb <query>'

function imdb:init(config)
    imdb.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('imdb', true).table
    imdb.doc = config.cmd_pat .. 'imdb <query> \nReturns an IMDb entry.'
end

function imdb:action(msg, config)

    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(self, msg, imdb.doc, true)
        return
    end

    local url = 'http://www.omdbapi.com/?t=' .. URL.escape(input)

    local jstr, res = HTTP.request(url)
    if res ~= 200 then
        utilities.send_reply(self, msg, config.errors.connection)
        return
    end

    local jdat = JSON.decode(jstr)

    if jdat.Response ~= 'True' then
        utilities.send_reply(self, msg, config.errors.results)
        return
    end

    local output = '*' .. jdat.Title .. ' ('.. jdat.Year ..')*\n'
    output = output .. jdat.imdbRating ..'/10 | '.. jdat.Runtime ..' | '.. jdat.Genre ..'\n'
    output = output .. '_' .. jdat.Plot .. '_\n'
    output = output .. '[Read more.](http://imdb.com/title/' .. jdat.imdbID .. ')'

    utilities.send_message(self, msg.chat.id, output, true, nil, true)

end

return imdb
