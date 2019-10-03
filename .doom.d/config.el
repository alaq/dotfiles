;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(setq org-startup-indented t)
(setq org-startup-with-inline-images t)

(add-hook 'auto-save-hook 'org-save-all-org-buffers)
(blink-cursor-mode t)

(setq org-agenda-files (quote ("~/org/tasks.org" "~/org/journal.org")))

(after! org
  (add-to-list 'org-capture-templates
               '("td" "Todo" entry
                 (file+headline "~/org/tasks.org")
                 "* THEN %?\n %U"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("wt" "Work item" entry
                 (file+headline "~/org/tasks.org" "Next")
                 "* THEN %?\n %U"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("j" "Journal" entry
                 (file+datetree "~/org/journal.org")
                 "* %?\n %T"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("d" "DONE" entry
                 (file+datetree "~/org/journal.org")
                 "* DONE %?\n %T"
                 :empty-lines 1)))

(setq org-bullets-bullet-list (quote ("◉" "○")))

(setq display-line-numbers-type 'relative)


(projectile-add-known-project "/mnt/c/cats")
(projectile-add-known-project "~/org")
