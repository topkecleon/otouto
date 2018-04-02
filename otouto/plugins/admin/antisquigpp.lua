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
    if not group.data.admin.flags[self.flag] then return 'continue' end
    if user:rank(bot) > 1 then return 'continue' end
    local name = utilities.build_name(user.info.first_name, user.info.last_name)
    if name:match(utilities.char.arabic) or
        name:match(utilities.char.rtl_override) or
        name:match(utilities.char.rtl_mark)
    then
        autils.strike(bot, msg, self.flag)
    else
        return 'continue'
    end
end

return P
