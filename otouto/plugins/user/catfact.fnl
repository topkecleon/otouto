;; catfact.fnl
;; Returns cat facts.

;; Based on a plugin by matthewhesketh.
;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* (rename dkjson json)
          otouto.utilities
          ssl.https)

{
  :init (fn [self bot]
    (set self.url "https://catfact.ninja/fact")

    (set self.command "catfact")
    (set self.doc "Returns a cat fact from catfact.ninja.")
    (set self.triggers (utilities.make_triggers bot [] [:catfact true]))
    (values))

  :action (fn [self bot msg]
    (local (jstr code) (https.request self.url))
    (if (code ~= 200)
      (do (utilities.send_reply msg bot.config.errors.connection) nil)
      (let [data (json.decode jstr)
            output (f-str "<b>Cat Fact</b>\n<i>{}</i>" (utilities.html_escape data.fact))]
        (utilities.send_message msg.chat.id output true nil :html)
        nil)))
}
