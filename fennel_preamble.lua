package.path = './extern/?.lua;./extern/?/init.lua;' .. package.path
local fennel = require('fennel')
fennel.path = './extern/?.fnl;./extern/?/init.fnl;' .. fennel.path
table.insert(package.searchers, fennel.searcher)
