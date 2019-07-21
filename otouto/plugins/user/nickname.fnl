;; nickname.fnl
;; Allows a user to set or delete his nickname.

;; Copyright 2019 topkecleon <drew@otou.to>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

(local utilities (require :otouto.utilities))

{
  :init (fn [self bot]
    (set self.command "nick <nickname>")
    (set self.doc "Set a nickname. Pass <code>--</code> to delete it.")
    (set self.triggers (utilities.make_triggers bot [] [:nick true]))
    (if (not bot.database.userdata.nickname)
      (set bot.database.userdata.nickname {}))
    (set self.db bot.database.userdata.nickname)
    (values))

  ; No input returns nickname, or info if one isn't set.
  ; "--" or an em dash deletes a nickname.
  :action (fn [_ _ msg _ user]
    (utilities.send_reply msg (let [input (utilities.input msg.text)]
      (if (not input)
          (if user.data.nickname
              (.. "Your nickname is " user.data.nickname ".")
              ; else
              "You have no nickname.")
          ; else if input is '--' or em dash
          (or (= input "--") (= input utilities.char.em_dash))
          ; Delete the nickname.
          (do (set user.data.nickname nil)
              "Your nickname has been deleted.")
          ; else if input length > 32
          (> (utilities.utf8_len input) 32)
          "Nicknames cannot exceed 32 characters."
          ; else
          (let [nick (: input :gsub "\n" "")]
            (set user.data.nickname nick)
            (.. "Your nickname is now " nick "."))))))
}