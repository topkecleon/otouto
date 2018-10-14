--[[
    bot.lua
    The heart and soul of otouto, i.e. the init and main loop.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bot = {}
local bindings -- Bot API bindings.
local utilities -- Miscellaneous and shared functions.
local anise -- More utility functions.
local autils -- Administration-related functions.

bot.version = '3.16 admin'

 -- Function to be run on start and reload.
function bot:init()

    assert(self.config.bot_api_key, 'You didn\'t set your bot token in config.lua!')
    assert(self.config.admin, 'You didn\'t set your admin ID in config.lua!')

    bindings = require('otouto.bindings').set_token(self.config.bot_api_key)
    utilities = require('otouto.utilities')
    anise = require('anise')
    autils = require('otouto.autils')

    -- Fetch bot information. Try until it succeeds.
    local success
    repeat
        io.write('Fetching bot information...\n')
        success, self.info = bindings.getMe()
    until success
    self.info = self.info.result

    io.write(string.format('%s [%s] @%s\n',
        self.info.first_name, self.info.id, self.info.username))

    -- todo: use a real database
    self.database_name = self.config.database_name or self.info.username .. '.json'
    if not self.database then
        self.database = utilities.load_data(self.database_name)
    end

    -- Save the bot's version in the database to make migration simpler.
    self.database.version = self.version

    -- Database table to store user-specific information, such as nicknames or
    -- API usernames.
    if not self.database.userdata then
        self.database.userdata = { hammered = {}, administrator = {} }
    end
    -- Database table to store disabled plugins for chats.
    self.database.disabled_plugins = self.database.disabled_plugins or {}

    if not self.database.groupdata then
        self.database.groupdata = { admin = {} }
    end
    -- administration
    self.database.administration = self.database.administration or {}

    -- do_later stuff
    self.database.later = self.database.later or {}

    self.plugins = {}
    self.named_plugins = {}
    self:load_plugins(self.config.plugins)

    -- Set loop variables.
    self.last_update = self.last_update or 0 -- Update offset.
    self.last_database_save = self.last_database_save or os.date('%H') -- Last db save.
    self.is_started = true
end

function bot:load_plugins(pnames, pos)
    local loaded = {}
    local errors = {}
    for _, pname in ipairs(pnames) do
        local success, plugin = xpcall(function ()
            return assert(require('otouto.plugins.'..pname), pname .. ' is falsy')
        end, function (msg) return debug.traceback(msg) end)
        if not success then
            table.insert(errors, {pname, plugin})
        else
            if pos == nil then
                table.insert(self.plugins, plugin)
            else
                table.insert(self.plugins, pos + 1, plugin)
            end
            table.insert(loaded, plugin)
            self.named_plugins[pname] = plugin
            plugin.name = pname
            if plugin.init then plugin:init(self) end
            if not plugin.triggers then plugin.triggers = {} end
        end
    end
    if #errors > 0 then
        local text = "Error(s) loading the following plugin(s):"
        for _, error in ipairs(errors) do
            text = text .. "\n" .. "=> " .. tostring(error[1]) .. "\n" .. tostring(error[2])
        end
        utilities.log_error(text, self.config.log_chat)
    end
    for _, plugin in ipairs(self.plugins) do
        if plugin.on_plugins_load then
            plugin:on_plugins_load(self, loaded)
        end
    end
end

function bot:unload_plugins(pnames)
    local unloaded = {}
    local not_found = {}
    for _, pname in ipairs(pnames) do
        local found = nil
        for i, plugin in ipairs(self.plugins) do
            if pname == plugin.name then
                found = table.remove(self.plugins, i)
                break
            end
        end
        if found then
            self.named_plugins[pname] = nil
            table.insert(unloaded, found)
        else
            table.insert(not_found, pname)
        end
    end
    if #not_found > 0 then
        local text = "The following plugin(s) could not be found: " .. table.concat(not_found, ", ")
        utilities.log_error(text, self.config.log_chat)
    end
    for _, plugin in ipairs(self.plugins) do
        if plugin.on_plugins_unload then
            plugin:on_plugins_unload(self, unloaded)
        end
    end
end

 -- Function to be run on each new message.
function bot:on_message(msg)

    -- Do not process old messages.
    if msg.date < os.time() - 15 then return end

    -- If no text, use captions. If neither, blank string.
    if msg.caption then
        msg.text = msg.caption
        msg.entities = msg.caption_entities
    elseif not msg.text then
        msg.text = ''
    end
    if msg.reply_to_message and msg.reply_to_message.caption then
        msg.reply_to_message.text = msg.reply_to_message.caption
        msg.reply_to_message.entities = msg.reply_to_message.caption_entities
    elseif not msg.reply_to_message.text then
        msg.reply_to_message.text = ''
    end

    -- Support deep linking.
    local payload = msg.text:match('^/start (.+)$')
    if payload then
        msg.text = self.config.cmd_pat .. payload
    end

    msg.text_lower = msg.text:lower()

    local disabled_plugins = self.database.disabled_plugins[tostring(msg.chat.id)]
    local user = utilities.user(self, msg.from.id)
    local group
    if msg.chat.type ~= 'private' then
        group = utilities.group(self, msg.chat.id)
    end

    -- Do the thing.
    for _, plugin in ipairs(self.plugins) do
        if
            (not (disabled_plugins and disabled_plugins[plugin.name])) and
            ((not plugin.administration or (group and group.data.admin))
                and user:rank(self, msg.chat.id) >= (plugin.privilege or 0))
        then
            for _, trigger in ipairs(plugin.triggers) do
                if string.match(msg.text_lower, trigger) then

                    local success, result = xpcall(function ()
                        return plugin:action(self, msg, group, user)
                    end, function (message) return debug.traceback(message) end)

                    if not success then
                        -- If the plugin has an error message, send it. If it does
                        -- not, use the generic one specified in config. If it's set
                        -- to false, do nothing.
                        if plugin.error then
                            utilities.send_reply(msg, plugin.error)
                        elseif plugin.error == nil then
                            utilities.send_reply(msg, self.config.errors.generic)
                        end
                        -- The message contents are included for debugging purposes.
                        utilities.log_error(result..'\n'..msg.text, self.config.log_chat)
                        return
                    -- Continue if the return value is 'continue'.
                    elseif result ~= 'continue' then
                        return
                    end
                end
            end
        end
    end
end

function bot:on_edit(msg)
    if msg.edit_date < os.time() - 15 then return end
    msg.text = msg.text or msg.caption or ''
    if msg.reply_to_message then
        msg.reply_to_message.text = msg.reply_to_message.text or msg.reply_to_message.caption or ''
    end
    msg.text_lower = msg.text:lower()

    local user = utilities.user(self, msg.from.id)
    local group
    if msg.chat.type ~= 'private' then
        group = utilities.group(self, msg.chat.id)
    end

    for _, plugin in ipairs(self.plugins) do
        if
            plugin.edit_action and
            ((not plugin.administration or (group and group.data.admin))
                and user:rank(self, msg.chat.id) >= (plugin.privilege or 0))
        then
            for _, trigger in ipairs(plugin.triggers) do
                if string.match(msg.text_lower, trigger) then

                    local success, result = xpcall(function ()
                        return plugin:edit_action(self, msg, group, user)
                    end, function (message) return debug.traceback(message) end)

                    if not success then
                        -- The message contents are included for debugging purposes.
                        utilities.log_error(result..'\n'..msg.text, self.config.log_chat)
                        return
                    -- Continue if the return value is true.
                    elseif result ~= true then
                        return
                    end
                end
            end
        end
    end
end

function bot:on_callback_query(query)
    if query.data then
        local pname = query.data:match('^%g+')
        if self.named_plugins[pname] and self.named_plugins[pname].callback_action then
            local plugin = self.named_plugins[pname]
            local success, result = xpcall(function()
                return plugin:callback_action(self, query)
            end, function(msg) return debug.traceback(msg) end)
            if not success then
                utilities.log_error(result..'\ncallback_action for '..pname,
                    self.config.log_chat)
            end
            return
        end
        bindings.answerCallbackQuery{
            callback_query_id = query.id,
            text = "Something went wrong! It's been noted."
        }
        utilities.log_error('Orphaned callback query: ' .. query.data,
            self.config.log_chat)
    elseif query.game_short_name then
        -- to do
    end
end

 -- main
function bot:run()
    self:init()
    while self.is_started do
        -- Update loop.
        local success, result = bindings.getUpdates{
            timeout = 5, -- change the global http/s timeout in utilities.lua
            offset = self.last_update + 1,
            allowed_updates = '["message","edited_message","callback_query"]'
        }
        if success then
            -- Iterate over every new message.
            for _,v in ipairs(result.result) do
                self.last_update = v.update_id
                if v.message then
                    self:on_message(v.message)
                elseif v.edited_message then
                    self:on_edit(v.edited_message)
                elseif v.callback_query then
                    self:on_callback_query(v.callback_query)
                end
            end
        else
            io.write('[' .. os.date('%F %T') .. '] Error while fetching updates.\n')
        end

        local now = os.time()
        local delete_this = {}
        for i, thing in ipairs(self.database.later) do
            if now >= thing.when then
                local plugin = self.named_plugins[thing.pname]
                if plugin then
                    local suc, err = xpcall(function()
                        plugin:later(self, thing.param)
                    end, function(msg) return debug.traceback(msg) end)
                    if suc then
                        table.insert(delete_this, i)
                    else
                        utilities.log_error(err, self.config.log_chat)
                    end
                else
                    table.insert(delete_this, i)
                    utilities.log_error(
                        'Later job discarded for missing plugin: '..thing.pname,
                        self.config.log_chat
                    )
                end
            end
        end
        for i = #delete_this, 1, -1 do
            table.remove(self.database.later, delete_this[i])
        end

        -- Save the "database" every hour.
        if self.last_database_save ~= os.date('%H') then
            utilities.save_data(self.database_name, self.database)
            self.last_database_save = os.date('%H')
        end
    end
    -- Save the database before exiting.
    utilities.save_data(self.database_name, self.database)
    io.write('Halted.\n')
end

 -- Schedule a plugin's later function to be run after the given interval.
 -- "when" is a Unix timestamp.
function bot:do_later(pname, when, param)
    table.insert(self.database.later, {
        pname = pname,
        when = when,
        param = param
    })
end

return bot
