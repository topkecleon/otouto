if package.path:find('%./%?%.lua') and not package.path:find('%./%?/init%.lua') then
    package.path = package.path .. ';./?/init.lua'
end
dofile('fennel_preamble.lua')
-- Fennel loaded

local bot = require('otouto.bot')

local instance = setmetatable({
    config = require('config')
}, {__index = bot})

return instance:run()
