;; routines to highlight README.Debian file.
;; Copyright 2002 Junichi Uekawa.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; debian-changelog-mode.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with your Debian installation, in /usr/share/common-licenses/GPL
;; If not, write to the Free Software Foundation, 675 Mass Ave,
;; Cambridge, MA 02139, USA.

;; things nicked off debian-changelog-mode.
(defvar readme-debian-changelog-full-name (or (getenv "DEBFULLNAME")
				       (user-full-name))
  "*Full name of user, for inclusion in Debian changelog headers.
This defaults to the contents of environment variable DEBFULLNAME
or else to the value returned by the `user-full-name' function.")
(defvar readme-debian-mailing-address 
  (or (getenv "DEBEMAIL")
      (getenv "EMAIL")
      (and (boundp 'user-mail-address) user-mail-address)
      (and (fboundp 'user-mail-address) (user-mail-address)))
  "*Electronic mail address of user, for inclusion in Debian changelog headers.
This defaults to the value of (in order of precedence):
 Contents of environment variable DEBEMAIL,
 Contents of environment variable EMAIL,
 Value of `user-mail-address' variable,
 Value returned by the `user-mail-address' function.")

(add-to-list 'auto-mode-alist '("debian/README.Debian$" . readme-debian-mode))
(add-to-list 'auto-mode-alist '("^/usr/share/doc/.*/README.Debian.*$" . readme-debian-mode))


(defun readme-debian-update-timestamp ()
  "Function to update timestamp in README.Debian files, automatically invoked when saving file"
  (save-excursion
    (goto-line 1)
    (re-search-forward "^ -- ")
    (delete-region (progn (beginning-of-line) (point)) (progn (end-of-line) (point)))
    (insert (concat 
	     " -- "
	     readme-debian-changelog-full-name
	     " <" readme-debian-mailing-address ">, "
	     (current-time-string)))))

(defun readme-debian-mode ()
  "Mode to edit README.Debian"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'readme-debian-mode)
  (setq mode-name "README.Debian")
  (mapcar 'make-local-variable '(font-lock-defaults write-file-hooks))
  (use-local-map readme-debian-mode-map)
  (set-syntax-table readme-debian-mode-syntax-table)
  (setq font-lock-defaults 
	'(
					;keywords start here
	  (("^\\(.*\\) for \\(Debian\\)$" (1 font-lock-keyword-face) (2 font-lock-string-face))
	   ("^[-=]+$" . font-lock-warning-face)
	   ("^ -- \\([^<]*\\)\\(<[^>]*>\\), \\(.*\\)$" (1 font-lock-keyword-face) (2 font-lock-warning-face) (3 font-lock-string-face))
	   )
	  nil		;keywords-only
	  nil		;case-fold
	  ()		;syntax-alist
	  ))
  (add-to-list 'write-file-hooks 'readme-debian-update-timestamp) ; add timestamp update func to write-file-hook
  (run-hooks 'readme-debian-mode-hook)
  )

(defvar readme-debian-mode-map nil "keymap for README.Debian mode")
(defvar readme-debian-mode-syntax-table nil "syntax table for README.Debian mode")
(if readme-debian-mode-syntax-table
         ()              ; Do not change the table if it is already set up.
       (setq readme-debian-mode-syntax-table (make-syntax-table))
       (modify-syntax-entry ?\" ".   " text-mode-syntax-table)
       (modify-syntax-entry ?\\ ".   " text-mode-syntax-table)
       (modify-syntax-entry ?' "w   " text-mode-syntax-table))
