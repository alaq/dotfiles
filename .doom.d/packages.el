;; -*- no-byte-compile: t; -*-
;;; .doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)
(package! emojify)
(package! exwm)
(package! ivy-posframe)
(package! esh-autosuggest)
(package! org-mime)
(package! smtpmail)
(package! exwm-randr)
(package! org-roam
  :recipe (:host github :repo "jethrokuan/org-roam" :branch "develop"))
