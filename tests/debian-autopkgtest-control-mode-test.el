(require 'debian-autopkgtest-control-mode)
(require 'ert)
(require 'faceup)

(defvar debian-autopkgtest-control-mode-font-lock-test-dir
  (faceup-this-file-directory))

(defun debian-autopkgtest-control-mode-font-lock-test-apps (file)
  "Test FILE is fontified as the corresponding .facup file describes."
  (faceup-test-font-lock-file
   'debian-autopkgtest-control-mode
   (concat debian-autopkgtest-control-mode-font-lock-test-dir file)))
(faceup-defexplainer debian-autopkgtest-control-mode-font-lock-test-apps)

(ert-deftest debian-autopkgtest-control-mode-font-test ()
  "faceup tests for debian-autopkgtest-control-mode."
  (should (debian-autopkgtest-control-mode-font-lock-test-apps
           "faceup/debian-autopkgtest-control-mode/simple-control")))
