;;; jehna - Emacs init file

;;; Code:
(setq inhibit-startup-message t)
(setq use-package-always-ensure t)

;; Setup windowing
(when window-system (tool-bar-mode -1)
      (when window-system (set-frame-size (selected-frame) 200 53)))

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://stable.melpa.org/packages/") t)

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package try)

(use-package which-key
  :config (which-key-mode))

(use-package markdown-mode)
(gfm-mode)

(use-package counsel)

(use-package swiper
  :bind (("C-s" . swiper)
    ("C-x C-f" . counsel-find-file)
    ("M-x" . counsel-M-x)
    ("C-c j" . counsel-git-grep))
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
    ))

(use-package auto-complete
  :init
  (progn
    (ac-config-default)
    (global-auto-complete-mode t)))

(use-package multiple-cursors
  :bind (("∆" . mc/mark-next-like-this)
	 ("ﬂ" . mc/edit-lines))
  :init
  (multiple-cursors-mode t))

(use-package magit)

(use-package tern)

(use-package tern-auto-complete)

(use-package fiplr)

(use-package flycheck
  :init (global-flycheck-mode))

(use-package js2-mode)
(setq-default js2-basic-indent 2)
(setq-default js2-basic-offset 2)
(setq-default js2-auto-indent-p t)
(setq-default js2-cleanup-whitespace t)
(setq-default js2-enter-indents-newline t)
(setq-default js2-show-parse-errors nil)

(add-hook 'js2-mode-hook #'flycheck-mode)

;; Whitespace

(defun my/use-good-whitespace ()
  (setq whitespace-style (quote (face tabs indentation spaces space-mark tabs-mark)))
  (setq whitespace-indentation-regexp '("^\\( *\\)"))
  (global-whitespace-mode 1)
  (set-face-attribute 'whitespace-indentation nil :background nil :foreground "grey80")
  (set-face-attribute 'whitespace-space nil :background "black" :foreground "black")
  (set-face-attribute 'whitespace-hspace nil :background "red" :foreground nil)
  (set-face-attribute 'whitespace-tab nil :background "red" :foreground nil)
  (setq whitespace-display-mappings
        '((space-mark ?\xA0 [?\xB7] [?_])))
)
(add-hook 'js2-mode-hook #'my/use-eslint-from-node-modules)

(setq indo-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;; Tern config

(add-hook 'js-mode-hook (lambda () (tern-mode t)))
(eval-after-load 'tern
   '(progn
      (require 'tern-auto-complete)
      (tern-ac-setup)))

;; Don't backup (YOLO)
(setq make-backup-files nil)

;; Enable curly braces (wtf Charles)
(setq mac-option-modifier nil
      mac-command-modifier 'meta
      x-select-enable-clipboard t)

;; Better bash
(use-package exec-path-from-shell)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Fuzzy find config

(global-set-key (kbd "C-x t") 'fiplr-find-file)

(setq fiplr-ignored-globs '((directories (".git" ".svn" "node_modules"))
			    (files ("*.jpg" "*.png" "*.zip" "*~" ".*"))))

;; ESLint
;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
		(or (buffer-file-name) default-directory)
		"node_modules"))
	 (eslint (and root
		      (expand-file-name "node_modules/eslint/bin/eslint.js"
					root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))
(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; Custom keybinding

(defun window-half-height ()
  (max 1 (/ (1- (window-height (selected-window))) 2)))

(defun scroll-up-half ()
  (interactive)
  (scroll-up (window-half-height)))

(defun scroll-down-half ()
  (interactive)
  (scroll-down (window-half-height)))

(global-set-key (kbd "C-d") 'scroll-up-half)

;; Theme
(use-package dracula-theme)
(load-theme 'dracula t)
(custom-set-faces (if (not window-system) '(default ((t (:background "nil"))))))

;; Use custom font
;(set-frame-font "Inconsolata" nil t)
;(set-face-attribute 'default nil :height 150)
