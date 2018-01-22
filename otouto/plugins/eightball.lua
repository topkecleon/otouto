--[[
    eightball.lua
    Returns magic 8-ball-like answers.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local eightball = {}

function eightball:init()
    eightball.command = '8ball'
    eightball.doc = 'Returns an answer from a magic 8-ball!'
    eightball.triggers = utilities.triggers(self.info.username, self.config.cmd_pat, {'[Yy]/[Nn]%p*$'}):t('8ball', true).table
    eightball.yesno = {
        'Yes.',
        'No.',
        'Absolutely.',
        'In your dreams.'
    }
    eightball.answers = {
        "It is certain.",
        "It is decidedly so.",
        "Without a doubt.",
        "Yes, definitely.",
        "You may rely on it.",
        "As I see it, yes.",
        "Most likely.",
        "Outlook: good.",
        "Yes.",
        "Signs point to yes.",
        "Reply hazy try again.",
        "Ask again later.",
        "Better not tell you now.",
        "Cannot predict now.",
        "Concentrate and ask again.",
        "Don't count on it.",
        "My reply is no.",
        "My sources say no.",
        "Outlook: not so good.",
        "Very doubtful."
    }
    if self.config.eightball then
        for _, answer in ipairs(self.config.eightball) do
            table.insert(eightball.answers, answer)
        end
    end
end

function eightball:action(msg)
    local output
    if msg.text_lower:match('y/n%p?$') then
        output = eightball.yesno[math.random(#eightball.yesno)]
    else
        output = eightball.answers[math.random(#eightball.answers)]
    end
    utilities.send_reply(msg, output)
end

return eightball
