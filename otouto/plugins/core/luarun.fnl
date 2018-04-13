;; luarun.lua
;; Allows the bot owner to run arbitrary Lua or Fennel code inside the bot instance.
;; "/return" is an alias for "/lua return".

;; Copyright 2016 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(require-macros :anise.macros)
(require* otouto.utilities
          fennel
          fennelview
          serpent
          socket.url)

{
  :init (fn [self bot]
    (set self.triggers (utilities.make_triggers bot [] [:lua true] [:fnl true] [:return true]))
    (set self.err_msg (fn [x] (.. "Error:\n" (tostring x))))
    (values))

  :fennel_preamble "\z
(require-macros :anise.macros)\
(require* anise\
          otouto.autils\
          otouto.bindings\
          otouto.utilities\
          fennel\
          fennelview\
          serpent\
          socket.http\
          socket.url\
          ssl.https\
          (rename dkjson json))"

  :lua_preamble "\z
local anise = require('anise')\
local autils = require('otouto.autils')\
local bindings = require('otouto.bindings')\
local utilities = require('otouto.utilities')\
local fennel = require('fennel')\
local fennelview = require('fennelview')\
local serpent = require('serpent')\
local http = require('socket.http')\
local url = require('socket.url')\
local https = require('ssl.https')\
local json = require('dkjson')"

  :action (fn [self bot msg group user]
    (if (~= msg.from.id bot.config.admin)
      :continue
      (let [input (utilities.input msg.text)]
        (if (not input)
          (do (utilities.send_reply msg "Please enter a string to load.") nil)
          (let [mode (if (: msg.text_lower :match (f-str "^{bot.config.cmd_pat}fnl"))
                         :fennel
                         (: msg.text_lower :match (f-str "^{bot.config.cmd_pat}return"))
                         :lua_expr
                         ; else
                         :lua)
                code
                (if (= mode :fennel)
                    (fennel.compileString
                      (f-str "{self.fennel_preamble}\n(fn [bot msg group user] {input})"))
                    ; Lua
                    (let [input (if (= mode :lua_expr) (f-str "return {input}") input)]
                      (f-str "{self.lua_preamble}\nreturn function (bot, msg, group, user)\n{input}\nend")))
                (output err) (load code)
                text (if err
                       (utilities.html_escape err)
                       (: self :format_output mode err
                         (xpcall (output) self.err_msg bot msg group user)))]
            (utilities.send_reply msg (f-str "<code>{text}</code>") :html)
            nil)))))

  :format_value (fn [mode val depth]
    (if (= mode :fennel)
        (fennelview val {:depth depth})
        (or (= mode :lua) (= mode :lua_expr))
        (serpent.block val {:comment false :depth depth})
        ; else
        "Unknown format mode."))

  :format_output (fn [self mode ...]
    (local len (- (select :# ...) 2))
    (local max_length 4000)
    (if (= len 0)
        "Done!"
        ; else
        (do
          (var depth 5)
          (var text nil)
          (while (or (not text) (and (> (string.len text) 4000) (> depth 0)))
            (set text {})
            (for [i 1 len]
              (tset text i (utilities.html_escape
                             (self.format_value mode (select (+ i 2) ...) depth))))
            (set text (table.concat text "\n"))
            (set depth (- depth 1)))
          (if (> (string.len text) 4000)
            "Output is too large to print."
            text))))
}
