;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; UI

;; Keybindings
(map!
      :leader
      (:prefix "w"
        :desc "Open new window" "n" #'evil-window-vnew))

;; org-mode
(setq org-directory "~/org/"
      org-ellipsis " ▼ "
      ;; org-ellipsis " ▾ "
      ;; org-bullets-bullet-list '("#")
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
               '("td" "Task" entry
                 (file "~/org/tasks.org")
                 "* %?\n %T"
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
    (setq exwm-workspace-number 2))
  ;; Make class name the buffer name
  (add-hook 'exwm-update-class-hook
            (lambda ()
              (exwm-workspace-rename-buffer exwm-class-name)))

  ;; Multiple monitor setup
  (require 'exwm-randr)
  (setq exwm-randr-workspace-monitor-plist '(1 "DP2-3" 2 "eDP1"))
  (add-hook 'exwm-randr-screen-change-hook
            (lambda ()
              (start-process-shell-command
               "xrandr" nil "xrandr --output DP2-3 --above eDP1 --auto")))
  (message "Enabling multiple monitors!")
  (exwm-randr-enable)

  ;; Global keybindings.
  (unless (get 'exwm-input-global-keys 'saved-value)
    (setq exwm-input-global-keys
          `(
            ([?\M-i] . evil-move-divider-to-up)
            ([?\M-u] . evil-move-divider-to-down)
            ([?\M-y] . evil-move-divider-to-left)
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

(require 'exwm)
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

(defun sync-git-notes ()
  "Sync notes, via git, with the bash script."
  (interactive)
  (require 'core-cli)
  (compile "sync-git-notes")
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

(load! "mu4e" nil t)

;; JavaScript and TypeScript configuration

;; LSP requirements on the server
;; sudo npm i -g typescript-language-server; sudo npm i -g typescript
;; sudo npm i -g javascript-typescript-langserver
;; (setq lsp-prefer-flymake nil)

;; (require 'lsp-mode)
;; (after! lsp-mode
;;   (add-hook 'js2-mode-hook 'lsp)
;;   (add-hook 'php-mode 'lsp)
;;   (add-hook 'css-mode 'lsp)
;;   (add-hook 'web-mode 'lsp))

;; (setq lsp-language-id-configuration '((python-mode . "python")
;;                                       (css-mode . "css")
;;                                       (web-mode . "html")
;;                                       (html-mode . "html")
;;                                       (json-mode . "json")
;;                                       (js2-mode . "javascript")))

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

;; For Persp + EXWM compatibility
;; Source: https://www.reddit.com/r/emacs/comments/d8cd1h/a_simple_hack_for_persp_exwm_compatibility/
(defun exwm--update-utf8-title-advice (oldfun id &optional force)
"Only update the exwm-title when the buffer is visible."
  (when (get-buffer-window (exwm--id->buffer id))
    (funcall oldfun id force)))
(advice-add #'exwm--update-utf8-title :around #'exwm--update-utf8-title-advice)


(defun exwm-swap-monitors ()
  "Swaps your workspaces, between two monitors."
  (interactive)
  (exwm-workspace-swap 1 2))

(defun exwm-switch-to-monitors ()
  "Swaps your workspaces, between two monitors."
  (interactive)
  (exwm-workspace-switch 1))

(defun exwm-workspace-next (&optional reverse)
  (interactive "P")
  (let ((fn (if reverse #'- #'+)))
    (exwm-workspace-switch (mod (apply fn (list 1 exwm-workspace-current-index))
                                (- (length (frame-list)) 1)))))
(exwm-input-set-key (kbd "s-j") 'exwm-workspace-next)

(defun my/get-links-to-current-heading ()
  (interactive)
  (let ((title (nth 4 (org-heading-components))))
    (occur (concat "\\[\\[" title "\\]\\["))))

(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam)
  :init
  (setq org-roam-directory "~/org/")
  (map! :leader
        :prefix "n"
        :desc "Org-Roam-Insert" "i" #'org-roam-insert
        :desc "Org-Roam-Find"   "/" #'org-roam-find-file
        :desc "Org-Roam-Buffer" "r" #'org-roam)
  :config
  (org-roam-mode +1))

(defun my/org-roam--backlinks-list (file)
  (if (org-roam--org-roam-file-p file)
      (--reduce-from
       (concat acc (format "- [[file:%s][%s]]\n"
                           (file-relative-name (car it) org-roam-directory)
                                 (org-roam--get-title-or-slug (car it))))
       "" (org-roam-sql [:select [file-from] :from file-links :where (= file-to $s1)] file))
    ""))

(defun my/org-export-preprocessor ()
  (interactive)
  (let ((links (my/org-roam--backlinks-list (buffer-file-name))))
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "\n* Backlinks\n") links)))))

(defun org-roam-write-backlinks-to-file (file-path)
  "Show the backlinks for given org file for file at `FILE-PATH'."
  ;; (org-roam--db-ensure-built)
  (let* ((source-org-roam-directory org-roam-directory))
    (find-file file-path)
    (goto-char (point-max))
    ;; (let ((buffer-title (org-roam--get-title-or-slug file-path)))
      ;; (with-current-buffer org-roam-buffer
        ;; When dir-locals.el is used to override org-roam-directory,
        ;; org-roam-buffer should have a different local org-roam-directory and
        ;; default-directory, as relative links are relative from the overridden
        ;; org-roam-directory.
        (setq-local org-roam-directory source-org-roam-directory)
        (setq-local default-directory source-org-roam-directory)
        ;; Locally overwrite the file opening function to re-use the
        ;; last window org-roam was called from
        ;; (setq-local
        ;;  org-link-frame-setup
        ;;  (cons '(file . org-roam--find-file) org-link-frame-setup))
        ;; (let ((inhibit-read-only t))
          ;; (erase-buffer)
          ;; (when (not (eq major-mode 'org-roam-backlinks-mode))
          ;;   (org-roam-backlinks-mode))
          (make-local-variable 'org-return-follows-link)
          (setq org-return-follows-link t)
          ;; (insert
          ;;  (propertize buffer-title 'font-lock-face 'org-document-title))
          (if-let* ((backlinks (org-roam--get-backlinks file-path))
                    (grouped-backlinks (--group-by (nth 0 it) backlinks)))
              (progn
                (insert (format "* %d Backlinks\n"
                                (length backlinks)))
                (dolist (group grouped-backlinks)
                  (let ((file-from (car group))
                        (bls (cdr group)))
                    (insert (format "** [[file:%s][%s]]\n"
                                    file-from
                                    (org-roam--get-title-or-slug file-from)))
                    (dolist (backlink bls)
                      (pcase-let ((`(,file-from ,file-to ,props) backlink))
                        (insert (propertize
                                 (s-trim (s-replace "\n" " "
                                                    (plist-get props :content)))
                                 'font-lock-face 'org-block
                                 'help-echo "mouse-1: visit backlinked note"
                                 'file-from file-from
                                 'file-from-point (plist-get props :point)))
                        (insert "\n\n"))))))
            (message "No backlink found"))
            ;; (insert "\n\n* No backlinks!"))
          (save-buffer)
          (kill-buffer)
          ;; )
        ;; (read-only-mode 1))
      ;; )
    ))

(defun my/write-org-roam-backlinks ()
  (interactive)
  (mapc #'org-roam-write-backlinks-to-file (directory-files-recursively org-roam-directory "\\.org$" nil)))

(defun my/clear-org-roam-backlinks ()
  (interactive)
  (mapc #'clear-backlinks-in-file (directory-files-recursively org-roam-directory "\\.org$" nil)))

(defun clear-backlinks-in-file (file-path)
  (find-file file-path)
  (goto-char (point-min))
  (condition-case nil
      (progn
        (search-forward "Backlinks\n" nil nil)
        (backward-char)
        (org-mark-subtree)
        (delete-region (region-beginning) (region-end))
        (save-buffer)
        (kill-buffer))
    (error nil)))

(defun update-backlinks ()
  (interactive)
  (progn
    (defun org-roam--extract-links (&optional file-path)
      "Extracts all link items within the current buffer.
Link items are of the form:
    [file-from file-to properties]
This is the format that emacsql expects when inserting into the database.
FILE-FROM is typically the buffer file path, but this may not exist, for example
in temp buffers.  In cases where this occurs, we do know the file path, and pass
it as FILE-PATH."
      (let ((file-path (or file-path
                           (file-truename (buffer-file-name)))))
        (org-element-map (org-element-parse-buffer) 'link
          (lambda (link)
            (let ((type (org-element-property :type link))
                  (path (concat org-roam-directory (org-element-property :path link) ".org"))
                  (start (org-element-property :begin link)))
              (when (and (string= type "fuzzy")
                         (org-roam--org-file-p path))
                (goto-char start)
                (let* ((element (org-element-at-point))
                       (begin (or (org-element-property :content-begin element)
                                  (org-element-property :begin element)))
                       (content (or (org-element-property :raw-value element)
                                    (buffer-substring
                                     begin
                                     (or (org-element-property :content-end element)
                                         (org-element-property :end element)))))
                       (content (string-trim content)))
                  (vector file-path
                          (file-truename (expand-file-name path (file-name-directory file-path)))
                          (list :content content :point begin)))))))))
    (org-roam) ; enable org-roam
    (org-roam-mode -1) ; disable the auto refresh of the database
    (my/clear-org-roam-backlinks)
    (org-roam-build-cache)
    (my/write-org-roam-backlinks)))

(defun clear-backlinks-in-this-file ()
  (interactive)
  (clear-backlinks-in-file buffer-file-name))

(defun org-open-fuzzy-links-as-files ()
  "Open fuzzy links like [[Example]] as files."
  (let* ((el (org-element-context))
         (type (first el))
         (link-type (plist-get (cadr el) :type))
         (path (let ((path-1 (plist-get (cadr el) :path)))
                 (when (stringp path-1)
                   (org-link-unescape path-1)))))
    (when (and (eql type 'link)
               path
               (string= link-type "fuzzy"))
      (let* ((path (regexp-quote path)))
          (find-file (concat path ".org"))))))

(add-hook 'org-open-at-point-functions 'org-open-fuzzy-links-as-files)
