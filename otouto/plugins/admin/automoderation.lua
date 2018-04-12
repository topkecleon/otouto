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
end

function P:cron(bot, _now)
    if bot.database.administration.automod_timer ~= os.date('%d') then
        bot.database.groupdata.automoderation = {}
        bot.database.administration.automod_timer = os.date('%d')
    end
end

return P
