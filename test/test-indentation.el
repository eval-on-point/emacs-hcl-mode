;;; test-indentation.el --- test for indentation

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'ert)
(require 'hcl-mode)

(ert-deftest no-indentation ()
  "No indentation case"
  (with-hcl-temp-buffer
    "
foo = \"val1\"
bar = \"val2\"
"

    (forward-cursor-on "bar")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) 0))))

(ert-deftest no-indentation-with-empty-line ()
  "No indentation case with empty lines"
  (with-hcl-temp-buffer
    "
foo = \"val1\"
    \t
bar = \"val2\"
"

    (forward-cursor-on "bar")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) 0))))

(ert-deftest no-indentation-into-comment ()
  "No indentation case into comment"
  (with-hcl-temp-buffer
    "
    foo = 10
/*
  bar = 20
*/
"

    (forward-cursor-on "bar")
    (let ((cur-indent (current-indentation)))
      (call-interactively 'indent-for-tab-command)
      (should (= (current-indentation) cur-indent)))))

(ert-deftest indentation-into-block ()
  "Indent into block"
  (with-hcl-temp-buffer
    "
provider \"aws\" {
foo = 10
}
"

    (forward-cursor-on "foo")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) hcl-indent-level)))

  (with-hcl-temp-buffer
    "
variable \"aws_amis\" {
foo = 10
}
"

    (forward-cursor-on "foo")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) hcl-indent-level))))


(ert-deftest map-indentation ()
  "Indent for map entry"
  (with-hcl-temp-buffer
    "
map_var {
key = val
}
"

    (forward-cursor-on "key")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) hcl-indent-level))))

(ert-deftest array-indentation ()
  "Indent for array element"
  (with-hcl-temp-buffer
    "
array_var [
\"foo\"
]
"

    (forward-cursor-on "foo")
    (call-interactively 'indent-for-tab-command)
    (should (= (current-indentation) hcl-indent-level))))

(ert-deftest no-indentation-triggers-completion ()
  "When no indentation is necessary, trigger symbol completion"
  (with-hcl-temp-buffer
    "
    foo = \"val1\"
    bar =
"
    (cl-letf (((symbol-function 'completion-at-point)
	       (lambda () (insert "pass"))))
      (forward-cursor-on "bar")
      (call-interactively 'indent-for-tab-command)
      (backward-word)
      (message (buffer-string))
      (should (looking-at "pass")))))

;;; test-indentation.el ends here
