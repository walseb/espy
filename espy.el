;;; espy.el --- Emacs Simple Password Yielder -*- lexical-binding: t -*-

;; Author: Sebastian Wålinder <s.walinder@gmail.com>
;; URL: https://github.com/walseb/espy
;; Version: 1.0
;; Package-Requires: ((emacs "24"))
;; Keywords: convenience

;; espy.el is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; espy.el is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; To espy is to see something at a distance which is what this package is about.
;; This package allows users to fetch a password from a file without visiting
;; it. It gathers all headers containing passwords defined by
;; `espy-header-prefix' and `espy-password-prefix' and presents them to the user.
;; The choosen password gets added to the kill ring.
;;
;; For example using a password file with the content of
;; (with no whitespace before any prefix)
;;
;;    *** Header1
;;    >> Password1
;;
;; and running
;;
;;    (espy)
;;
;; would result in one entry `Header1' being selectable. Choosing this entry
;; results in `Password1' being copied to the kill-ring

;;; Code:

(defvar espy-password-file "~/password.org.gpg"
  "The file to pull passwords from.")

(defvar espy-header-prefix "*"
  "A single letter string prefixing password headings.

Expected to be repeated 1 or more times before a
whitespace followed by a password in password file.")

(defvar espy-password-prefix ">>"
  "A string prefixing passwords.")

(defun espy-get-password-headers ()
  "Fetches all headers containing a password in a file."
  (with-temp-buffer
    (insert-file-contents espy-password-file)
    (goto-char (point-min))
    ;; Search for user selected header
    (let* ((found-headers (list)))
      (while
	  (ignore-errors
	    ;; Go to next header in case last header had more than 1 password
	    (re-search-forward (concat "^" espy-header-prefix "+\s"))
	    (re-search-forward (concat "^" espy-password-prefix))
	    (re-search-backward (concat "^" espy-header-prefix "+\s"))
	    ;; Search-backward puts the cursor at column position 0, fix this
	    (re-search-forward "\s"))
	;; Push header string to list
	(push (buffer-substring-no-properties (point) (line-end-position)) found-headers))
      found-headers)))

;;;###autoload
(defun espy ()
  "Scans `espy-password-file' and prompts user for password entry.

After user has selected a password entry it is copied to the kill ring."
  (interactive)
  (with-temp-buffer
    (insert-file-contents espy-password-file)
    (goto-char (point-min))
    ;; Go to selected heading
    (re-search-forward
     (concat espy-header-prefix " "
	     (completing-read "Get password: " (espy-get-password-headers))))
    ;; Go to heading password
    (re-search-forward (concat "^" espy-password-prefix "\s"))
    (kill-new (buffer-substring-no-properties (point) (line-end-position)))))

(provide 'espy)

;;; espy.el ends here
