;;; debian-autopkgtest-control-mode.el --- Major mode for Debian package autopkgtest control files -*- lexical-binding: t -*-

;; Copyright 2024 Xiyue Deng <manphiz@gmail.com>

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

;; debian-autopkgtest-control-mode will automatically activate when
;; editing files named debian/tests/control.  This mode can be
;; customised from the group tools -> debian-autopkgtest-control-mode,
;; or directly from the debian-autopkgtest-control-mode group.

;; The author learned many from debian-copyright.el by Junichi Uekawa
;; during the development.

;;; Code:

(require 'debian-rfc822-mode)

(define-derived-mode debian-autopkgtest-control-mode debian-rfc822-mode
  "Debian autopkgtest control mode"
  (setq-local debian-rfc822-mode-field-spec
              '(("Architecture")
                ("Classes")
                ("Depends")
                ("Features")
                ("Restrictions" . ("allow-stderr"
                                   "breaks-testbed"
                                   "build-needed"
                                   "flaky"
                                   "hint-testsuite-triggers"
                                   "isolation-container"
                                   "isolation-machine"
                                   "needs-internet"
                                   "needs-reboot"
                                   "needs-recommends"  ;; deprecated
                                   "needs-root"
                                   "needs-sudo"
                                   "rw-build-tree"
                                   "skip-not-installable"
                                   "skippable"
                                   "superficial"))
                ("Test-Command")
                ("Tests")
                ("Tests-Directory")))
  (setq-local debian-rfc822-mode-variable-spec
              '("builddeps"
                "recommends"))
  (debian-rfc822-set-font-lock-defaults))

;;;###autoload
(add-to-list 'auto-mode-alist
             '("debian/tests/control\\'" . debian-autopkgtest-control-mode))

(provide 'debian-autopkgtest-control-mode)

;;; debian-autopkgtest-control-mode.el ends here
