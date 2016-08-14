 -- Based on a plugin by matthewhesketh.

local JSON = require('dkjson')
local HTTP = require('socket.http')
local utilities = require('otouto.utilities')

local chuck = {}

function chuck:init(config)
    chuck.triggers = utilities.triggers(self.info.username, config.cmd_pat)
        :t('chuck', true):t('cn', true):t('chucknorris', true).table
    chuck.command = 'chuck'
    chuck.doc = 'Returns a fact about Chuck Norris.'
    chuck.url = 'http://api.icndb.com/jokes/random'
end

function chuck:action(msg, config)
    local jstr, code = HTTP.request(chuck.url)
    if code ~= 200 then
        utilities.send_reply(self, msg, config.errors.connection)
        return
    end
    local data = JSON.decode(jstr)
    local output = '*Chuck Norris Fact*\n_' .. data.value.joke .. '_'
    utilities.send_message(self, msg.chat.id, output, true, nil, true)
end

return chuck
