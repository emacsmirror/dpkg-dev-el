;;; debian-copyright.el --- Major mode for Debian package copyright files

;; Copyright 2002, 2003 Junichi Uekawa.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; debian-copyright.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with your Debian installation, in /usr/share/common-licenses/GPL
;; If not, write to the Free Software Foundation, 675 Mass Ave,
;; Cambridge, MA 02139, USA.


(require 'debian-changelog-mode)

;;; Code:
(add-to-list 'auto-mode-alist '("debian/copyright$" . debian-copyright-mode))
(add-to-list 'auto-mode-alist '("^/usr/share/doc/.*/copyright" . debian-copyright-mode))

(defgroup debian-copyright nil "Debian copyright mode"
  :group 'tools
  :prefix "debian-copyright-")

(defcustom debian-copyright-mode-load-hook nil
  "*Hooks that are run when `debian-copyright-mode' is loaded."
  :group 'debian-copyright
  :type 'hook)
  
(defcustom debian-copyright-mode-hook nil
  "Normal hook run when entering Debian Copyright mode."
  :group 'debian-copyright
  :type 'hook
  :options '(turn-on-auto-fill flyspell-mode))

(defconst debian-copyright-mode-version "$Id$" "Version of debian copyright mode.")

(defvar debian-copyright-mode-map nil
  "Keymap for debian/copyright mode.")
(defvar debian-copyright-mode-syntax-table nil
  "Syntax table for debian/copyright mode.")

(if debian-copyright-mode-syntax-table
         ()              ; Do not change the table if it is already set up.
       (setq debian-copyright-mode-syntax-table (make-syntax-table))
       (modify-syntax-entry ?\" ".   " debian-copyright-mode-syntax-table)
       (modify-syntax-entry ?\\ ".   " debian-copyright-mode-syntax-table)
       (modify-syntax-entry ?' "w   " debian-copyright-mode-syntax-table))

(defun debian-copyright-mode ()
  "Mode to edit and read debian/copyright.
\\{debian-copyright-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'debian-copyright-mode)
  (setq mode-name "debian/copyright")
  (mapcar 'make-local-variable '(font-lock-defaults write-file-hooks))
  (use-local-map debian-copyright-mode-map)
  (set-syntax-table debian-copyright-mode-syntax-table)
  (if (not (featurep 'browse-url))
      (setq font-lock-defaults
            '((("http:.*$" . font-lock-function-name-face)
               ("ftp:.*$" . font-lock-function-name-face)
               ("^Copyright:$" . font-lock-keyword-face))
              nil		;keywords-only
              nil		;case-fold
              ()		;syntax-alist
              ))
    (setq font-lock-defaults
          '((("^Copyright:$" . font-lock-keyword-face))
            nil		;keywords-only
            nil		;case-fold
            ()		;syntax-alist
            ))
    (goto-address))
  (run-hooks 'debian-copyright-mode-hook))

(run-hooks 'debian-copyright-mode-load-hook)

(provide 'debian-copyright-mode)

(provide 'debian-copyright)

;;; debian-copyright.el ends here
