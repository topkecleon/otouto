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

local lume = require('lume')

local utilities = require('otouto.utilities')

local control = {}

function control:init(bot)
    local cmd_pat = bot.config.cmd_pat
    self.cmd_pat = cmd_pat
    self.triggers = utilities.triggers(bot.info.username, cmd_pat,
        {'^'..cmd_pat..'do'}):t('hotswap', true):t('reload', true):t('halt').table

    bot.database.control = bot.database.control or {}
    -- Ability to send the bot owner a message after a successful restart.
    if bot.database.control.on_start then
        utilities.send_message(bot.database.control.on_start.id, bot.database.control.on_start.text)
        bot.database.control.on_start = nil
    end
end

function control:action(bot, msg)

    if msg.from.id ~= bot.config.admin then
        return
    end

    if msg.date < os.time() - 2 then return end

    local cmd_pat = self.cmd_pat
    if msg.text_lower:match('^'..cmd_pat..'hotswap') then
        local errs = {}
        local init = false
        for _, modname in ipairs(lume.split(utilities.input(msg.text))) do
            if modname == '!' then
                init = true
            else
                local mod, err = lume.hotswap(modname)
                if err ~= nil then
                    table.insert(errs, err)
                end
                if init then
                    mod:init(bot)
                end
            end
        end
        local reply = "Modules reloaded!"
        if #errs ~= 0 then
            reply = reply .. '\nErrors:\n' .. table.concat(errs, '\n')
        end
        utilities.send_reply(msg, reply)
    elseif msg.text_lower:match('^'..cmd_pat..'reload') then
        for pac, _ in pairs(package.loaded) do
            if pac:match('^otouto%.plugins%.') then
                package.loaded[pac] = nil
            end
        end
        package.loaded['otouto.bindings'] = nil
        package.loaded['otouto.utilities'] = nil
        package.loaded['lume'] = nil
        package.loaded['otouto.autils'] = nil
        package.loaded['config'] = nil
        if not msg.text_lower:match('%-config') then
            for k, v in pairs(require('config')) do
                bot.config[k] = v
            end
        end
        bot.database.control.on_start = {
            id = msg.chat.id,
            text = 'Bot reloaded!'
        }
        bot:init()
    elseif msg.text_lower:match('^'..cmd_pat..'halt') then
        bot.is_started = false
        utilities.send_reply(msg, 'Stopping bot!')
        bot.database.control.on_start = {
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
            command = lume.trim(command)
            msg.text = command
            bot:on_message(msg)
        end
    end

end

return control
