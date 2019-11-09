;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; UI

;(setq doom-font (font-spec :family "Fira Code" :size 12)
;      doom-variable-pitch-font (font-spec :family "Noto Sans" :size 13))

;; Keybindings
(map!
      ;; Easier window movement
      :ni "C-h" #'evil-window-left
      :ni "C-j" #'evil-window-down
      :ni "C-k" #'evil-window-up
      :ni "C-l" #'evil-window-right)

;; org-mode
(setq org-directory "~/org/"
      org-ellipsis " ▼ "
      ;; org-ellipsis " ▾ "
      org-bullets-bullet-list '("#")
      org-startup-indented t
      org-startup-with-inline-images t
      ;; org-agenda-files (quote ("~/org/tasks.org" "~/org/journal.org"))
      org-agenda-skip-scheduled-if-done t
      org-agenda-files (ignore-errors (directory-files +org-dir t "\\.org$" t))
      +org-capture-todo-file "tasks.org"
      org-use-property-inheritance t
      org-log-done 'time)

(add-hook 'auto-save-hook 'org-save-all-org-buffers)

(after! org
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
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("wt" "Work item" entry
                 (file+headline "~/org/tasks.org" "Next")
                 "* THEN %?\n %U"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("j" "Journal" entry
                 (file+olp+datetree "~/org/journal.org")
                 "* %?\n %T"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("d" "DONE" entry
                 (file+olp+datetree "~/org/journal.org")
                 "* DONE %?\n %T"
                 :empty-lines 1)))

;; Other settings
(after! projectile
  (projectile-add-known-project "/mnt/c/cats")
  (projectile-add-known-project "~/org"))

(setq
  blink-cursor-mode t
  projectile-project-search-path '("~/git/")
  ;; doom-font (font-spec :family "SF Mono" :size 20)
  ;; doom-big-font (font-spec :family "SF Mono" :size 36)
  ;; doom-variable-pitch-font (font-spec :family "Avenir Next" :size 18)
  display-line-numbers-type 'relative)

;; External frame from ./module...

;;;###autoload
(defvar +org-capture-frame-parameters-temp
  `((name . "org-capture")
    (width . 70)
    (height . 50)
    (transient . t)
    ,(if IS-LINUX '(display . "172.25.112.1:0")))
  "TODO")

;;;###autoload
(defun +org-capture/open-frame-temp (&optional initial-input key)
  "Opens the org-capture window in a floating frame that cleans itself up once
you're done. This can be called from an external shell script."
  (interactive)
  (when (and initial-input (string-empty-p initial-input))
    (setq initial-input nil))
  (when (and key (string-empty-p key))
    (setq key nil))
  (let* ((frame-title-format "")
         (frame (if (+org-capture-frame-p)
                    (selected-frame)
                  (make-frame +org-capture-frame-parameters-temp))))
    (select-frame-set-input-focus frame)  ; fix MacOS not focusing new frames
    (with-selected-frame frame
      (require 'org-capture)
      (condition-case ex
          (cl-letf (((symbol-function #'pop-to-buffer)
                     (symbol-function #'switch-to-buffer)))
            (switch-to-buffer (doom-fallback-buffer))
            (let ((org-capture-initial initial-input)
                  org-capture-entry)
              (when (and key (not (string-empty-p key)))
                (setq org-capture-entry (org-capture-select-template key)))
              (if (or org-capture-entry
                      (not (fboundp 'counsel-org-capture)))
                  (org-capture)
                (unwind-protect
                    (counsel-org-capture)
                  (if-let* ((buf (cl-loop for buf in (buffer-list)
                                          if (buffer-local-value 'org-capture-mode buf)
                                          return buf)))
                      (with-current-buffer buf
                        (add-hook 'kill-buffer-hook #'+org-capture-cleanup-frame-h nil t))
                    (delete-frame frame))))))
        ('error
         (message "org-capture: %s" (error-message-string ex))
         (delete-frame frame))))))

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
            ([?\s-r] . exwm-reset)
            ;; 's-w': Switch workspace.
            ([?\s-w] . exwm-workspace-switch)
            ;; 's-&': Launch application.
            ([?\s-&] . (lambda (command)
                         (interactive (list (read-shell-command "$ ")))
                         (start-process-shell-command command nil command)))
            ;; 's-N': Switch to certain workspace.
            ,@(mapcar (lambda (i)
                        `(,(kbd (format "s-%d" i)) .
                          (lambda ()
                            (interactive)
                            (exwm-workspace-switch-create ,i))))
                      (number-sequence 0 9)))))
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
  ;; Configure Ido
  ;; (exwm-config-ido)
  ;; Other configurations
  (exwm-config-misc))

(after! exwm
  (require 'exwm-config)

  (exwm-config-custom)
  (exwm-input-set-key (kbd "M-h") #'evil-window-left)
  (exwm-input-set-key (kbd "M-j") #'evil-window-down)
  (exwm-input-set-key (kbd "M-k") #'evil-window-up )
  (exwm-input-set-key (kbd "M-l") #'evil-window-right)
  (exwm-input-set-key (kbd "M-RET") #'eshell-toggle) ; Currently not working
  (exwm-input-set-key (kbd "M-b") #'exwm-workspace-switch-to-buffer)
  (push ?\M-\  exwm-input-prefix-keys)
  (setq persp-init-frame-behaviour nil)

  ;; in normal state/line mode, use the familiar i key to switch to input state
  ;; from https://github.com/timor/spacemacsOS/blob/master/packages.el#L152
  (evil-define-key 'normal exwm-mode-map (kbd "i") 'exwm-input-release-keyboard)
  (push ?\i exwm-input-prefix-keys)

  ;; TODO make the below work for good buffer switching
  ;; (add-hook 'exwm-buffer-mode-hook #'doom-mark-buffer-as-real-h)
  )
