dofile('fennel_preamble.lua')
-- Fennel loaded

local bot = require('otouto.bot')

local instance = setmetatable({
    config = require('config')
}, {__index = bot})

return instance:run()
