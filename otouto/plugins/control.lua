--[[
    control.lua
    Provides various commands to manage the bot.

    /reload [-config]
        Reloads the bot, optionally without reloading config.

    /halt
        Safely stops the bot.

    /do
        Runs multiple, newline-separated commands as if they were individual
        messages.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bot = require('otouto.bot')
local utilities = require('otouto.utilities')

local control = {}

local cmd_pat -- Prevents the command from being uncallable.

function control:init()
    cmd_pat = self.config.cmd_pat
    control.triggers = utilities.triggers(self.info.username, cmd_pat,
        {'^'..cmd_pat..'do'}):t('reload', true):t('halt').table

    self.database.control = self.database.control or {}
    -- Ability to send the bot owner a message after a successful restart.
    if self.database.control.on_start then
        utilities.send_message(self.database.control.on_start.id, self.database.control.on_start.text)
        self.database.control.on_start = nil
    end
end

function control:action(msg)

    if msg.from.id ~= self.config.admin then
        return
    end

    if msg.date < os.time() - 2 then return end

    if msg.text_lower:match('^'..cmd_pat..'reload') then
        for pac, _ in pairs(package.loaded) do
            if pac:match('^otouto%.plugins%.') then
                package.loaded[pac] = nil
            end
        end
        package.loaded['otouto.bindings'] = nil
        package.loaded['otouto.utilities'] = nil
        package.loaded['otouto.drua-tg'] = nil
        package.loaded['config'] = nil
        if not msg.text_lower:match('%-config') then
            for k, v in pairs(require('config')) do
                self.config[k] = v
            end
        end
        self.database.control.on_start = {
            id = msg.chat.id,
            text = 'Bot reloaded!'
        }
        bot.init(self)
    elseif msg.text_lower:match('^'..cmd_pat..'halt') then
        self.is_started = false
        utilities.send_reply(msg, 'Stopping bot!')
        self.database.control.on_start = {
            id = msg.chat.id,
            text = 'Bot started!'
        }
    elseif msg.text_lower:match('^'..cmd_pat..'do') then
        local input = msg.text_lower:match('^'..cmd_pat..'do\n(.+)')
        if not input then
            utilities.send_reply(msg, 'usage: ```\n'..cmd_pat..'do\n'..cmd_pat..'command <arg>\n...\n```', true)
            return
        end
        input = input .. '\n'
        for command in input:gmatch('(.-)\n') do
            command = utilities.trim(command)
            msg.text = command
            bot.on_message(self, msg)
        end
    end

end

return control

