;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; UI

;; Keybindings
(map!
      ;; Easier window movement
      ;; :ni "C-h" #'evil-window-left
      ;; :ni "C-j" #'evil-window-down
      ;; :ni "C-k" #'evil-window-up
      ;; :ni "C-l" #'evil-window-right
      :leader
      (:prefix "w"
        :desc "Open new window" "n" #'evil-window-vnew))

;; org-mode
(setq org-directory "~/org/"
      org-ellipsis " ▼ "
      ;; org-ellipsis " ▾ "
      org-bullets-bullet-list '("#")
      org-startup-indented t
      org-startup-with-inline-images t
      org-agenda-files (quote ("~/org/tasks.org" "~/org/journal.org"))
      org-agenda-skip-scheduled-if-done t
      org-agenda-files (ignore-errors (directory-files +org-dir t "\\.org$" t))
      +org-capture-todo-file "tasks.org"
      org-use-property-inheritance t
      org-log-done 'time)

(global-emojify-mode)
(display-time-mode)
(display-battery-mode)

(after! org
  (set-face-attribute 'outline-1 nil :background nil) ; remove background from org-level-1 headers
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-agenda-custom-commands
        '(("A" "Agenda and all TODOs"
           ((agenda #1="")
            (todo "TODO"))
           ((org-agenda-start-with-log-mode '(closed clock state))
            (org-agenda-archives-mode t)))))
  (add-to-list 'org-capture-templates
               '("td" "Todo" entry
                 (file+headline "~/org/tasks.org")
                 "* THEN %?\n %U"
                 :empty-lines 0))
  (add-to-list 'org-capture-templates
               '("wt" "Work item" entry
                 (file+headline "~/org/tasks.org" "Next")
                 "* THEN %?\n %U"
                 :empty-lines 0))
  (add-to-list 'org-capture-templates
               '("j" "Journal" entry
                 (file+olp+datetree "~/org/journal.org")
                 "* %?\n %T"
                 :empty-lines 0))
  (add-to-list 'org-capture-templates
               '("d" "DONE" entry
                 (file+olp+datetree "~/org/journal.org")
                 "* DONE %?\n %T"
                 :empty-lines 0)))

;; Other settings
(after! projectile
  (projectile-add-known-project "/mnt/c/cats")
  (projectile-add-known-project "~/org"))

(setq
  blink-cursor-mode t
  projectile-project-search-path '("~/git/")
  display-line-numbers-type 'relative)

(defun exwm-config-custom ()
  "Default configuration of EXWM. But customized slightly."
  ;; Set the initial workspace number.
  (unless (get 'exwm-workspace-number 'saved-value)
    (setq exwm-workspace-number 4))
  ;; Make class name the buffer name
  (add-hook 'exwm-update-class-hook
            (lambda ()
              (exwm-workspace-rename-buffer exwm-class-name)))
  ;; Global keybindings.
  (unless (get 'exwm-input-global-keys 'saved-value)
    (setq exwm-input-global-keys
          `(
            ;; 's-r': Reset (to line-mode).
            ([?\M-y] . evil-move-divider-to-left)
            ;; 's-r': Reset (to line-mode).
            ([?\M-o] . evil-move-divider-to-right)
            ;; 's-r': Reset (to line-mode).
            ([?\s-r] . exwm-reset)
            ;; 's-w': Switch workspace.
            ([?\s-w] . exwm-workspace-switch)
            ;; 's-&': Launch application.
            ([?\s-&] . (lambda (command)
                         (interactive (list (read-shell-command "$ ")))
                         (start-process-shell-command command nil command)))
            ;; 's-N': Switch to certain workspace.
            ,@(mapcar (lambda (i)
                        `(,(kbd (format "s-%d" (+ 1 i))) .
                          (lambda ()
                            (interactive)
                            (+workspace/switch-to ,i))))
                      (number-sequence 0 8)))))
  ;; Line-editing shortcuts
  (unless (get 'exwm-input-simulation-keys 'saved-value)
    (setq exwm-input-simulation-keys
          '(([?\C-b] . [left])
            ([?\C-f] . [right])
            ([?\C-p] . [up])
            ([?\C-n] . [down])
            ([?\C-a] . [home])
            ([?\C-e] . [end])
            ([?\M-v] . [prior])
            ([?\C-v] . [next])
            ([?\C-d] . [delete])
            ([?\C-k] . [S-end delete]))))
  ;; Enable EXWM
  (exwm-enable)
  (exwm-init)
  ;; Other configurations
  (exwm-config-misc))

