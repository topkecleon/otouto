local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    self.named_plugins.flags.flags[P.name] =
        'Arabic script is not allowed in names.'
    P.triggers = {''}
    P.internal = true
end

function P:action(msg, group, user)
    if not group.flags.antisquigpp then return true end
    if user.rank > 1 then return true end
    if user.name:match(utilities.char.arabic) or
        user.name:match(utilities.char.rtl_override) or
        user.name:match(utilities.char.rtl_mark)
    then
        autils.strike(self, msg, P.name)
    else
        return true
    end
end

return P
