local commit = {}

local utilities = require('otouto.utilities')
local bindings = require('otouto.bindings')
local http = require('socket.http')

commit.command = 'commit'
commit.doc = 'Returns a commit message from whatthecommit.com.'

function commit:init(config)
    commit.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('commit').table
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
