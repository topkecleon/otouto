;; maybe.fnl
;; Runs a command, if it feels like it.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "maybe [int%] <command>")
    (set self.doc "Runs a command sometimes (default 50% chance).")
    (set self.triggers (utilities.make_triggers bot [] [:maybe true]))
    (values))

  :action (fn [self bot msg]
    (local (probability input)
      (: msg.text :match (f-str "^{bot.config.cmd_pat}maybe%s+(%d*)%%?%s*(.+)")))
    (if (not input)
      (do (utilities.send_plugin_help msg.chat.id msg.message_id bot.config.cmd_pat self) nil)
      (let [probability (or (tonumber probability) 50)]
        (when (< (* (math.random) 100) probability)
          (set msg.text (anise.trim input))
          (: self :on_message msg)))))
}
