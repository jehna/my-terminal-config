;; Disable package initialize at startup. The commented line below is
;; required for really disabling it.

;; (package-initialize)
(setq package-enable-at-startup nil)

(setq vj--emacs-org "~/.config/emacs/emacs.org"
      vj--emacs-elc (concat (file-name-sans-extension vj--emacs-org) ".elc"))

(defun recompile-emacs-org ()
  (interactive)
  (let ((old-init-file-debug init-file-debug)
        (init-file-debug nil))
    (require 'ob-tangle)
    (org-babel-load-file vj--emacs-org t)
    (setq init-file-debug old-init-file-debug)))

;; If emacs.org is newer than emacs.elc, then load .org and show a
;; message that elc is out of date. Don't load elc anyway if in
;; init-file-debug mode
(if init-file-debug
    (progn
      (org-babel-load-file vj--emacs-org t)
      (message "emacs.elc older than emacs.org. Update with M-x recompile-emacs-org"))
  (load-file vj--emacs-elc))
