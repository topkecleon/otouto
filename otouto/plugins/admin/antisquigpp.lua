local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    local flag = 'antisquigpp'
    self.flag = flag
    flags_plugin.flags[flag] =
        'Arabic script is not allowed in names.'
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, group, user)
    if not group.flags[self.flag] then return true end
    if user.rank > 1 then return true end
    if user.name:match(utilities.char.arabic) or
        user.name:match(utilities.char.rtl_override) or
        user.name:match(utilities.char.rtl_mark)
    then
        autils.strike(bot, msg, self.flag)
    else
        return true
    end
end

return P
