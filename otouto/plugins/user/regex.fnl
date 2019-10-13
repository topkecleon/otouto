;; regex.fnl
;; Sed-like substitution using PCRE regular expressions. Ignores commands with
;; no reply-to message.

;; Copyright 2017 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* anise
          re
          (rename rex_pcre rex)
          otouto.utilities)

(local invoke_pattern (re.compile "\
invocation <- 's/' {~ pcre ~} '/' {~ repl ~} ('/' modifiers)? !.\
pcre <- ( [^\\/] / f_slash / '\\' )*\
repl <- ( [^\\/%] / percent / f_slash / capture / '\\' )*\
\
modifiers <- { flags? } {~ n_matches? ~} {~ probability? ~}\
\
flags <- ('i' / 'm' / 's' / 'x' / 'U' / 'X')+\
n_matches <- ('#' {[0-9]+}) -> '%1'\
probability <- ('%' {[0-9]+}) -> '%1'\
\
f_slash <- ('\\' '/') -> '/'\
percent <- '%' -> '%%%%'\
capture <- ('\\' {[0-9]+}) -> '%%%1'\
"))

(fn process_text [raw_text cmd_pat]
  (local text (: raw_text :match (f-str "^{cmd_pat}?(.*)$")))
  (if (not text)
    nil
    (let [(patt repl flags n_matches probability) (: invoke_pattern :match text)]
      (if (not patt)
        nil
        (values
          patt
          repl
          flags
          (and n_matches (tonumber n_matches))
          (and probability (tonumber probability)))))))

(fn make_n_matches [n_matches probability]
  (if
    (not probability)
    n_matches
    (not n_matches)
    (fn [] (< (* (math.random) 100) probability))
    ; else
    (do
      (var matches_left n_matches)
      (fn []
        (local tmp (and-or (< matches_left 0) 0 nil))
        (set matches_left (- matches_left 1))
        (values
          (< (* (math.random) 100) probability)
          tmp)))))

{
  :init (fn [self bot]
    (set self.command "s/<pattern>/<substitution>")
    (set self.help_word :regex)
    (set self.doc "Replace all matches for the given pattern.\n\z
Uses PCRE regexes.\n\z
\n\z
Modifiers are [&lt;flags&gt;][#&lt;matches&gt;][%probability]:\n\z
* Flags are i, m, s, x, U, and X, as per PCRE\n\z
* Matches is how many matches to replace\n\z
  (all matches are replaced by default)\n\z
* Probability is the percentage that a match will\n\z
  be replaced (100 by default)")
    (set self.triggers [(.. bot.config.cmd_pat "?s/.-/.-$")])
    (local flags_plugin (. bot.named_plugins :admin.flags))
    (set self.flag :regex_unwrapped)
    (set self.flag_desc "Regex substitutions aren't prefixed.")
    (when flags_plugin
      (tset flags_plugin.flags self.flag self.flag_desc))
    (values))

  :action (fn [self bot msg group]
    (if (not msg.reply_to_message)
      true
      (let [(patt repl flags n_matches probability) (process_text msg.text bot.config.cmd_pat)
            n_matches (make_n_matches n_matches probability)]
        (if (not patt)
          nil
          (let [input msg.reply_to_message.text
                input (and-or (= msg.reply_to_message.from.id bot.info.id)
                              (: input :match "^Did you mean:\n\"(.+)\"$")
                              input)
                (success result n_matched)
                (pcall (fn [] (rex.gsub input patt repl n_matches flags)))]
            (if (= success false)
                (let [output (.. "Malformed pattern!\n" (utilities.html_escape result))]
                  (utilities.send_reply msg output)
                  nil)
                (= n_matched 0)
                nil
                ; else
                (do (var output (anise.trim (: result :sub 1 4000)))
                  (set output (utilities.html_escape output))
                  (when (not (and flags_plugin group.data.admin.flags[self.flag]))
                    (set output (f-str "<b>Did you mean:</b>\n\"{}\"" output)))
                  (utilities.send_reply msg.reply_to_message output :html)
                  nil)))))))
}
