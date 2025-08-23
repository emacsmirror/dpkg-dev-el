;;; dpkg-dev-common-utils.el --- Common utilities for dpkg-dev-el. -*- lexical-binding: t -*-

;; Copyright: 2025 Debian Emacsen Team <debian-emacsen@lists.debian.org>

;; Author: Xiyue Deng <manphiz@gmail.com>

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with your Debian installation, in /usr/share/common-licenses/GPL.

;;; Commentary:

;; This file contains utility functions that are useful for other files.

;;; Code:

(defun dpkg-dev-common-utils--add-debputy-settings ()
  "Add debputy settings to eglot if it is available."
  (when (fboundp 'eglot)
    (require 'eglot)
    (add-to-list 'eglot-server-programs
                 `(((debian-autopkgtest-control-mode
                     :language-id "debian/tests/control")
                    (debian-control-mode :language-id "debian/control")
                    (debian-changelog-mode :language-id "debian/changelog")
                    (debian-copyright-mode :language-id "debian/copyright"))
                   "debputy" "lsp" "server"))))

(provide 'dpkg-dev-common-utils)

;;; dpkg-dev-el.el ends here
