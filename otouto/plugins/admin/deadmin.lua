local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('deadmin', true).table
    P.privilege = 5
    P.command = 'deadmin'
    P.doc = 'Demotes an administrator or administrators.'
    P.targeting = true
end

function P:action(msg, _group, _user)
    local targets = autils.targets(self, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                if self.database.administration.administrators[tostring(id)]
                then
                    self.database.administration.administrators[tostring(id)] =
                        nil
                    for chat_id in pairs(self.database.administration.groups) do
                        if autils.rank(self, id, chat_id) < 2 then
                            autils.demote_admin(chat_id, id)
                        end
                    end
                    table.insert(output, utilities.format_name(self, id) ..
                        ' is no longer an administrator.')
                else
                    table.insert(output, utilities.format_name(self, id) ..
                        ' is not an administrator.')
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, self.config.errors.specify_targets)
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
