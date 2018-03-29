;; cats.fnl
;; Returns photos of cats from thecatapi.com.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local http (require :socket.http))

(local bindings (require :otouto.bindings))
(local utilities (require :otouto.utilities))
(require-macros :otouto.macros)

{
  :init (fn [self bot]
    (when (not bot.config.thecatapi_key)
      (print "Missing config value: thecatapi_key.\n\z
        cats.lua will be enabled, but there are more features with a key."))
    (set self.url
      (f-str "http://thecatapi.com/api/images/get?format=html&type=jpg{}"
        (if bot.config.thecatapi_key (f-str "&api_key={bot.config.thecatapi_key}") "")))

    (set self.command "cat")
    (set self.doc "Returns a cat!")
    (set self.triggers (utilities.make_triggers bot [] :cat))
    (values))

  :action (fn [self bot msg]
    (local (str res) (http.request self.url))
    (if (~= res 200)
      (do
        (utilities.send_reply msg bot.config.errors.connection)
        nil)
      (do
        (bindings.sendPhoto {
          :chat_id msg.chat.id
          :photo (: str :match "<img src=\"(.-)\">")
        })
        nil)))
}
