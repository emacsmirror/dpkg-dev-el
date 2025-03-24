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
