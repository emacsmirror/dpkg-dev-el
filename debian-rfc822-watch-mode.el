;;; debian-rfc822-watch-mode.el --- Major mode for rfc822-style Debian watch files -*- lexical-binding: t -*-

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

;; debian-rfc822-watch-mode will automatically activate when editing
;; files named debian/watch.  This mode can be customised from the group
;; tools -> debian-rfc822-watch-mode, or directly from the
;; debian-rfc822-watch-mode group.

;;; Code:

(require 'debian-rfc822-mode)

;;;###autoload
(define-derived-mode debian-rfc822-watch-mode debian-rfc822-mode
  "Debian rfc822 watch"
  (setq-local debian-rfc822-mode-field-spec
              '(("Bare")
                ("Component")
                ("Compression")
                ("Ctype")
                ("Date")
                ("Decompress" . ("yes"))
                ("Download-Url-Mangle")
                ("Dversion-Mangle")
                ("Dirversion-Mangle")
                ("Filename-Mangle")
                ("Git-Export")
                ("Git-Mode" . ("shallow"
                               "full"))
                ("Git-Modules" . ("all"))
                ("Matching-Pattern" . ("HEAD"))
                ("Mode" . ("LWP"
                           "git"
                           "svn"))
                ("Oversion-Mangle")
                ("Page-Mangle")
                ("Pgp-Mode" . ("auto"
                               "default"
                               "gittag"
                               "mangle"
                               "next"
                               "none"
                               "previous"
                               "self"))
                ("Pgp-Sig-Url-Mangle")
                ("Pretty")
                ("Repacksuffix")
                ("Repack")
                ("Search-Mode" . ("html"
                                  "plain"))
                ("Source")
                ("Template")
                ("User-Agent")
                ("Uversion-Mangle")
                ("Version")
                ("Version-Constraint" . ("same"))
                ("Version-Mangle")
                ("Version-Separator")
                ("Version-Schema" . ("previous"
                                     "group"
                                     "checksum"))))

  (setq-local debian-rfc822-mode-variable-spec
              '("ANY_VERSION"
                "ARCHIVE_EXT"
                "COMPONENT"
                "DEB_EXT"
                "PACKAGE"
                "SEMANTIC_VERSION"
                "SIGNATURE_EXT"
                "STABLE_VERSION"))

  (debian-rfc822-mode-set-font-lock-defaults))

;;;###autoload
(add-to-list 'auto-mode-alist
             '("debian/watch\\'" . debian-rfc822-watch-mode))

(provide 'debian-rfc822-watch-mode)

;;; debian-rfc822-watch-mode.el ends here
