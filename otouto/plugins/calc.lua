local calc = {}

local URL = require('socket.url')
local HTTPS = require('ssl.https')
local utilities = require('otouto.utilities')

calc.command = 'calc <expression>'

function calc:init(config)
    calc.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('calc', true).table
    calc.doc = config.cmd_pat .. [[calc <expression>
Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.]]
end

function calc:action(msg, config)
    local input = utilities.input_from_msg(msg)
    if not input then
        utilities.send_reply(self, msg, calc.doc, true)
        return
    end

    local url = 'https://api.mathjs.org/v1/?expr=' .. URL.escape(input)
    local output = HTTPS.request(url)
    output = output and '`'..output..'`' or config.errors.connection
    utilities.send_reply(self, msg, output, true)
end

return calc
