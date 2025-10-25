;;; debian-rfc822-mode.el --- Base major mode for rfc822 style files. -*- lexical-binding: t -*-

;; Copyright 2025 Xiyue Deng <manphiz@gmail.com>

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with your Debian installation, in /usr/share/common-licenses/GPL.

;;; Commentary:

;; debian-rfc822-mode provides a base mode for defining more specialized
;; rfc822-style modes.  The derived mode can update the spec variables
;; `debian-rfc822-mode-field-spec' and
;; `debian-rfc822-mode-variable-spec' for detecting mode specific field
;; and variable names.

;; The author learned many from debian-copyright.el by Junichi Uekawa
;; during the development.

;;; Code:

(require 'cl-lib)
(require 'dpkg-dev-common-utils)
(require 'regexp-opt)

(defgroup debian-rfc822-mode nil "Debian rfc822-style base mode"
  :group 'tools
  :prefix "debian-rfc822-mode-")

(defcustom debian-rfc822-mode-hook nil
  "Normal hook run when entering `debian-rfc822-mode'."
  :type 'hook
  :options '(turn-on-auto-fill flyspell-mode))

(defvar debian-rfc822-mode-map (make-sparse-keymap)
  "Keymap for debian-rfc822-mode.")

(defvar-local debian-rfc822-mode-field-spec nil
  "Keyword spec for debian-rfc822-mode.  This consists of a list
of '(\"field-name\" [. (\"sub-item1\" \"sub-item2\" ...)])', where each
string is a regexp.  The field-name are detected at the start of the
line and ends at `:'.  If any `sub-itemN' is present, they will be
highlighted if the current line starts with `field-name'.

A derived mode should customize this variable accordingly.")

(defvar-local debian-rfc822-mode-variable-spec nil
  "Variable spec for debian-rfc822-mode.  This should be a list of strings
and the corresponding substitute variables like `@string1@',
`@string2@', etc. will be highlighted.

A derived mode should customize this variable accordingly.")

(defvar debian-rfc822-mode--syntax-table
  (let ((table (make-syntax-table text-mode-syntax-table)))
    (modify-syntax-entry ?\" ".   " table)
    (modify-syntax-entry ?\\ ".   " table)
    (modify-syntax-entry ?'  "w   " table)
    table)
  "Syntax table for debian-rfc822-mode.")

(defvar debian-rfc822-mode--email-font-lock-spec
  '("<?\\([^<> \t\n]+@[^<> \t\n]+\\.[^<> \t\n]+\\)>?"
    (1 font-lock-variable-name-face))
  "The font lock spec for emails.")

(defvar debian-rfc822-mode--url-font-lock-spec
  (let* ((protocol-prefixes '("file:///"
                              "ftp://"
                              "git://"
                              "http://"
                              "https://"
                              "ssh://"
                              "svn://"
                              "mailto:"))
         (url-regexp (concat (regexp-opt protocol-prefixes)
                             "[^/ \t\n][^ \t\n]*")))
    `(,url-regexp . font-lock-constant-face))
  "The font lock spec for URLs.")

(defvar debian-rfc822-mode--comment-font-lock-spec
  '("^[[:space:]]*\\(#.*\\)$" (1 font-lock-comment-face))
  "The font lock spec for comments.")

(defun debian-rfc822-mode--field-font-lock-spec (field-spec)
  "Build a font lock spec based on FIELD-SPEC.
See debian-rfc822-mode-field-spec."
  (let (result)
    (dolist (field field-spec)
      (let* ((field-name (car field))
             (sub-items (cdr field))
             (field-name-regexp (concat "^" field-name ":"))
             (sub-items-spec
              (when sub-items
                (let ((sub-item-regexp
                       (concat "\\_<\\(" (regexp-opt sub-items) "\\)\\_>")))
                  `(,sub-item-regexp nil nil
                                     (1 font-lock-type-face))))))
        (if sub-items-spec
            (cl-pushnew `(,field-name-regexp
                          (0 font-lock-keyword-face)
                          ,sub-items-spec)
                        result)
          (cl-pushnew `(,field-name-regexp . font-lock-keyword-face)
                      result))))
    result))

(defun debian-rfc822-mode--variable-font-lock-spec (variable-spec)
  "Build a font lock spec for `@variable@' based on VARIABLE-SPEC.
See `debian-rfc822-mode-variable-spec'."
  (let ((variable-regexp
         (regexp-opt (mapcar (lambda (var)
                               (concat "@" var "@"))
                             variable-spec))))
    `(,variable-regexp . font-lock-variable-name-face)))

(defun debian-rfc822-mode--font-lock-keywords (fields variables)
  "Build font-lock-defaults based on FIELDS and VARIABLES."
  (let ((mode-font-lock-keywords `(,debian-rfc822-mode--url-font-lock-spec
                                   ,debian-rfc822-mode--email-font-lock-spec)))
    (when fields
      (dolist (spec (debian-rfc822-mode--field-font-lock-spec
                     fields))
        (cl-pushnew spec mode-font-lock-keywords)))

    ;; Make variable higher priority than email and URL so that it takes
    ;; priority.
    (when variables
      (cl-pushnew (debian-rfc822-mode--variable-font-lock-spec
                   variables)
                  mode-font-lock-keywords))

    ;; Ensure that comment is the top one on the font-lock-keywords so that it
    ;; takes the highest priority.
    (cl-pushnew debian-rfc822-mode--comment-font-lock-spec
                mode-font-lock-keywords)
    mode-font-lock-keywords))

(defun debian-rfc822-mode-set-font-lock-defaults (&optional more-spec)
  "Set font-lock-defaults based on the buffer local customization.
A derived mode should customize `debian-rfc822-mode-font-field-spec' and
`debian-rfc822-mode-variable-spec' for highlighting.  When needed,
MORE-SPEC can be used to specify additional highlighting customization."
  (setq-local font-lock-defaults
              `(;; keywords
                ,(let ((mode-font-lock-keywords
                        (debian-rfc822-mode--font-lock-keywords
                         debian-rfc822-mode-field-spec
                         debian-rfc822-mode-variable-spec)))
                   (when more-spec
                     (nconc 'mode-font-lock-keywords 'more-spec))
                   mode-font-lock-keywords)
                ;; keywords-only
                nil
                ;; case-fold
                nil
                ;; syntax-alist
                nil)))

(define-derived-mode debian-rfc822-mode text-mode "Debian rfc822-style mode"
  "Mode for rfc822-style Debian configuration files.
This should be the parent-mode for a more specific rfc822-style mode.  A
derived mode should update the buffer local variables
`debian-rfc822-mode-field-spec' and `debian-rfc822-mode-variable-spec'
according to the mode's specific usage to enable better highlighting.
Note that you also need to
call `(debian-rfc822-mode-set-font-lock-defaults)' explicitly in
`define-derived-mode' to let it take effect."
  (set-syntax-table debian-rfc822-mode--syntax-table)
  ;; Comments
  (setq-local comment-start-skip "#+ *")
  (setq-local comment-start "#")
  (setq-local comment-end "")

  (dpkg-dev-common-utils--add-debputy-settings))

(provide 'debian-rfc822-mode)

;;; debian-rfc822-mode.el ends here
