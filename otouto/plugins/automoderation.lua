--[[
    This module will count "strikes", issue warnings, delete messages, kick,
    and ban on behalf of all automoderation policies (antisquig, antiflood, etc)

    Strike 1: message deleted
    Strike 2: ^& kicked
    Strike 3: ^& banned
]]

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.administration')

local automod = {}

function automod:init()
    self.database.administration.automoderation =
        self.database.administration.automoderation or {}
    self.database.administration.automod_timer =
        self.database.administration.automod_timer or os.date('%d')
end

function automod:cron()
    if self.database.administration.automod_timer ~= os.date('%d') then
        self.database.administration.automoderation = {}
        self.database.administration.automod_timer = os.date('%d')
    end
end

return automod
