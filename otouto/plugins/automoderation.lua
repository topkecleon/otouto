--[[
    This module will count "strikes", issue warnings, delete messages, kick,
    and ban on behalf of all automoderation policies (antisquig, antiflood, etc)

    Strike 1: message deleted
    Strike 2: ^& kicked
    Strike 3: ^& banned
]]

local bindings = require('otouto.bindings')

local automod = {}

function automod:init()
    self.database.administration.automoderation =
        self.database.administration.automoderation or {}
    self.database.administration.automod_timer =
        self.database.administration.automod_timer or os.date('%d')

    -- Store the IDs of warning messages to delete them after five minutes.
    automod.store = {}
end

function automod:cron()
    if self.database.administration.automod_timer ~= os.date('%d') then
        self.database.administration.automoderation = {}
        self.database.administration.automod_timer = os.date('%d')
    end

    -- Delete old first-strike warnings after five minutes.
    if #automod.store > 0 then
        local new_store = {}
        local time = os.time() - self.config.administration.warning_expiration
        for _, m in ipairs(automod.store) do
            if time > m.date then
                bindings.deleteMessage{
                    message_id = m.message_id,
                    chat_id = m.chat_id
                }
            else
                table.insert(new_store, m)
            end
        end
        automod.store = new_store
    end
end

return automod
