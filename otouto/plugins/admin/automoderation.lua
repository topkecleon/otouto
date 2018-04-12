--[[
    This module will count "strikes", issue warnings, delete messages, kick,
    and ban on behalf of all automoderation policies (antisquig, antiflood, etc)

    Strike 1: message deleted
    Strike 2: ^& kicked
    Strike 3: ^& banned
]]

local bindings = require('otouto.bindings')

local P = {}

function P:init(bot)
    bot.database.groupdata.automoderation =
        bot.database.groupdata.automoderation or {}
    bot.database.administration.automod_timer =
        bot.database.administration.automod_timer or os.date('%d')

    -- Store the IDs of warning messages to delete them after five minutes.
    self.store = {}
end

function P:cron(bot, _now)
    if bot.database.administration.automod_timer ~= os.date('%d') then
        bot.database.groupdata.automoderation = {}
        bot.database.administration.automod_timer = os.date('%d')
    end

    -- Delete old first-strike warnings after five minutes.
    if #self.store > 0 then
        local new_store = {}
        local time = os.time() - bot.config.administration.warning_expiration
        for _, m in ipairs(self.store) do
            if time > m.date then
                bindings.deleteMessage{
                    message_id = m.message_id,
                    chat_id = m.chat_id
                }
            else
                table.insert(new_store, m)
            end
        end
        self.store = new_store
    end
end

return P
