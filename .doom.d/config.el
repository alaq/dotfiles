;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; UI

;; Keybindings
(map!
      ;; Easier window movement
      :ni "C-h" #'evil-window-left
      :ni "C-j" #'evil-window-down
      :ni "C-k" #'evil-window-up
      :ni "C-l" #'evil-window-right
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
      ;; org-agenda-files (quote ("~/org/tasks.org" "~/org/journal.org"))
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
  (exwm-input-set-key (kbd "M-y") #'evil-move-divider-to-left)
  (exwm-input-set-key (kbd "M-u") #'evil-window-decrease-height)
  (exwm-input-set-key (kbd "M-i") #'evil-window-increase-height)
  (exwm-input-set-key (kbd "M-o") #'evil-move-divider-to-right)
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
        (progn
          (message "decreasing width")
          (evil-window-decrease-width 10))
      (if (= right 213)
          (progn
            (message "decreasing other window")
            (other-window -1)
            (evil-window-decrease-width 10)
            (other-window 1))
        (progn
          (message "increasing window")
          (other-window -1)
          (evil-window-decrease-width 10)
          (other-window 1))))))

(defun evil-move-divider-to-right ()
  "Move divider to the right."
  (interactive)
  (let ((left (car (window-edges)))
        (right (car (cdr (cdr (window-edges))))))
    (message "%s" left)
    (message "%s" right)
    (if (= left 0)
        (progn
          (message "increase width")
          (evil-window-increase-width 10))
      (if (= right 213)
          (progn
            (message "decrease width")
            (evil-window-decrease-width 10))
        (progn
          (message "decrease other window's width")
          (other-window 1)
          (evil-window-decrease-width 10)
          (other-window -1))))))
