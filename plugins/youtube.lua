-- Youtube Plugin for bot based on otouto
-- Glanced at https://github.com/yagop/telegram-bot/blob/master/plugins/youtube.lua
local PLUGIN = {}

PLUGIN.doc = [[
  /youtube <query>
  Search videos on YouTube.
]]

PLUGIN.triggers = {
  '^/youtube'
}

function PLUGIN.action(msg)
  -- BASE
  local input = get_input(msg.text)
  if not input then
    return send_msg(msg, PLUGIN.doc)
  end
  --URL API
  local url = 'https://www.googleapis.com/youtube/v3/search?'
  url = url..'part=snippet'..'&maxResults=4'..'&type=video'
  url = url..'&q='..URL.escape(input).."&key=AIzaSyAfe7SI8kwQqaoouvAmevBfKumaLf-3HzI"
  -- JSON
  local res,code  = HTTPS.request(url)
  if code ~= 200 then return nil end
  local data_JSON = JSON.decode(res)
  -- Print Items
  local text = ""
  for k,item in pairs(data_JSON.items) do
    text = text..'http://youtu.be/'..item.id.videoId..' '..item.snippet.title..'\n\n'
  end
  -- END - ERRO 404
  local text_end = text
  if text == "" then
    text_end = "Not found video"
  end
  -- Send MSG
  send_message(msg.chat.id, text_end)

end

return PLUGIN