(after! exwm
  (require 'exwm-config)

  (exwm-config-custom)
  (exwm-input-set-key (kbd "M-h") #'evil-window-left)
  (exwm-input-set-key (kbd "M-j") #'evil-window-down)
  (exwm-input-set-key (kbd "M-k") #'evil-window-up )
  (exwm-input-set-key (kbd "M-l") #'evil-window-right)
  (exwm-input-set-key (kbd "M-u") #'evil-window-decrease-height)
  (exwm-input-set-key (kbd "M-i") #'evil-window-increase-height)
  (exwm-input-set-key (kbd "M-SPC") #'counsel-linux-app)
  (exwm-input-set-key (kbd "M-f") #'doom/window-maximize-buffer)
  (exwm-input-set-key (kbd "M-RET") #'eshell-toggle) ; Currently not working
  (exwm-input-set-key (kbd "M-b") #'exwm-workspace-switch-to-buffer)
  (evil-set-initial-state 'exwm-mode 'normal)

  ;; in normal state/line mode, use the familiar i key to switch to input state
  ;; from https://github.com/timor/spacemacsOS/blob/master/packages.el#L152
  (evil-define-key 'normal exwm-mode-map (kbd "i") 'exwm-input-release-keyboard)
  (push ?\i exwm-input-prefix-keys)
  (push ?\  exwm-input-prefix-keys))

(defun spacemacs/exwm-switch-to-buffer-or-run (window-class command)
  "Switch to first buffer with window-class, and if not present, run command."
  (let ((buffer
         (find window-class (buffer-list) :key (lambda(b) (cdr (assoc 'exwm-class-name (buffer-local-variables b)))) :test 'string-equal)))
    (if buffer
        (exwm-workspace-switch-to-buffer buffer)
      (start-process-shell-command command nil command))))

(defun spacemacs/exwm-bind-switch-to-or-run-command (key window-class command)
  (exwm-input-set-key (kbd key)
                      `(lambda ()
                         (interactive)
                         (spacemacs/exwm-switch-to-buffer-or-run ,window-class ,command))))

(spacemacs/exwm-bind-switch-to-or-run-command "s-f" "Firefox" "firefox")

;; turn off display-line-numbers in org-mode
(add-hook 'org-mode-hook #'doom-disable-line-numbers-h)

(after! ivy-posframe
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (setq ivy-posframe-parameters '((parent-frame nil)))
  (ivy-posframe-mode))

(add-hook 'exwm-mode-hook #'doom-mark-buffer-as-real-h)

(defun evil-move-divider-to-left ()
  "Move divider to the left."
  (interactive)
  (let ((left (car (window-edges)))
        (right (car (cdr (cdr (window-edges))))))
    (if (= left 0)
        (evil-window-decrease-width 10)
      (if (= right 213)
          (progn
            (other-window -1)
            (evil-window-decrease-width 10)
            (other-window 1))
        (evil-window-decrease-width 10)))))

(defun evil-move-divider-to-right ()
  "Move divider to the right."
  (interactive)
  (let ((left (car (window-edges)))
        (right (car (cdr (cdr (window-edges))))))
    (if (= left 0)
        (evil-window-increase-width 10)
      (if (= right 213)
          (evil-window-decrease-width 10)
        (progn
          (other-window 1)
          (evil-window-decrease-width 10)
          (other-window -1))))))

; The list returned has the form (LEFT TOP RIGHT BOTTOM).

(defun evil-move-divider-to-up ()
  "Move divider to the top."
  (interactive)
  (let ((top (car (cdr (window-edges))))
        (bottom (car (cdr (cdr (cdr (window-edges)))))))
    (if (= top 0)
        (evil-window-decrease-height 10)
      (if (= bottom 59)
          (progn
            (other-window -1)
            (evil-window-decrease-height 10)
            (other-window 1))
        (evil-window-decrease-height 10)))))

(defun evil-move-divider-to-down ()
  "Move divider to the bottom."
  (interactive)
  (let ((top (car (cdr (window-edges))))
        (bottom (car (cdr (cdr (cdr (window-edges)))))))
    (if (= top 0)
        (evil-window-increase-height 10)
      (if (= bottom 59)
          (evil-window-decrease-height 10)
        (progn
          (other-window 1)
          (evil-window-decrease-height 10)
          (other-window -1))))))

(defun sync-notes ()
  "Sync notes, with the bash script."
  (interactive)
  (require 'core-cli)
  (compile "sync-notes")
  (while compilation-in-progress
    (sit-for 1))
  (other-popup)
  (+popup/close)
  (message "Sync finished!"))

(defun org-counsel-goto-and-narrow ()
  "Go to a heading and narrow to it."
  (interactive)
  (counsel-org-goto)
  (org-narrow-to-subtree))

(load! "config-mu4e")

;; JavaScript and TypeScript configuration

;; LSP requirements on the server
;; sudo npm i -g typescript-language-server; sudo npm i -g typescript
;; sudo npm i -g javascript-typescript-langserver
(setq lsp-prefer-flymake nil)

(after! lsp-mode
  (add-hook 'js2-mode-hook 'lsp)
  (add-hook 'php-mode 'lsp)
  (add-hook 'css-mode 'lsp)
  (add-hook 'web-mode 'lsp))

(setq lsp-language-id-configuration '((python-mode . "python")
                                      (css-mode . "css")
                                      (web-mode . "html")
                                      (html-mode . "html")
                                      (json-mode . "json")
                                      (js2-mode . "javascript")))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-hook 'js2-mode-hook #'setup-tide-mode)
