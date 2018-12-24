;; wikipedia.fnl
;; Returns a Wikipedia result for a given query.

;; Copyright 2018 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* ssl.https
          socket.url
          (rename dkjson json)
          otouto.utilities)

{
  :init (fn [self bot]
    (set self.command "wikipedia <query>")
    (set self.doc
      "Returns an article from Wikipedia.\n\z
      Aliases: /w, /wiki")
    (set self.triggers (utilities.make_triggers bot []
      [:wikipedia true] [:wiki true] [:w true]))
    (set self.search_url (.. "https://" bot.config.lang ".wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch="))
    (set self.result_url (.. "https://" bot.config.lang ".wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exchars=4000&explaintext=&titles="))
    (set self.article_url (.. "https://" bot.config.lang ".wikipedia.org/wiki/")))

  :get_title (fn [dsq] (let [t []]
    (each [_ v (pairs dsq)]
      (if (not (: v.snippet :match "may refer to"))
        (table.insert t v.title)))
    (if (> (# t) 0) (. t 1) false)))

  :build (fn [self title text]
    (f-str "<b>{}</b>\n{}\n<a href=\"{}\">Read more.</a>"
      (utilities.html_escape title)
      (let [l (: text :find "\n")]
        (if l (: text :sub 1 (- l 1)) text))
      (.. self.article_url (url.escape title)))
  )

  :action (fn [self bot msg] (let [input (utilities.input_from_msg msg)]
    (let [output
      (if (not input) self.doc
        (let [(res code) (https.request (.. self.search_url (url.escape input)))]
          (if (~= code 200) bot.config.errors.connection
            (let [data (json.decode res)]
              (if (or (not data.query) (= data.query.searchinfo.totalhits 0)) bot.config.errors.results
                (let [title (self.get_title data.query.search)]
                  (if (not title) bot.config.errors.results
                    (let [(res code) (https.request (.. self.result_url (url.escape title)))]
                      (if (~= code 200) bot.config.errors.connection
                        (let [(_ text) (next (. (json.decode res) :query :pages))]
                          (if (not text) bot.config.errors.results
                            (: self :build title text.extract))))))))))))]
    (utilities.send_reply msg output :html)))
    nil)
}
