local luarun = {}

local utilities = require('otouto.utilities')
local URL = require('socket.url')
local JSON, serpent

function luarun:init(config)
    luarun.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('lua', true):t('return', true).table
    if config.luarun_serpent then
        serpent = require('serpent')
        luarun.serialize = function(t)
            return serpent.block(t, {comment=false})
        end
    else
        JSON = require('dkjson')
        luarun.serialize = function(t)
            return JSON.encode(t, {indent=true})
        end
    end
end

function luarun:action(msg, config)

    if msg.from.id ~= config.admin then
        return true
    end

    local input = utilities.input(msg.text)
    if not input then
        utilities.send_reply(msg, 'Please enter a string to load.')
        return
    end

    if msg.text_lower:match('^'..config.cmd_pat..'return') then
        input = 'return ' .. input
    end

    local output, success =
        load("local bot = require('otouto.bot')\n\z
        local bindings = require('otouto.bindings')\n\z
        local utilities = require('otouto.utilities')\n\z
        local drua = require('otouto.drua-tg')\n\z
        local JSON = require('dkjson')\n\z
        local URL = require('socket.url')\n\z
        local HTTP = require('socket.http')\n\z
        local HTTPS = require('ssl.https')\n\z
        return function (self, msg, config)\n" .. input .. "\nend")

    local function err_msg(x)
        return "Error:\n" .. tostring(x)
    end

    if output == nil then
        output = success
    else
        success, output = xpcall(output(), err_msg, self, msg, config)
    end

    if output == nil then
        output = 'Done!'
    else
        if type(output) == 'table' then
            local s = luarun.serialize(output)
            if URL.escape(s):len() < 4000 then
                output = s
            end
        end
        output = '<code>' .. utilities.html_escape(tostring(output)) .. '</code>'
    end
    utilities.send_message(msg.chat.id, output, true, msg.message_id, 'html')

end

return luarun

