; xkcd.fnl
; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* (rename dkjson json)
  ssl.https
  extern.bindings
  otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "xkcd [i]")
    (set self.doc "Returns the latest xkcd strip or a specified one. \
      <i>i</i> may be \"r\" or \"random\" for a random strip.")
    (set self.triggers (utilities.make_triggers bot [] [:xkcd true]))

    (when (not bot.database.xkcd) (: self :later bot)))

  :later (fn [self bot]
    (: bot :do_later self.name (+ (os.time) 21600))
    (local (res code) (https.request "https://xkcd.com/info.0.json"))
    (when (= code 200)
      (set bot.database.xkcd (json.decode res))))

  :action (fn [self bot msg] (let [input (utilities.get_word msg.text 2)
    (res code) (https.request (f-str "https://xkcd.com/{}/info.0.json"
      (if (or (= input :r) (= input :random))
          (math.random bot.database.xkcd.num)
        (tonumber input)
          input
        ;else
          (tostring bot.database.xkcd.num))))]
    (when (= code 200) (let [strip (json.decode res)]
      ; Simple way to correct an out-of-date latest strip.
      (when (> strip.num bot.database.xkcd.num) (set bot.database.xkcd strip))

      (bindings.sendPhoto {
        :chat_id msg.chat.id
        :parse_mode :html
        :photo strip.img
        :caption (f-str "<b>{}</b>\n<i>{}</i>\nhttps://xkcd.com/{}"
          (utilities.html_escape (utilities.fix_utf8 strip.safe_title))
          (utilities.html_escape strip.alt)
          strip.num
        )
      })))))
}
