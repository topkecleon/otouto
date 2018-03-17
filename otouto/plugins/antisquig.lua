local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local P = {}

function P:init()
    assert(self.named_plugins.flags, P.name .. ' requires flags')
    self.named_plugins.flags.flags[P.name] =
        'Arabic script is not allowed in messages.'
    P.triggers = {
        utilities.char.arabic,
        utilities.char.rtl_override,
        utilities.char.rtl_mark
    }
    P.internal = true
end

function P:action(msg, group, user)
    if not group.flags.antisquig then return true end
    if user.rank > 1 then return true end
    if msg.forward_from and (
        msg.forward_from.id == self.info.id or
        msg.forward_from.id == self.config.log_chat or
        msg.forward_from.id == self.config.administration.log_chat
    ) then
        return true
    end

    autils.strike(self, msg, P.name)
end

P.edit_action = P.action

return P
