;; macros.fnl
;; Macros shared among Fennel otouto plugins.

;; Copyright 2018 bb010g <bb010g@gmail.com>
;; This code is licensed under the GNU AGPLv3. See /LICENSE for details.

{
  "void" (fn [...]
    (local out (list (sym :do) ...))
    (table.insert out (list (sym :values)))
    out)

  "require*" (fn [...]
    (local names (list))
    (local requires (list (sym :values)))
    (each [_ spec (pairs [...])]
      (if ; path, import as tail
         (sym? spec)
         (let [path (. spec 1)
               path-parts (or (multi-sym? path) [path])
               tail (. path-parts (# path-parts))]
           (table.insert names (sym tail))
           (table.insert requires (list (sym :require) path)))
         ; typed spec
         (and (list? spec))
         (let [ty (. spec 1)
               len (# spec)]
           (assert (sym? ty) "require*: spec type must be a symbol")
           (if ; rename, import as second arg
               (= (. ty 1) :rename)
               (do
                (assert (= (% len 2) 1) "require*: rename needs pairs of paths and names")
                (for [i 2 len 2]
                  (let [path (. spec i)
                        name (. spec (+ 1 i))]
                    (assert (sym? path) "require*: rename's paths must be symbols")
                    (assert (sym? name) "require*: rename's names must be symbols")
                    (table.insert names name)
                    (table.insert requires (list (sym :require) (. path 1))))))
               ; unknown typed spec type
               (error "require*: unknown spec type")))
         ; unknown require spec
         (error "require*: unknown spec")))
    (list (sym :local) names requires))

  "f-str" (lambda [input ...]
    (when (~= (type input) :string)
      (error "f-str: must be called with a string"))
    (local cat (list (sym "..")))
    (local args [...])
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
              ; else (unreachable)
              (error "f-str: improper left curly brace"))
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
              (do
                (assert (> (# args) 0) "f-str: Missing argument")
                (set state :string)
                (table.insert cat (string.char (table.unpack bytes)))
                (set bytes [])
                (table.insert cat (table.remove args 1)))
              ; else (unreachable)
              (error "f-str: improper right curly brace"))
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
              ; else (unreachable)
              (error (.. "f-str: unknown state " state)))))
    (if (= state :string)
        (when (> (# input) 0)
          (table.insert cat (string.char (table.unpack bytes))))
        (or (= state :expr) (= state :expr-first))
        (error "f-str: unmatched right curly")
        (= state :escape-right)
        (error "f-str: unmatched left curly")
        ; else (unreachable)
        (error (.. "f-str: unknown state " state)))
    cat)
}
