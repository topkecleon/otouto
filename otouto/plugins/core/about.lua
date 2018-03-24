--[[
    about.lua
    Returns owner-configured information related to the bot and a link to the
    source code.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    self.command = 'about'
    self.doc = 'Returns information about the bot.'
    self.text = bot.config.about_text ..
        '\nBased on [otouto](http://github.com/topkecleon/otouto) v'..bot.version..' by topkecleon.'
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('about'):t('start').table
end

function P:action(_bot, msg)
    utilities.send_message(msg.chat.id, self.text, true, nil, true)
end

return P
