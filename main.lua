package.path = './extern/?.lua;./extern/?/init.lua;' .. package.path
local fennel = require('fennel')
fennel.path = './extern/?.fnl;' .. fennel.path
table.insert(package.searchers, fennel.searcher)
-- Fennel loaded

local bot = require('otouto.bot')

local instance = setmetatable({
    config = require('config')
}, {__index = bot})

return instance:run()
