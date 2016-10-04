local dilbert = {}

local HTTP = require('socket.http')
local URL = require('socket.url')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

dilbert.command = 'dilbert [date]'

function dilbert:init(config)
    dilbert.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('dilbert', true).table
    dilbert.doc = config.cmd_pat .. [[dilbert [YYYY-MM-DD]
Returns the latest Dilbert strip or that of the provided date.
Dates before the first strip will return the first strip. Dates after the last trip will return the last strip.
Source: dilbert.com]]
end

function dilbert:action(msg, config)

    bindings.sendChatAction{ chat_id = msg.chat.id, action = 'upload_photo' }

    local input = utilities.input(msg.text)
    if not input then input = os.date('%F') end
    if not input:match('^%d%d%d%d%-%d%d%-%d%d$') then input = os.date('%F') end

    local url = 'http://dilbert.com/strip/' .. URL.escape(input)
    local str, res = HTTP.request(url)
    if res ~= 200 then
        utilities.send_reply(msg, config.errors.connection)
        return
    end

    local strip_title = str:match('<meta property="article:publish_date" content="(.-)"/>')

    local strip_url = str:match('<meta property="og:image" content="(.-)"/>')
    bindings.sendPhoto{chat_id = msg.chat.id, photo = strip_url, caption = strip_title}

end

return dilbert
