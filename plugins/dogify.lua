local command = 'dogify <text>[/text]'
local doc = [[```
/dogify <such text/wow>
Wow, much return: such text, wow.
```]]

local triggers = {
        '^/dogify[@'..bot.username..']*'
}

local action = function(msg)
        local base_url = 'http://dogr.io/'
        local input = msg.text:input()
        local urlm = 'https?://[%%%w-_%.%?%.:/%+=&]+'
        if not input then
                output = doc
        else
                input = input:gsub(' ', '%%20')
                url = base_url..input..'.png?split=false&.png'
                if string.match(url, urlm) == url then
                        output = '[WOW!]('..url..')'
                else
                        output = config.errors.argument 
                end
        end
        sendMessage(msg.chat.id, output, false, nil, true)
end

return {
        action = action,
        triggers = triggers,
        doc = doc,
        command = command
}
