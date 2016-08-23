 -- Based on a plugin by matthewhesketh.

local JSON = require('dkjson')
local HTTP = require('socket.http')
local utilities = require('otouto.utilities')

local catfact = {}

function catfact:init(config)
    catfact.triggers = utilities.triggers(self.info.username, config.cmd_pat)
        :t('catfact', true).table
    catfact.command = 'catfact'
    catfact.doc = 'Returns a cat fact.'
    catfact.url = 'http://catfacts-api.appspot.com/api/facts'
end

function catfact:action(msg, config)
    local jstr, code = HTTP.request(catfact.url)
    if code ~= 200 then
        utilities.send_reply(msg, config.errors.connection)
        return
    end
    local data = JSON.decode(jstr)
    local output = '*Cat Fact*\n_' .. data.facts[1] .. '_'
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return catfact
