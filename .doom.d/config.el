;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(setq org-startup-indented t)
(setq org-startup-with-inline-images t)

(add-hook 'auto-save-hook 'org-save-all-org-buffers)
(blink-cursor-mode t)

(setq org-agenda-files (quote ("~/org/tasks.org" "~/org/journal.org")))
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/tasks.org" "Next")
          "* THEN %?\n %U")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
          "* %?\n %T")
        ("d" "DONE" entry (file+datetree "~/org/journal.org")
          "* DONE %?\n %T")))

(setq org-bullets-bullet-list (quote ("◉" "○")))

(setq display-line-numbers-type 'relative)

(projectile-add-known-project "/mnt/c/cats")
(projectile-add-known-project "~/org")
