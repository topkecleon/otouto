local cats = {}

local HTTP = require('socket.http')
local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')

function cats:init(config)
    if not config.thecatapi_key then
        print('Missing config value: thecatapi_key.')
        print('cats.lua will be enabled, but there are more features with a key.')
    end

    cats.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('cat').table
end

cats.command = 'cat'
cats.doc = 'Returns a cat!'

function cats:action(msg, config)

    local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg'
    if config.thecatapi_key then
        url = url .. '&api_key=' .. config.thecatapi_key
    end

    local str, res = HTTP.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, config.errors.connection)
        return
    end

    str = str:match('<img src="(.-)">')
    bindings.sendPhoto{chat_id = msg.chat.id, photo = str}

end

return cats
