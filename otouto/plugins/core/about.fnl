;; about.fnl
;; Returns owner-configured information related to the bot and a link to the
;; source code.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "about")
    (set self.doc "Returns information about the bot")
    (set self.text (f-str "{bot.config.about_text}\z
      \nBased on <a href=\"https://github.com/topkecleon/otouto\">otouto</a> v{bot.version} by topkecleon."))
    (set self.triggers (utilities.make_triggers bot [] :about :start))
    nil)

  :action (fn [self, bot, msg]
    (utilities.send_message msg.chat.id self.text true nil :html)
    (values))
}
