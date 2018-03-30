;; echo.fnl
;; Returns input.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :otouto.macros)
(require* serpent
          otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "echo <text>")
    (set self.doc "Repeats a string of text.")
    (set self.triggers (utilities.make_triggers bot [] [:echo true]))
    (values))

  :action (fn [self bot msg]
    (local input (utilities.input_from_msg msg))
    (if (not input)
        (do (utilities.send_plugin_help msg.chat.id msg.message_id bot.config.cmd_pat self) nil)
        (let [html_input (utilities.html_escape input)
              output (if (= msg.chat.type :supergroup)
                         (f-str "<b>Echo:</b>\n\"{}\"" (utilities.html_escape input))
                         (utilities.html_escape (.. utilities.char.zwnj input)))]
          (utilities.send_message msg.chat.id output true nil :html)
          nil)))
}
