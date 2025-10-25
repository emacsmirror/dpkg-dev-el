;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'debian-changelog-mode)
(require 'ert)
(require 'faceup)

(defvar debian-changelog-mode-font-lock-test-dir (faceup-this-file-directory))

(defun debian-changelog-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file 'debian-changelog-mode
                              (concat debian-changelog-mode-font-lock-test-dir
                                      file)))
(faceup-defexplainer debian-changelog-mode-font-lock-test-apps)

(ert-deftest debian-changelog-mode-font-test ()
  "faceup tests for debian-changelog-mode."
  (should (debian-changelog-mode-font-lock-test-apps
           "faceup/debian-changelog-mode/simple-changelog")))

(ert-deftest debian-changelog-mode-fill-paragraph-test ()
  "Test reflowing a debian changelog file with erts files."
  (ert-test-erts-file "tests/erts/debian-changelog-mode.erts"
                      (lambda ()
                        ;; fill-paragraph currently doesn't work on the
                        ;; timestamp line, so need to skip that part when
                        ;; setting marked regions.
                        (let ((end-point (save-excursion
                                           (goto-char (point-max))
                                           (forward-line -2)
                                           (point))))
                          (debian-changelog-mode)
                          (fill-region (point-min) end-point)))))

(ert-deftest debian-changelog-mode-verify-values-from-debian-distro-info ()
  "Verify that the values from debian-distro-info is consistent with local values."
  (skip-unless (executable-find "debian-distro-info"))
  (should (cl-subsetp
           debian-changelog--allowed-debian-distributions-from-distro-info
           debian-changelog--allowed-debian-distributions))
  (should (cl-subsetp
           debian-changelog--debian-code-names-from-distro-info
           debian-changelog-debian-code-names)))

(ert-deftest debian-changelog-mode-verify-values-from-ubuntu-distro-info ()
  "Verify that the values from ubuntu-distro-info is consistent with local values."
  (skip-unless (executable-find "ubuntu-distro-info"))
  (should (cl-subsetp
           debian-changelog--allowed-ubuntu-distributions-from-distro-info
           debian-changelog--allowed-ubuntu-distributions))
  (should (cl-subsetp
           debian-changelog--ubuntu-code-names-from-distro-info
           debian-changelog-ubuntu-code-names)))
