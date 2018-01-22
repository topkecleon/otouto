--[[
    end_forwards.lua
    This plugin keeps forwarded messages from hitting any plugin after it in the
    load order. Just put this wherever, close to the top. The only plugin which
    needs to see forwarded messages is administration.lua.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

return {
    name = 'end_forwards',
    triggers = { '' },
    action = function(_, msg)
        if not msg.forward_from then return true end
    end
}
