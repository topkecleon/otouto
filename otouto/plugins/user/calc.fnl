;; calc.fnl
;; Runs mathematical expressions through the mathjs.org API.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          socket.url
          ssl.https)

{
  :init (fn [self bot]
    (set self.url "https://api.mathjs.org/v1/?expr=")

    (set self.command "calc <expression>")
    (set self.doc "Returns solutions to mathematical expressions and \z
      conversions between common units. Results provided by mathjs.org.")
    (set self.triggers (utilities.make_triggers bot [] [:calc true]))
    (values))

  :action (fn [self bot msg]
    (local input (utilities.input_from_msg msg))
    (if (not input)
      (do (utilities.send_plugin_help msg.chat.id msg.message_id bot.config.cmd_pat self) nil)
      (let [(data res) (.. (https.request (.. url (url.escape input))))
            output (and-or data
                           (f-str "<code>{}</code>" (utilities.html_escape data))
                           bot.config.errors.connection)]
        (utilities.send_reply msg output :html)
        nil)))
}
