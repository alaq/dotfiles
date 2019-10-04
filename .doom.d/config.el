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
