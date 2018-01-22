--[[
    luarun.lua
    Allows the bot owner to run arbitrary Lua code inside the bot instance.
    "/return" is alias for "/lua return".

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')
local URL = require('socket.url')
local serpent = require('serpent')

local luarun = {}

function luarun:init()
    luarun.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('lua', true):t('return', true).table
    -- Lua 5.2 compatibility.
    luarun.err_msg = function(x)
        return 'Error:\n' .. tostring(x)
    end
end

function luarun:action(msg)

    if msg.from.id ~= self.config.admin then
        return true
    end

    local input = utilities.input(msg.text)
    if not input then
        utilities.send_reply(msg, 'Please enter a string to load.')
        return
    end

    if msg.text_lower:match('^'..self.config.cmd_pat..'return') then
        input = 'return ' .. input
    end

    local output, success = (load or loadstring)(
        "local bot = require('otouto.bot')\n\z
        local bindings = require('otouto.bindings')\n\z
        local utilities = require('otouto.utilities')\n\z
        local drua = require('otouto.drua-tg')\n\z
        local json = require('dkjson')\n\z
        local url = require('socket.url')\n\z
        local http = require('socket.http')\n\z
        local https = require('ssl.https')\n\z
        local serpent = require('serpent')\n\z
        return function (self, msg)\n" .. input .. "\nend"
    )

    if output == nil then
        output = success
    else
        success, output = xpcall(output(), luarun.err_msg, self, msg)
    end

    if output == nil then
        output = 'Done!'
    else
        if type(output) == 'table' then
            local s = serpent.block(output, {comment=false})
            if URL.escape(s):len() < 4000 then
                output = s
            end
        end
        output = '<code>' .. utilities.html_escape(tostring(output)) .. '</code>'
    end
    utilities.send_message(msg.chat.id, output, true, msg.message_id, 'html')

end

return luarun
