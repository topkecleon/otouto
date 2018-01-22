--[[
    about.lua
    Returns owner-configured information related to the bot and a link to the
    source code.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

local about = {}

about.command = 'about'
about.doc = 'Returns information about the bot.'

function about:init()
    about.text = self.config.about_text .. '\nBased on [otouto](http://github.com/topkecleon/otouto) v'..bot.version..' by topkecleon.'
    about.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('about'):t('start').table
end

function about:action(msg)
    utilities.send_message(msg.chat.id, about.text, true, nil, true)
end

return about
