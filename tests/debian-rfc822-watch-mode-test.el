(require 'debian-rfc822-watch-mode)
(require 'ert)
(require 'faceup)

(defvar debian-rfc822-watch-mode-font-lock-test-dir
  (faceup-this-file-directory))

(defun debian-rfc822-watch-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file
   'debian-rfc822-watch-mode
   (concat debian-rfc822-watch-mode-font-lock-test-dir file)))
(faceup-defexplainer debian-rfc822-watch-mode-font-lock-test-apps)

(ert-deftest debian-rfc822-watch-mode-font-test ()
  "faceup tests for debian-rfc822-watch-mode."
  (should (debian-rfc822-watch-mode-font-lock-test-apps
           "faceup/debian-rfc822-watch-mode/example-watch")))
