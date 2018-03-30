;; reactions.fnl
;; Provides a list of callable emoticons for the poor souls who don't have a
;; compose key.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "reactions")
    (set self.doc "Returns a list of \"reaction\" emoticon commands.")
    (set self.triggers (utilities.make_triggers bot [] :reactions))

    (local cmd_pat bot.config.cmd_pat)
    (local username (: bot.info.username :lower))
    ; Generate a command list message triggered by "/reactions".
    (set self.help "Reactions:\n")
    (each [trigger reaction (pairs bot.config.reactions)]
      (set self.help (f-str "{self.help}• {cmd_pat}{trigger}: {reaction}\n"))
      (table.insert self.triggers (f-str "^{cmd_pat}{trigger}"))
      (table.insert self.triggers (f-str "^{cmd_pat}{trigger}@{username}"))
      (table.insert self.triggers (f-str "{cmd_pat}{trigger}$"))
      (table.insert self.triggers (f-str "{cmd_pat}{trigger}@{username}$"))
      (table.insert self.triggers (f-str "\n{cmd_pat}{trigger}"))
      (table.insert self.triggers (f-str "\n{cmd_pat}{trigger}@{username}"))
      (table.insert self.triggers (f-str "{cmd_pat}{trigger}\n"))
      (table.insert self.triggers (f-str "{cmd_pat}{trigger}@{username}\n"))))

  :action (fn [self bot msg]
    (local cmd_pat bot.config.cmd_pat)
    (if (string.match msg.text_lower (f-str "{cmd_pat}reactions"))
      (do (utilities.send_message msg.chat.id self.help true nil :html) nil)
      (each [trigger reaction (pairs bot.config.reactions)]
        (when (string.match msg.text_lower (.. cmd_pat trigger))
          (utilities.send_message msg.chat.id reaction true nil :html)))))
}
