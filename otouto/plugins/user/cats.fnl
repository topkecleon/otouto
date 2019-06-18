;; cats.fnl
;; Returns photos of cats from thecatapi.com.

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* socket.http
          extern.bindings
          otouto.utilities)

{ :init
  (fn [self bot]
    (when (not bot.config.cat_api_key)
      (io.write "Missing config value: cat_api_key.\n\z
                 \tuser.cats will be enabled, but there are more features with a key.\n"))
    (set self.url
      (.. "http://thecatapi.com/api/images/get?format=html&type=jpg"
        (and-or bot.config.cat_api_key
          (.. "&api_key=" bot.config.cat_api_key)
          "")))

    (set self.command "cat")
    (set self.doc "Returns a cat!")
    (set self.triggers (utilities.make_triggers bot [] :cat))
    (values))

  :action
  (fn [self bot msg]
    (local (str res) (http.request self.url))
    (if (~= res 200)
      (do (utilities.send_reply msg bot.config.errors.connection) nil)
      (do (bindings.sendPhoto {:chat_id msg.chat.id
                               :photo (: str :match "<img src=\"(.-)\">")})
          nil)))}

