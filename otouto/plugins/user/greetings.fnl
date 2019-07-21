; greetings.fnl
; Reponds to configurable terms with configurable greetings.

; Copyright 2019 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities)

{
  :init (fn [self bot]
    (set self.triggers {})
    (each [_ triggers (pairs bot.config.greetings)]
      (each [_ trigger (ipairs triggers)]
        (let [s (f-str "^{trigger},? {}%p*$" (: bot.info.first_name :lower))]
          (table.insert self.triggers s)))))

  :action (fn [_ bot msg]
    (var output "")
    (each [response triggers (pairs bot.config.greetings)]
        (each [_ trigger (ipairs triggers)]
          (when (: msg.text_lower :match trigger)
            (set output response))))
    (let [nick (: (utilities.get_nick bot msg.from) :gsub "%%" "%%%%")]
      (set output (: output :gsub "#NAME" nick)))
    (utilities.send_reply msg output))
}