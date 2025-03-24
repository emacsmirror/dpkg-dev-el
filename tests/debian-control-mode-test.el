(require 'debian-control-mode)
(require 'ert)
(require 'faceup)

(defvar debian-control-mode-font-lock-test-dir (faceup-this-file-directory))

(defun debian-control-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file 'debian-control-mode
                              (concat debian-control-mode-font-lock-test-dir
                                      file)))
(faceup-defexplainer debian-control-mode-font-lock-test-apps)

(ert-deftest debian-control-mode-font-test ()
  "faceup tests for debian-control-mode."
  (should (debian-control-mode-font-lock-test-apps
           "faceup/debian-control-mode/simple-control")))
