local https = require('ssl.https')
local json = require('dkjson')

local utilities = require('otouto.utilities')

local p = {}

function p:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('cash', true):t('currency', true).table
    self.command = 'cash [amount] <currency> to <currency>'
    self.doc = 'Example: ' .. bot.config.cmd_pat .. [[cash 5 BTC to USD
Returns currency exchange rates and calculations.
Source: <a href="https://exchangeratesapi.io/">Exchange Rates API</a>
Alias: ]] .. bot.config.cmd_pat .. 'currency'
    self.base_url = "https://api.exchangeratesapi.io/latest?symbols=%s&base=%s"
end

function p:action(bot, msg)
    local output
    local input = msg.text:upper()
    local from_cur, to_cur = input:match('(%a%a%a) TO (%a%a%a)')
    if from_cur and to_cur then
        local from_val = tonumber(
            input:match('([%d%.]+) ' .. from_cur .. ' TO ' .. to_cur)
        ) or 1

        local response, code = https.request(self.base_url:format(to_cur, from_cur))
        if code == 200 then
            data = json.decode(response)
            output = string.format(
                '%s %s = %s %s\nRate: %s\nDate: %s\nSource: <a href="https://exchangeratesapi.io/">Exchange Rates API</a>',
                from_val,
                from_cur:upper(),
                string.format("%.2f", from_val * data.rates[to_cur:upper()]),
                to_cur:upper(),
                data.rates[to_cur:upper()],
                data.date
            )
        elseif response then
            output = json.decode(response).error
        else
            output = bot.config.errors.connection
        end
    else
        output = self.doc
    end
    utilities.send_reply(msg, output, 'html')
end

return p
