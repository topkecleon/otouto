(require-macros :anise.macros)
(require* anise)
; For details on configuration values, see README.md#configuration.
{

  ; Your authorization token from the botfather. (string, put quotes)
  :bot_api_key (os.getenv "OTOUTO_BOT_API_KEY")
  ; Your Telegram ID (number).
  :admin (math.floor (os.getenv "OTOUTO_ADMIN_ID"))
  ; Two-letter language code.
  ; Fetches it from the system if available, or defaults to English.
  :lang (let [lang (os.getenv "LANG")]
          (and-or lang (: lang :sub 1 2) "en"))
  ; The channel, group, or user to send error reports to.
  ; If this is not set, errors will be printed to the console.
  :log_chat (or (os.getenv "OTOUTO_LOG_ID") nil)
  ; The symbol that starts a command. Usually noted as "/" in documentation.
  :cmd_pat "/"
  ; The filename of the database. If left nil, defaults to $username.json.
  :database_name (os.getenv "OTOUTO_JSON_FILE")
  ; The block of text returned by /start and /about..
  :about_text
"I am otouto, the plugin-wielding, multipurpose Telegram bot.\
\
Send /help to get started."

  ;; Third-party API keys
  ; The Cat API (thecatapi.com) (optional for cats)
  :cat_api_key nil
  ; Biblia (bibliaapi.com) (mandatory for bible)
  :biblia_api_key nil
  ; NASA APOD (api.nasa.gov) (optional for apod)
  :nasa_api_key "DEMO_KEY"
  ; google (mandatory for google_translate)
  :google_api_key nil

  :paged_lists {
    :page_length 8
    :list_duration 900
    :private_lists false
  }

  ; some dumb stuff
  :user_lists {
    ; Lists are sorted alphabetically. Set to true to sort backward.
    :reverse_sort false
  }

  :user_info {
    ; If set to true, user info will only be collected in administrated groups.
    :admin_only false
  }

  ; Generic error messages.
  :errors {
    :generic "An unexpected error occurred."
    :connection "Connection error."
    :results "No results found."
    :argument "Invalid argument."
    :syntax "Invalid syntax."
    :specify_targets "Specify a target or targets by reply, username, or ID."
    :specify_target "Specify a target by reply, username, or ID."
  }

  :administration {
    ; Conversation, group, or channel for kick/ban notifications.
    ; Defaults to config.log_chat if left empty.
    :log_chat nil
    ; link or username
    :log_chat_username nil
    ; First strike warnings will be deleted after this, in seconds.
    :warning_expiration 30
    ; Default flag settings.
    :flags {
      :antibot true
      :antilink true
    }
  }

  :reactions {
    :shrug "¯\\_(ツ)_/¯"
    :lenny "( ͡° ͜ʖ ͡°)"
    :flip "(╯°□°）╯︵ ┻━┻"
    :look "ಠ_ಠ"
    :shots "SHOTS FIRED"
    :facepalm "(－‸ლ)"
  }

  :greetings {
    "Hello, #NAME." {
      "hello"
      "hey"
      "hi"
      "good morning"
      "good day"
      "good afternoon"
      "good evening"
    }
    "Goodbye, #NAME." {
      "good%-?bye"
      "bye"
      "later"
      "see ya"
      "good night"
    }
    "Welcome back, #NAME." {
      "i'm home"
      "i'm back"
    }
    "You're welcome, #NAME." {
      "thanks"
      "thank you"
    }
  }

  ; To enable a plugin, add its name to the list.
  :plugins (let
      [
        core-critical [
          :core.control
          :core.luarun
          :core.user_info
          :core.group_whitelist
          :core.group_info
        ]
        admin-critical [
          :admin.flags
          :admin.ban_remover
          :admin.autopromoter
        ]
        admin-filters [
          :admin.antibot
          :admin.antilink
          :admin.antisquigpp
          :admin.antisquig
          :admin.antisticker
          :admin.delete_left_messages
          :admin.delete_join_messages
          :admin.filterer
          :admin.files_only
        ]
        core [
          :core.end_forwards
          :core.user_blacklist
          :core.about
          :core.delete_messages
          :core.disable_plugins
          :core.help
          :core.paged_lists
          :core.ping
          :core.user_lists
        ]
        admin [
          :admin.add_admin
          :admin.add_group
          :admin.add_mod
          :admin.antihammer_whitelist
          :admin.ban
          :admin.deadmin
          :admin.demod
          :admin.filter
          :admin.fix_perms
          :admin.get_description
          :admin.get_link
          :admin.hammer
          :admin.interactive_flags
          :admin.kick
          :admin.kickme
          :admin.list_admins
          :admin.list_flags
          :admin.list_groups
          :admin.list_mods
          :admin.list_rules
          :admin.mute
          :admin.regen_link
          :admin.remove_group
          :admin.set_description
          :admin.set_governor
          :admin.set_rules
          :admin.temp_ban
          :admin.unhammer
          :admin.unrestrict
        ]
        user [
          :user.apod
          ;:user.bible
          :user.calc
          :user.cat_fact
          :user.cats
          :user.currency
          :user.dice
          :user.dilbert
          :user.echo
          :user.eight_ball
          :user.full_width
          ;:user.google_translate
          :user.greetings
          :user.hex_color
          :user.maybe
          :user.nickname
          :user.regex
          :user.reminders
          :user.slap
          :user.shout
          :user.urban_dictionary
          :user.user_lookup
          :user.whoami
          :user.wikipedia
          :user.xkcd
          :user.reactions
        ]
      ]

    (anise.concat
      core-critical
      ;admin-critical
      ;admin-filters
      core
      ;admin
      user
    ))

}
