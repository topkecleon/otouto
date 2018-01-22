--[[
    commit.lua
    Returns a commit message from whatthecommit.com.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')
local http = require('socket.http')

local commit = {}

function commit:init()
    commit.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('commit').table
    commit.command = 'commit'
    commit.doc = 'Returns a commit message from whatthecommit.com.'
end

function commit:action(msg)
    local output = http.request('http://whatthecommit.com/index.txt') or 'Minor text fixes'
    bindings.sendMessage{
        chat_id = msg.chat.id,
        text = '```\n' .. output .. '\n```',
        parse_mode = 'Markdown'
    }
end

return commit
