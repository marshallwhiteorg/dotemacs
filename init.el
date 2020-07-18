(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

;; Personal info
(setq user-full-name "Marshall White"
      user-mail-address "m@marshallwhite.org")

;; key bindings
(when (eq system-type 'darwin) ;; mac specific settings
  (setq mac-option-modifier 'meta))

;; use-package setup
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Helm allows better completions.
(use-package helm
  :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files))
  :config (progn
            (setq helm-buffers-fuzzy-matching t)
            (setq helm-mode-fuzzy-match t)
            (setq helm-completion-in-region-fuzzy-match t)
            (helm-mode 1)))

;; Helm-swoop allows better searching.
(use-package helm-swoop
  :ensure t
  :bind (("C-s" . helm-swoop)))

;; Allows C-k to remove a line.
(customize-set-variable 'kill-whole-line t)

;; Disables hard tabs.
(customize-set-variable 'indent-tabs-mode nil)

;; Enables whitespace-mode for programming-related major modes.
(define-global-minor-mode prog-global-whitespace-mode whitespace-mode
  (lambda ()
    (when (derived-mode-p 'prog-mode)
      (whitespace-mode t))))
(setq whitespace-global-modes nil)
(prog-global-whitespace-mode 1)


;; Use aspell for spell checking.
(setq ispell-program-name "aspell")
(setq ispell-list-command "--list")

;; Move backups to ~/.emacs.d/backups
(customize-set-variable 'backup-directory-alist
                        `(("." . ,(concat user-emacs-directory "backups"))))

;; Cycle window config changes
(when (fboundp 'winner-mode) (winner-mode))

;; Easy font size changes
(bind-key "M-+" 'text-scale-increase)
(bind-key "M-=" 'text-scale-increase)
(bind-key "M--" 'text-scale-decrease)

;; Reset font size
(defun zz/text-scale-reset ()
  (interactive)
  (text-scale-set 0))
(bind-key "M-0" 'zz/text-scale-reset)

;; Discover emacs keys more easily via helper
(use-package which-key
  :ensure t
  :defer nil
  :diminish which-key-mode
  :config
  (which-key-mode))


;; Modeline config
(display-time-mode 1)
(use-package smart-mode-line
  :ensure t)

;; Add char count for line to modeline
(setq global-mode-string
      '(:eval (format "%dc" (- (line-end-position) (line-beginning-position)))))

;; Title bar memento mori
(add-hook 'after-init-hook (lambda ()
                             (setq-default frame-title-format "In game")))

;; Switch windows with M-[num]
(global-set-key (kbd "M-0") 'winum-select-window-0-or-10)
(global-set-key (kbd "M-1") 'winum-select-window-1)
(global-set-key (kbd "M-2") 'winum-select-window-2)
(global-set-key (kbd "M-3") 'winum-select-window-3)
(global-set-key (kbd "M-4") 'winum-select-window-4)
(global-set-key (kbd "M-5") 'winum-select-window-5)
(global-set-key (kbd "M-6") 'winum-select-window-6)
(global-set-key (kbd "M-7") 'winum-select-window-7)
(global-set-key (kbd "M-8") 'winum-select-window-8)
(use-package winum
  :ensure t
  :config
  (winum-mode))

;; Appearance
(when (>= emacs-major-version 26)
  (pixel-scroll-mode))

(set-face-attribute 'default nil :family "Iosevka" :height 130)
(set-face-attribute 'fixed-pitch nil :family "Iosevka")
(set-face-attribute 'variable-pitch nil :family "Baskerville")
;;(use-package poet-dark-monochrome-theme
;;(use-package cyberpunk-theme
(use-package nord-theme
  :ensure t
  :config
  (variable-pitch-mode 0))

(menu-bar-mode -1)
(tool-bar-mode -1)

;; Center text in buffer while in text mode
;; (add-hook 'text-mode-hook 'turn-on-olivetti-mode)
;;(add-hook 'text-mode-hook
;;                (lambda ()
;;                  (variable-pitch-mode 1)))
(blink-cursor-mode 0)    ;; Reduce visual noise

(setq highlight-indent-guides-responsive 'top
      highlight-indent-guides-delay 0)

;; Org and R additional symbols
;; hex code ▷ (9655), ◇ (9671), ▶ (9654), ƒ (402)
;;(setq +pretty-code-iosevka-font-ligatures
;;      (append +pretty-code-iosevka-font-ligatures
;;              '(("[ ]" .  "☐")
;;                ("[X]" . "☑" )
;;                ("[-]" . "❍" )
;;                ("%>%" . ?▷)
;;                ("%$%" . ?◇)
;;                ("%T>%" . ?▶)
;;                ("function" . ?ƒ))))

;; Use IPython for REPL
(setq python-shell-interpreter "jupyter"
      python-shell-interpreter-args "console --simple-prompt"
      python-shell-prompt-detect-failure-warning nil)

;; Allows easier interaction with projects
(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode 1))

;; Uses Helm utilities for projectile
(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))


;; Shell
(use-package shell-switcher
  :ensure t
  :config
  (setq shell-switcher-mode t))

(use-package eshell
  :init
  (add-hook 'eshell-mode-hook 'shell-switcher-manually-register-shell)
  :config
  (setq eshell-prompt-function
        (lambda nil
          (let ((env-name conda-env-current-name))
            (concat
             (if (string= (eshell/pwd) (getenv "HOME"))
                 "~" (eshell/basename (eshell/pwd)))
             (if env-name
                 (format " (%s) $ " env-name)
               " $ "))))))

;; Anaconda
(use-package conda
  :ensure t
  :init
  (setq conda-anaconda-home (expand-file-name "~/miniconda3/"))
  (setq conda-env-home-directory (expand-file-name "~/miniconda3/"))
  :config
  (conda-env-initialize-eshell))


;; C++ ----
;; Adds on the fly syntax checking
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  (add-hook
   'c++-mode-hook
   (lambda () (setq flycheck-clang-language-standard "c++17"))))

;; Improves C++ code style
(setq c-basic-offset 4
      c-default-style "stroustrup") ; style from his book

;; Racket ----
(use-package racket-mode
  :ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups"))))
 '(c-basic-offset 4)
 '(custom-safe-themes
   (quote
    ("1119fc59c71d953f66e1b24889886f91ead269831f3e0562cd64b1781cc125c8" "82358261c32ebedfee2ca0f87299f74008a2e5ba5c502bde7aaa15db20ee3731" "6bc387a588201caf31151205e4e468f382ecc0b888bac98b2b525006f7cb3307" default)))
 '(indent-tabs-mode nil)
 '(initial-buffer-choice "~/files/pictures/mwhite_pixel.png")
 '(kill-whole-line t)
 '(line-spacing 0.2)
 '(package-selected-packages
   (quote
    (helm-projectile projectile flycheck python-docstring mentor org-pomodoro conda ein cyberpunk-theme poet-dark-monochrome-theme poet-dark-theme winum org-bullets helm-swoop helm use-package)))
 '(safe-local-variable-values (quote ((TeX-engine . xetex))))
 '(whitespace-global-modes nil)
 '(whitespace-line-column 80)
 '(whitespace-style
   (quote
    (face trailing tabs spaces lines newline empty indentation space-after-tab space-before-tab tab-mark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
