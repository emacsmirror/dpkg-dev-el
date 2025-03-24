(require 'debian-copyright)
(require 'ert)
(require 'faceup)

(defvar debian-copyright-mode-font-lock-test-dir (faceup-this-file-directory))

(defun debian-copyright-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file 'debian-copyright-mode
                              (concat debian-copyright-mode-font-lock-test-dir
                                      file)))
(faceup-defexplainer debian-copyright-mode-font-lock-test-apps)

(ert-deftest debian-copyright-mode-font-test ()
  "faceup tests for debian-copyright-mode."
  (should (debian-copyright-mode-font-lock-test-apps
           "faceup/debian-copyright-mode/simple-copyright")))
