;; bible.fnl
;; Returns Bible verses.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          socket.http
          socket.url)

{
  :init (fn [self bot]
    (when (not bot.config.biblia_api_key)
      (io.write "Missing config value: biblia_api_key.\n\z \tuser.bible will \z
        not work without a key from http://bibliaapi.com/.\n"))
    (set self.url "http://api.biblia.com/v1")

    (set self.command "bible <reference>")
    (set self.doc
      "Returns a verse from the American Standard Version of the Bible, \z
       or an apocryphal verse from the King James Version. \z
       Results from Biblia.com.")
    (set self.triggers (utilities.make_triggers bot [] [:bible true] [:b true]))
    (values))

  :biblia_content (fn [self key bible passage]
    (http.request
      (f-str "{self.url}/bible/content/{bible}.txt?key={key}&passage={}"
        (url.escape passage))))

  :action (fn [self bot msg]
    (local input (utilities.input_from_msg msg))
    (if (not input)
      (do (utilities.send_plugin_help msg.chat.id msg.message_id bot.config.cmd_pat self) nil)
      (let [key bot.config.biblia_api_key]
        (var (output res) (: self :biblia_content key "ASV" input))
        (when (or (not output) (~= res 200) (= (: output :len) 0))
          (set (output res) (: self :biblia_content key "KJVAPOC" input)))
        (when (or (not output) (~= res 200) (= (: output :len) 0))
          (set output bot.config.errors.results))
        (when (> (: output :len) 4000)
          (set output "The text is too long to post here. Try being more specific."))
        (utilities.send_reply msg output)
        nil)))
}

