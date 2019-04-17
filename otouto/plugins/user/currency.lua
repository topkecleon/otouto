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
    self.url = "https://api.exchangeratesapi.io/latest"
    self.out_str = '%s %s = %s %s\nRate: %s\n%s\n<a href="https://exchangeratesapi.io/">Exchange Rates API</a>'
    self.unsupported_str = 'Unsupported currency: '
    self:later(bot)
end

function p:get_rate(from, to)
    if from == self.latest.base then
        return self.latest.rates[to]
    elseif to == self.latest.base then
        return 1 / self.latest.rates[from] 
    else
        return (1 / self.latest.rates[from]) * self.latest.rates[to]
    end
end

function p:action(bot, msg)
    local output
    local input = msg.text:upper()
    local from_cur, to_cur = input:match('(%a%a%a) TO (%a%a%a)')
    if from_cur and to_cur then
        local from_val = tonumber(
            input:match('([%d%.]+) ' .. from_cur .. ' TO ' .. to_cur)
        ) or 1
        if not (self.latest.rates[from_cur] or self.latest.base == from_cur) then
            output = self.unsupported_str .. from_cur
        elseif not (self.latest.rates[to_cur] or self.latest.base == to_cur) then
            output = self.unsupported_str .. to_cur
        else
            local rate = self:get_rate(from_cur, to_cur)
            local to_val = from_val * rate
            output = string.format(self.out_str,
                from_val,
                from_cur,
                string.format("%.2f", from_val * rate),
                to_cur,
                string.format("%.4f", rate),
                self.latest.date
            )
        end
    else
        output = self.doc
    end
    utilities.send_reply(msg, output, 'html')
end

 -- Update the rates every hour. The API updates every hour.
function p:later(bot)
    local response, code = https.request(self.url)
    if code == 200 then
        self.latest = json.decode(response)
    else
        error('Unable to connect to exchangeratesapi.io')
    end
    bot:do_later(self.name, os.time() + (60 * 60))
end

return p
