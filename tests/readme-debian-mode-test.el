;; -*- lexical-binding: t -*-

(require 'readme-debian)
(require 'ert)
(require 'faceup)

(defvar readme-debian-mode-font-lock-test-dir (faceup-this-file-directory))

(defun readme-debian-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file 'readme-debian-mode
                              (concat readme-debian-mode-font-lock-test-dir
                                      file)))
(faceup-defexplainer readme-debian-mode-font-lock-test-apps)

(ert-deftest readme-debian-mode-font-test ()
  "faceup tests for readme-debian-mode."
  (should (readme-debian-mode-font-lock-test-apps
           "faceup/readme-debian-mode/simple-readme-debian")))
