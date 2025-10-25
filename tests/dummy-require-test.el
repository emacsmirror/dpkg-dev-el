;; -*- lexical-binding: t -*-

(require 'debian-bts-control)
(require 'debian-changelog-mode)
(require 'debian-control-mode)
(require 'debian-copyright)
(require 'dpkg-dev-el)
(require 'readme-debian)

(ert-deftest dummy-require-test ()
  "A dummy test to ensure all add-ons are byte-compiled.

This helps catch bugs and dependency issues when developing
without real unit tests.  When real tests are available please
feel free to remove this one."
  t)
