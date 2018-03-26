;; about.lua
;; Returns owner-configured information related to the bot and a link to the
;; source code.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local utilities (require :otouto.utilities))
(require-macros :otouto.macros)

{
  :init (fn [self bot]
    (set self.command "about")
    (set self.doc "Returns information about the bot")
    (set self.text (f-str "{bot.config.about_text}\z
      \nBased on [otouto](https://github.com/topkecleon/otouto) v{bot.version} by topkecleon."))
    (set self.triggers (make-triggers bot [] :about :start)))
  :action (fn [self, _bot, msg]
    (utilities.send_message msg.chat.id self.text true nil true))
}
