--[[
    bot.lua
    The heart and soul of otouto, ie the init and main loop.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bot = {}
local bindings -- Bot API bindings.
local utilities -- Miscellaneous and shared functions.

bot.version = '3.15.4'

 -- Function to be run on start and reload.
function bot:init()

    assert(self.config.bot_api_key, 'You didn\'t set your bot token in config.lua!')

    bindings = require('otouto.bindings').init(self.config.bot_api_key)
    utilities = require('otouto.utilities')

    -- Fetch bot information. Try until it succeeds.
    repeat
        print('Fetching bot information...\n')
        self.info = bindings.getMe()
    until self.info
    self.info = self.info.result

    -- todo: use a real database
    self.database_name = self.config.database_name or self.info.username .. '.db'
    if not self.database then
        self.database = utilities.load_data(self.database_name)
    end

    -- Save the bot's version in the database to make migration simpler.
    self.database.version = bot.version

    -- Database table to store user-specific information, such as nicknames or
    -- API usernames.
    self.database.userdata = self.database.userdata or {}

    self.plugins = {}
    self.named_plugins = {}
    for _, pname in ipairs(self.config.plugins) do
        local plugin = require('otouto.plugins.'..pname)
        table.insert(self.plugins, plugin)
        self.named_plugins[pname] = plugin
        if plugin.init then plugin.init(self) end
        if plugin.doc then
            plugin.doc = '<pre>'..utilities.html_escape(plugin.doc)..'</pre>'
        end
        if not plugin.triggers then plugin.triggers = {} end
    end

    -- Set loop variables.
    self.last_update = self.last_update or 0 -- Update offset.
    self.last_cron = self.last_cron or os.date('%M') -- Last cron job.
    self.last_database_save = self.last_database_save or os.date('%H') -- Last db save.
    self.is_started = true

    print('@' .. self.info.username .. ', AKA ' .. self.info.first_name ..' ('..self.info.id..')\n')

end

 -- Function to be run on each new message.
function bot:on_message(msg)

    -- Do not process old messages.
    if msg.date < os.time() - 5 then return end

    -- If no text, use captions.
    msg.text = msg.text or msg.caption or ''
    if msg.reply_to_message then
        msg.reply_to_message.text = msg.reply_to_message.text or msg.reply_to_message.caption or ''
    end

    -- Support deep linking.
    local payload = msg.text:match('^/start (.+)$')
    if payload then
        msg.text = self.config.cmd_pat .. payload
        print('payload', msg.text)
    end

    msg.text_lower = msg.text:lower()

    -- Do the thing.
    for _, plugin in ipairs(self.plugins) do
        for _, trigger in ipairs(plugin.triggers) do
            if string.match(msg.text_lower, trigger) then
                local success, result = pcall(function()
                    return plugin.action(self, msg)
                end)

                if not success then
                    -- If the plugin has an error message, send it. If it does
                    -- not, use the generic one specified in config. If it's set
                    -- to false, do nothing.
                    if plugin.error then
                        utilities.send_reply(msg, plugin.error)
                    elseif plugin.error == nil then
                        utilities.send_reply(msg, self.config.errors.generic)
                    end
                    utilities.handle_exception(self, result, msg.from.id .. ': ' .. msg.text, self.config.log_chat)
                    return
                -- Continue if the return value is true.
                elseif result ~= true then
                    return
                end
            end
        end
    end
end

 -- main
function bot:run()
    bot.init(self)
    while self.is_started do
        -- Update loop.
        local res = bindings.getUpdates{
            timeout = 20,
            offset = self.last_update + 1,
            allowed_updates = '["message"]'
        }
        if res then
            -- Iterate over every new message.
            for _,v in ipairs(res.result) do
                self.last_update = v.update_id
                bot.on_message(self, v.message)
            end
        else
            print('[' .. os.date('%F %T') .. '] Connection error while fetching updates.')
        end

        -- Run cron jobs every minute.
        if self.last_cron ~= os.date('%M') then
            self.last_cron = os.date('%M')
            for i,v in ipairs(self.plugins) do
                if v.cron then -- Call each plugin's cron function, if it has one.
                    local result, err = pcall(function() v.cron(self) end)
                    if not result then
                        utilities.handle_exception(self, err, 'CRON: ' .. i, self.config.log_chat)
                    end
                end
            end
        end

        -- Save the "database" every hour.
        if self.last_database_save ~= os.date('%H') then
            self.last_database_save = os.date('%H')
            utilities.save_data(self.database_name, self.database)
        end
    end
    -- Save the database before exiting.
    utilities.save_data(self.database_name, self.database)
    print('Halted.\n')
end

return bot
