package = 'otouto'
version = 'dev-1'

source = {
  url = 'git://github.com/topkecleon/otouto.git'
}

description = {
  summary = 'The plugin-wielding, multipurpose Telegram bot!',
  detailed = 'A plugin-wielding, multipurpose bot for the Telegram API.',
  homepage = 'http://otou.to',
  maintainer = 'Drew <drew@otou.to>',
  license = 'GPL-2'
}

dependencies = {
  'lua >= 5.2',
  'LuaSocket ~> 3.0',
  'LuaSec ~> 0.6',
  'dkjson ~> 2.5',
  'LPeg ~> 1.0'
}
