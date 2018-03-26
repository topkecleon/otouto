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
    bot.database.administration.automoderation =
        bot.database.administration.automoderation or {}
    bot.database.administration.automod_timer =
        bot.database.administration.automod_timer or os.date('%d')

    -- Store the IDs of warning messages to delete them after five minutes.
    self.store = {}

    self.help_word = 'automoderation'
    self.doc = "\z
The automoderation system provides a unified three-strike system in each \z
group. When a first strike is issued, the offending message is deleted and a \z
warning is posted. The warning is deleted after " ..
bot.config.administration.warning_expiration .. " seconds. When the second \z
strike is issued, the offending message is again deleted and the user is \z
banned for five minutes. On the third strike, the message is deleted and the \z
user is banned. \
A user's local strikes can be reset with /unrestrict. Available \z
automoderation policies can be viewed with /flags (see /help flags)."
end

function P:cron(bot, _now)
    if bot.database.administration.automod_timer ~= os.date('%d') then
        bot.database.administration.automoderation = {}
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
