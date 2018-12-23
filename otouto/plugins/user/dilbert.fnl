; dilbert.fnl
; Copyright 2018 topkecleon <drew@otou.to>
; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* ssl.https
  socket.url
  otouto.bindings
  otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "dilbert [date]")
    (set self.doc (.. bot.config.cmd_pat "dilbert [YYYY-MM-DD] \
      Returns the latest <a href=\"https://dilbert.com\">Dilbert</a> strip or that of a given date."))
    (set self.triggers (utilities.make_triggers bot [] [:dilbert true])))

  :action (fn [self bot msg] (let [input (utilities.get_word msg.text 2)]
    (local (res code)
           (https.request (.. "https://dilbert.com/strip/" (url.escape (or
              (and input (: input :match "^%d%d%d%d%-%d%d%-%d%d$"))
              (os.date "%F"))))))
    (if (~= code 200)
      (do (utilities.send_reply msg bot.config.errors.connection) nil)
    ;else
      (bindings.sendPhoto {
        :chat_id msg.chat.id
        :photo (: res :match "<meta property=\"og:image\" content=\"(.-)\"/>")
        :caption (: res :match "<meta property=\"article:publish_date\" content=\"(.-)\"/>")})
      nil)))
}
