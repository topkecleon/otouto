local utilities = require('otouto.utilities')
local bot = require('otouto.bot')

local wait = {}

function wait:init(config)
    self.database.wait = self.database.wait or {}
    wait.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('wait', true).table
    wait.command = '/wait <duration> <command> [args]'
    wait.doc = config.cmd_pat .. [[wait <duration> <command> [args]
Postpone a command for a given duration, in minutes.
Max duration is 10000.]]
end

 -- ex: /wait 15 /calc 5 * 10
function wait:action(msg, config)
    local duration = utilities.get_word(msg.text, 2)
    duration = tonumber(duration)
    local input = msg.text
    repeat
        input = input:gsub('^' .. config.cmd_pat .. '[Ww][Aa][Ii][Tt] %g+ ', '')
    until not input:match('^' .. config.cmd_pat .. '[Ww][Aa][Ii][Tt] %g+ ')
    if not input or not duration or duration > 10000 then
        utilities.send_reply(msg, wait.doc, 'html')
        return
    end
    msg.date = msg.date + ( duration * 60 )
    msg.text = input
    table.insert(self.database.wait, msg)
    utilities.send_reply(msg, 'Queued.')
end

function wait:cron(config)
    local now = os.time() + 1
    for k, msg in pairs(self.database.wait) do
        if msg.date < now then
            msg.date = os.time()
            bot.on_msg_receive(self, msg, config)
            self.database.wait[k] = nil
        end
    end
end

return wait
