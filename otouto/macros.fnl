;; macros.fnl
;; Macros shared among Fennel otouto plugins.

;; Copyright 2018 bb010g <bb010g@gmail.com>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

{
  "void" (fn [...]
    (local out (list (sym :do) ...))
    (table.insert out (list (sym :values)))
    out)

  "f-str" (lambda [input]
    (when (~= (type input) :string)
      (error "f-str: must be called with a string"))
    (var cat (list (sym "..")))
    (var state :string)
    (var bytes [])
    (for [i 1 (# input)]
      (local b (string.byte input i))
      (if (= b 123) ; left curly
          (if (= state :string)
              (set state :expr-first)
              (= state :expr-first) ; escaped curly
              (do
                (set state :string)
                (table.insert bytes b))
              (= state :expr)
              (error "f-str: can't have curly braces in expressions")
              (= state :escape-right)
              (error "f-str: unmatched right curly must be followed by another")
              ; else
              (error "f-str: improper left curly brace")) ; unreachable
          (= b 125) ; right curly
          (if (= state :expr)
              (do
                (set state :string)
                (table.insert cat (sym (string.char (table.unpack bytes))))
                (set bytes []))
              (= state :string)
              (set state :escape-right)
              (= state :escape-right)
              (do
                (set state :string)
                (table.insert bytes b))
              (= state :expr-first)
              (error "f-str: empty single curly braces")
              ; else
              (error "f-str: improper right curly brace")) ; unreachable
          ; else
          (if (or (= state :string) (= state :expr))
              (table.insert bytes b)
              (= state :expr-first) ; starting expression
              (do
                (set state :expr)
                (table.insert cat (string.char (table.unpack bytes)))
                (set bytes [b]))
              (= state :escape-right)
              (error "f-str: unmatched right curly must be followed by another")
              ; else
              (error (.. "f-str: unknown state " state))))) ; unreachable
    (if (= state :string)
        (when (> (# input) 0)
          (table.insert cat (string.char (table.unpack bytes))))
        (or (= state :expr) (= state :expr-first))
        (error "f-str: unmatched right curly")
        (= state :escape-right)
        (error "f-str: unmatched left curly")
        ; else
        (error (.. "f-str: unknown state " state))) ; unreachable
    cat)
}
