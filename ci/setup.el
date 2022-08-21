;; Evaluate this file to set-up emacs in CI for building slides

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)
(package-refresh-contents)

(setq package-selected-packages
      '(org-mode
        ox-reveal
        htmlize))

(package-install-selected-packages)
(save-buffers-kill-emacs)
