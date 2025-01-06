(require 'debian-changelog-mode)

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
