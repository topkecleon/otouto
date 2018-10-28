;; apod.fnl
;; Returns the NASA astronomy picture of the day, along with related text.

;; Credit to @HeitorPB.
;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* (rename dkjson json)
          otouto.utilities
          socket.url
          ssl.https)

{
  :init (fn [self bot]
    (set self.url (.. "https://api.nasa.gov/planetary/apod?api_key="
                      (or bot.config.nasa_api_key "DEMO_KEY")))

    (set self.command "apod [YYYY-MM-DD]")
    (set self.doc "Returns the latest Astronomy Picture of the Day from \z
      <a href=\"https://apod.nasa.gov/\">NASA</a>.")
    (set self.triggers (utilities.make_triggers bot [] [:apod true]))
    (values))

  :action (fn [self bot msg]
    (local input (utilities.input msg.text))
    (local is_date (: input match "^(%d+)%-(%d+)%-(%d+)$") input)
    (local url (.. self.url (and-or is_date (.. "&date=" (url.escape input)) "")))

    (local (jstr code) (https.request url))
    (if (~= code 200)
      (do (utilities.send_reply msg bot.config.errors.connection) nil)
      (let [data (json.decode jstr)]
        (if data.error
          (do (utilities.send_reply msg bot.config.errors.results) nil)
          (let [output (f-str "<b>{} (</b><a href=\"{}\"><{}</a><b>)</b>\n{}"
                              (utilities.html_escape data.title)
                              (utilities.html_escape (or data.hdurl data.url))
                              (or date (os.date "%F"))
                              (utilities.html_escape data.explanation))]
            (utilities.send_message msg.chat.id output false nil :html)
            nil)))))
}
