local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('unhammer', true).table
    self.command = 'unhammer'
    self.privilege = 4
    self.targeting = true
end

function P:action(bot, msg, _group)
    local targets = autils.targets(bot, msg)
    local output = {}

    if targets then
        for _, id in ipairs(targets) do
            if tonumber(id) then
                local name = utilities.format_name(bot, id)
                local id_str = tostring(id)
                if bot.database.administration.hammers[id_str] then
                    bot.database.administration.hammers[id_str] = nil
                    table.insert(output, name..' is no longer globally banned.')
                else
                    table.insert(output, name .. ' is not globally banned.')
                end
            else
                table.insert(output, id)
            end
        end
    else
        table.insert(output, bot.config.errors.specify_targets)
    end

    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
