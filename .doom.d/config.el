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
      org-log-done 'time)

(add-hook 'auto-save-hook 'org-save-all-org-buffers)

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

;; Other settings
(projectile-add-known-project "/mnt/c/cats")
(projectile-add-known-project "~/org")

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
