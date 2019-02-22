;;; flycheck-colored-status.el --- Show flycheck status as colored dots -*- lexical-binding: t -*-

;; Copyright (c) 2019 Damien Collard

;; Author: Damien Collard <damien.collard@laposte.net>
;; URL:
;; Version: 0.0.1
;; Keywords: convenience languages tools
;; Package-Requires: ((emacs "24.3") (flycheck "0.20"))

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

;; `flycheck-colored-status' replaces the standard Flycheck mode-line status
;; indicators with simple colored dots and counts for the error, warning and
;; info levels.
;;
;; The status uses dots by default, but this can be customized by setting
;; `flycheck-colored-status-indicator'.  Colors can be customized as well
;; through faces `flycheck-colored-status-LEVEL', where LEVEL is one of
;; `error', `warning' and `info'.
;;
;; Code inspired by flycheck-status-emoji.el, appearance inspired by a
;; a mode line somewhere...
;;
;; TODO: Make the minor mode menu appear on the error, warning and info dots.
;; (It does work when there's a single dot, i.e. when there's no error, warning
;; nor info.)

;;; Code:

(require 'flycheck)

(eval-when-compile
  (require 'cl-lib)
  (require 'let-alist))

(defcustom flycheck-colored-status-indicator "·"
  "Character used to show the flycheck status.
The default is '·' (Unicode MIDDLE DOT).
A nice alternative would be '●' (Unicode BLACK CIRCLE)."
  :group 'flycheck-colored-status
  :type 'string)

(defface flycheck-colored-status-error '((t (:inherit flycheck-error-list-error)))
  "Color used to display the error dot."
  :group 'flycheck-colored-status)

(defface flycheck-colored-status-warning '((t (:inherit flycheck-error-list-warning)))
  "Color used to display the warning dot."
  :group 'flycheck-colored-status)

(defface flycheck-colored-status-info '((t (:inherit flycheck-error-list-info)))
  "Color used to display the info dot."
  :group 'flycheck-colored-status)

(defun flycheck-colored-status--color-for (level)
  "Return the color for the given LEVEL."
  (cond
   ((eq 'error level) 'flycheck-colored-status-error)
   ((eq 'warning level) 'flycheck-colored-status-warning)
   ((eq 'info level) 'flycheck-colored-status-info)
   (t 'default)))

(defun flycheck-colored-status-for-level (error-counts level)
  "Format status indicator for ERROR-COUNTS messages at a specific LEVEL.

If the count in ERROR-COUNTS for LEVEL is 0, return
nil.  Otherwise, return a dot followed by the count, propertized
with the color for LEVEL."
  (let ((count (alist-get level error-counts))
	(color (flycheck-colored-status--color-for level)))
    (when count
      (propertize
       (concat flycheck-colored-status-indicator (number-to-string count))
       'face color))))

(defun flycheck-colored-status-mode-line-status-text (&optional status)
  "Return a text using colored dots to describe STATUS for use in the mode line.

STATUS defaults to `flycheck-last-status-change' if omitted or
nil.  This function is a drop-in replacement for the standard
flucheck function `flycheck-mode-line-status-text'."
  (let ((status (or status flycheck-last-status-change)))
    `(" "
      ,(if (eq 'finished status)
	   (if flycheck-current-errors
	       (let ((counts (flycheck-count-errors flycheck-current-errors)))
		 (cl-remove-if #'null
			       (mapcar (apply-partially #'flycheck-colored-status-for-level
							counts)
				       '(error warning info))))
	     flycheck-colored-status-indicator)
	 flycheck-colored-status-indicator))))

(defgroup flycheck-colored-status nil
  "Show Flycheck status using colored dots."
  :prefix "flycheck-colored-status-"
  :group 'flycheck
  :link '(url-link :tag "GitHub" "https://github.com/damiencollard/flycheck-colored-status"))

;;;###autoload
(define-minor-mode flycheck-colored-status-mode
  "Toggle Flycheck colored status mode.

Interactively with no argument, this command toggles the mode.  A
positive prefix argument enables the mode; any other prefix
argument disables it.

When enabled, this mode replaces the standard Flycheck mode line
status indicators with colored dots."
  :global t
  :require 'flycheck-colored-status
  (progn
    (setq flycheck-mode-line
	  (if flycheck-colored-status-mode
	      '(:eval (flycheck-colored-status-mode-line-status-text))
	    (eval (car (or (get 'flycheck-mode-line 'saved-value)
			   (get 'flycheck-mode-line 'standard-value))))))
    (force-mode-line-update t)))

(provide 'flycheck-colored-status)

;;; flycheck-colored-status.el ends here
