local urbandictionary = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

urbandictionary.command = 'urbandictionary <query>'
urbandictionary.base_url = 'http://api.urbandictionary.com/v0/define?term='

function urbandictionary:init(config)
    urbandictionary.triggers = utilities.triggers(self.info.username, config.cmd_pat)
        :t('urbandictionary', true):t('ud', true):t('urban', true).table
    urbandictionary.doc = [[
/urbandictionary <query>
Returns a definition from Urban Dictionary.
Aliases: /ud, /urban
    ]]
    urbandictionary.doc = urbandictionary.doc:gsub('/', config.cmd_pat)
end

function urbandictionary:action(msg, config)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(self, msg, urbandictionary.doc, true)
        return
    end

    local url = urbandictionary.base_url .. URL.escape(input)
    local jstr, code = HTTP.request(url)
    if code ~= 200 then
        utilities.send_reply(self, msg, config.errors.connection)
        return
    end

    local data = JSON.decode(jstr)
    local output
    if data.result_type == 'no_results' then
        output = config.errors.results
    else
        output = string.format('*%s*\n\n%s\n\n_%s_',
            data.list[1].word:gsub('*', '*\\**'),
            utilities.trim(utilities.md_escape(data.list[1].definition)),
            utilities.trim((data.list[1].example or '')):gsub('_', '_\\__')
        )
    end
    utilities.send_reply(self, msg, output, true)
end

return urbandictionary
