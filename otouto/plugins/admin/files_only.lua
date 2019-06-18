--[[
    filesonly.lua
    A flag to delete photos, videos, gifs, etc, and reupload them as files.
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('extern.bindings')
local utilities = require('otouto.utilities')

local P = {}

function P:init(bot)
    local flags_plugin = bot.named_plugins['admin.flags']
    assert(flags_plugin, self.name .. ' requires flags')
    self.flag = 'files_only'
    self.flag_desc = 'Deletes photos and videos and reuploads them as files.'
    flags_plugin.flags[self.flag] = self.flag_desc
    self.triggers = {''}
    self.administration = true
end

function P:action(bot, msg, group)
    if not group.data.admin.flags[self.flag] then
        return 'continue'
    end

    local file_id
    if msg.photo then
        file_id = msg.photo[#msg.photo].file_id
    elseif msg.video_note then
        file_id = msg.video_note.file_id
    end

    if file_id then
        local success, result = bindings.getFile{file_id = file_id}
        if success then
            local filename = utilities.download_file(
                'https://api.telegram.org/file/bot' .. bot.config.bot_api_key
                    .. '/' .. result.result.file_path,
                '/tmp/' .. os.time() .. result.result.file_path:match('%..-$')
            )
            local caption = 'Media from ' .. utilities.print_name(msg.from)
            if msg.caption then
                caption = caption .. ':\n' .. msg.caption
            end
            if bindings.sendDocument(
                {chat_id = msg.chat.id, caption = caption},
                {document = filename}
            ) then
                bindings.deleteMessage{
                    chat_id = msg.chat.id,
                    message_id = msg.message_id
                }
            end
            os.execute('rm ' .. filename)
            return
        end
    end

    return 'continue'
end

return P
