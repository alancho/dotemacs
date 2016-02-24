(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

(package-initialize)

(el-get 'sync)

;; now set our own packages
(setq
 my:el-get-packages
 '(el-get				; el-get is self-hosting
   zencoding-mode			; http://www.emacswiki.org/emacs/ZenCoding
   color-theme		                ; nice looking emacs
   color-theme-tango
   auctex
   auto-complete
   ctable
   dash
   deferred
   elpy
   epc
   epl
   ess
   exec-path-from-shell
   expand-region
   idle-highlight-mode
   ido-ubiquitous
   magit
   markdown-mode
   org-mode
   paredit
   pkg-info
   popup
   request
   s
   smex
   websocket
   yasnippet
   ))

(when (ignore-errors (el-get-executable-find "cvs"))
  (add-to-list 'my:el-get-packages 'emacs-goodies-el)) ; the debian addons for emacs

(when (ignore-errors (el-get-executable-find "svn"))
  (loop for p in '(psvn    		; M-x svn-status
		   )
	do (add-to-list 'my:el-get-packages p)))

(setq my:el-get-packages
      (append
       my:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)

;; The following are my settings

;; Exec-path-from-shell
;; ========================================================
;; (require 'exec-path-from-shell) ;; if not using the ELPA package
(exec-path-from-shell-initialize)

;; Start in *scratch*
;; ========================================================
(setq inhibit-startup-message t)

;; AucTeX
;; ========================================================
;; (setq-default TeX-engine 'xetex)
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)

(add-hook 'LaTeX-mode-hook '(lambda () (if (string-match "\\.Rnw\\'" buffer-file-name) (setq fill-column 80))))

(auto-fill-mode -1)

(remove-hook 'text-mode-hook #'turn-on-auto-fill)

;; (add-hook 'LaTeX-mode-hook '(flyspell-mode t))
(add-hook 'LaTeX-mode-hook 'turn-on-flyspell)

;; To save and then run LaTeX in one command
(defun my-run-latex ()
  (interactive)
  (TeX-save-document (TeX-master-file))
  (TeX-command "LaTeX" 'TeX-master-file -1))

(defun my-LaTeX-hook ()
 (local-set-key (kbd "C-c C-c") 'my-run-latex))

(add-hook 'LaTeX-mode-hook 'my-LaTeX-hook)
;; ========================================================

;; Autocomplete
;; ========================================================
;; (require 'auto-complete-config)
;; (ac-config-default)

;; (setq
;;       ;; ac-auto-show-menu 1
;;       ;; ac-candidate-limit nil
;;       ;; ac-delay 0.1
;;       ;; ac-disable-faces (quote (font-lock-comment-face font-lock-doc-face))
;;       ;; ac-ignore-case 'smart
;;       ;; ac-menu-height 10
;;       ;; ac-quick-help-delay 1.5
;;       ;; ac-quick-help-prefer-pos-tip t
;;       ;; ac-use-quick-help nil
;; )

;; (define-key ac-completing-map [tab] 'ac-complete)
;; (define-key ac-completing-map [return] nil)

;; Default directory
;; ========================================================
;; (setq default-directory "~/Dropbox/")

;; Python
;; ========================================================
(elpy-enable)
(elpy-use-ipython)
(setq elpy-rpc-backend "jedi")
(define-key elpy-mode-map [(shift return)] 'elpy-shell-send-region-or-buffer)
(define-key elpy-mode-map [(C-return)] 'elpy-company-backend)

;; Encryption
;; ========================================================
(require 'epa-file)
(epa-file-enable)

;; ESS
;; ========================================================
(require 'ess-site)

(setq ess-ask-for-ess-directory nil)
(setq ess-local-process-name "R")
(setq ansi-color-for-comint-mode 'filter)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
(defun my-ess-start-R ()
  (interactive)
  (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
      (progn
        (delete-other-windows)
        (setq w1 (selected-window))
        (setq w1name (buffer-name))
        (setq w2 (split-window w1 nil t))
        (R)
        (set-window-buffer w2 "*R*")
        (set-window-buffer w1 w1name))))
(defun my-ess-eval ()
  (interactive)
  (my-ess-start-R)
  (if (and transient-mark-mode mark-active)
      (call-interactively 'ess-eval-region)
    (call-interactively 'ess-eval-line-and-step)))
(add-hook 'ess-mode-hook
          '(lambda()
             (local-set-key [(shift return)] 'my-ess-eval)))
(add-hook 'inferior-ess-mode-hook
          '(lambda()
             (local-set-key [C-up] 'comint-previous-input)
             (local-set-key [C-down] 'comint-next-input)))
(add-hook 'Rnw-mode-hook
          '(lambda()
             (local-set-key [(shift return)] 'my-ess-eval)))

;; This is to be quicker when writing the %>% operator from dplyr
(defun then_R_operator ()
  "R - %>% operator or 'then' pipe operator"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
  (reindent-then-newline-and-indent))
(define-key ess-mode-map (kbd "C-<return>") 'then_R_operator)
(define-key inferior-ess-mode-map (kbd "C-<return>") 'then_R_operator)

(defun then_ggplot_plus ()
  "R - %>% operator or 'then' pipe operator"
  (interactive)
  (just-one-space 1)
  (insert "+")
  (reindent-then-newline-and-indent))
(define-key ess-mode-map (kbd "C-+") 'then_ggplot_plus)
(define-key inferior-ess-mode-map (kbd "C-+") 'then_ggplot_plus)

;; (setq ess-default-style 'OWN)
;; (setq ess-default-style 'DEFAULT)

;;; my-RRR style (minor modification of default RRR) 2014-05-19
;; http://emacs.1067599.n5.nabble.com/indentation-of-ggplot-code-and-ess-13-09-02-td322315.html#a322335
;; (add-to-list 'ess-style-alist
;; 	     '(my-RRR (ess-indent-level . 2)
;; 		      ;; (ess-first-continued-statement-offset . 2)
;; 		      (ess-first-continued-statement-offset . 2)
;; 		      (ess-continued-statement-offset . 0)
;; 		      ;; (ess-continued-statement-offset . 2)
;; 		      (ess-brace-offset . 0)
;; 		      (ess-arg-function-offset . 2)
;; 		      (ess-arg-function-offset-new-line . '(2))
;; 		      ;; (ess-arg-function-offset-new-line . 0)
;; 		      (ess-expression-offset . 2)
;; 		      (ess-else-offset . 0)
;; 		      (ess-close-brace-offset . 0)))
;; (setq ess-default-style 'my-RRR)

;; The previous paragraph is now unnecessary because ESS now has
;; RStudio indentation!
(setq ess-default-style 'RStudio)

(setq fill-column 72)
(setq comment-auto-fill-only-comments t)
(auto-fill-mode t)

;; Define key-bindings for calling 'spin';
;; 'M-n n' - spin the current buffer
(define-key ess-mode-map "\M-nn" 'ess-swv-spin)

(defun ess-swv-spin ()
  "Run spin on the current .R file."
  (interactive)
  (ess-swv-run-in-R "knitr::spin"))

;; This is to change the default commenting style from base R to
;; roxygen comments
;; (add-hook 'ess-mode-hook
;;           '(lambda ()
;;             (setq comment-start "##'"
;;                   comment-end   "")))


;; Expand region
;; ========================================================
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;; This are my faces, fonts, et cetera
;; ========================================================
;; (set-face-attribute 'default nil :height 110 :weight 'normal)
;; In the Mac version comment the line above and uncomment the one below
;; (set-face-attribute 'default nil :height 110 :family "Monaco")
;; (set-face-attribute 'default nil :height 120 :family "Terminus")
(set-face-attribute 'default nil :height 120 :family "Inconsolata")
;; (set-face-attribute 'default nil :height 110 :family "Andale Mono")
;; (set-face-attribute 'default nil :height 120 :family "Consolas")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(markdown-bold-face ((t (:inherit font-lock-variable-name-face :weight normal))) t)
 '(markdown-header-delimiter-face ((t (:inherit font-lock-function-name-face :weight normal))) t)
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight normal))) t)
 '(markdown-italic-face ((t (:slant normal))) t)
 '(org-column ((t (:background "slate gray" :strike-through nil :underline nil :slant normal :weight normal :height 100 :family "Courier New"))))
;; In the Mac version comment the line above and uncomment the one below
 ;; '(org-column ((t (:background "slate gray" :strike-through nil :underline nil :slant normal :weight normal :height 120 :family "Monaco"))))
 )

;; This is to unfill paragraphs
;; ========================================================
(defun my-fill-latex-paragraph ()
  "Fill the current paragraph, separating sentences w/ a newline.

AUCTeX's latex.el reimplements the fill functions and is *very*
convoluted. We use part of it --- skip comment par we are in."
  (interactive)
  (if (save-excursion
        (beginning-of-line) (looking-at TeX-comment-start-regexp))
      (TeX-comment-forward)
  (let ((to (progn
              (LaTeX-forward-paragraph)
              (point)))
        (from (progn
                (LaTeX-backward-paragraph)
                (point)))
        (to-marker (make-marker)))
    (set-marker to-marker to)
    (while (< from (marker-position to-marker))
      (forward-sentence)
      (setq tmp-end (point))
      (LaTeX-fill-region-as-paragraph from tmp-end)
      (setq from (point))
      (unless (bolp)
        (LaTeX-newline))))))

(eval-after-load "latex"
  '(define-key LaTeX-mode-map (kbd "M-q") 'my-fill-latex-paragraph))

;; I don't need to highlight current line
;; ========================================================
;; ;; highlight the current line; set a custom face, so we can
;; ;; recognize from the normal marking (selection)
;; (defface hl-line '((t (:background "Black")))
;;   "Face to use for `hl-line-face'." :group 'hl-line)
;; (setq hl-line-face 'hl-line)
;; (global-hl-line-mode nil) ; turn it on for all modes by default

(remove-hook 'prog-mode-hook 'esk-turn-on-hl-line-mode)

;; When C-x C-f I don't want to see this extensions
;; ========================================================
(custom-set-variables
 '(completion-ignored-extensions (quote (".docx" ".xlsx" ".wmf" ".doc" ".xls" ".csv" ".bib" ".o" "~" ".bin" ".bak" ".obj" ".map" ".ico" ".pif" ".lnk" ".a" ".ln" ".blg" ".bbl" ".dll" ".drv" ".vxd" ".386" ".elc" ".lof" ".glo" ".idx" ".lot" ".svn/" ".hg/" ".git/" ".bzr/" "CVS/" "_darcs/" "_MTN/" ".fmt" ".tfm" ".class" ".fas" ".lib" ".mem" ".x86f" ".sparcf" ".fasl" ".ufsl" ".fsl" ".dxl" ".pfsl" ".dfsl" ".p64fsl" ".d64fsl" ".dx64fsl" ".lo" ".la" ".gmo" ".mo" ".toc" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr" ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".pyc" ".pyo" ".odt" ".pptx" ".ppt" ".txt" ".dat"))))

;; My magit setup
;; ========================================================
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

;; To stop seeing the warning triggered by the last version
;; (setq magit-last-seen-setup-instructions "1.4.0")

;; Setup markdown
;; ========================================================
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)

(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; My org-mode setup
;; ========================================================
(require 'org)

;; This is to have no blank lines inserted after headings
(setq org-blank-before-new-entry nil)

;; This is to view all at startup
(setq org-startup-folded nil)

;; Change todo state with C-c C-t KEY
(setq org-use-fast-todo-selection t)

;; Fixing task state with S-arrow
;; (setq org-treat-S-cursor-todo-selection-as-state-change nil)

;; To allow S-arrow to work only with time stamps
(setq org-support-shift-select (quote always))

(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key (kbd "<f11>") 'org-capture)

(setq org-agenda-files (list "~/Dropbox/gtd/inbox.org"
			     "~/Dropbox/gtd/thesis.org"
			     "~/Dropbox/gtd/ideas.org"
			     "~/Dropbox/gtd/someday.org"
			     ))

;; ;; Capture templates for: TODO tasks, Notes, appointments, phone calls, and org-protocol
(setq org-capture-templates
      (quote (("t" "Tasks" entry (file+headline "~/Dropbox/gtd/inbox.org" "Tasks")
               "* TODO %?\n %i")
              ("j" "Journal" entry (file+datetree "~/Dropbox/gtd/journal.org")
               "* %?\n%U"))))


;; Targets include this file and any file contributing to the agenda - up to 2 levels deep
(setq org-refile-targets (quote (("~/Dropbox/gtd/thesis.org" :level . 2)
				 ("~/Dropbox/gtd/ideas.org" :level . 2)
                                 ("~/Dropbox/gtd/someday.org" :level . 2))))

;; Stop using paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path nil)

;; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

;; Use IDO for both buffer and file completion and ido-everywhere to t
(setq org-completion-use-ido t)
(setq ido-everywhere t)
(setq ido-max-directory-size 100000)
(ido-mode (quote both))

(setq org-agenda-custom-commands
      '(("p" "Projects"
         ((tags "PROJECT")))

        ("c" "Office and Home Lists"
         ((agenda)
          (tags-todo "DATAANALYSIS")
          (tags-todo "WRITING")
          (tags-todo "EVENING")))

        ("d" "Daily Action List"
         (
          (agenda "" ((org-agenda-ndays 1)
                      (org-agenda-sorting-strategy
                       (quote ((agenda time-up priority-down tag-up) )))
                      (org-deadline-warning-days 0)
                      ))))
        )
      )

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

;; ;; This is to have always the 7 coming days in the week
;; (setq org-agenda-start-on-weekday nil)
;; (setq org-agenda-ndays 21)

;; (defun org-summary-todo (n-done n-not-done)
;;   "Switch entry to DONE when all subentries are done, to TODO otherwise."
;;   (let (org-log-done org-log-states)   ; turn off logging
;;     (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

;; (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

(defun gtd ()
    (interactive)
    (find-file "~/Dropbox/gtd/inbox.org"))

(global-set-key (kbd "C-c g") 'gtd)

;; Recent mode
;; ========================================================
(require 'recentf)

;; get rid of `find-file-read-only' and replace it with something
;; more useful.
(global-set-key (kbd "C-x C-r") 'ido-recentf-open)

;; enable recent files mode.
(recentf-mode t)

; 50 files ought to be enough.
(setq recentf-max-saved-items 50)

;; (defun ido-recentf-open ()
;;   "Use `ido-completing-read' to \\[find-file] a recent file"
;;   (interactive)
;;   (if (find-file (ido-completing-read "Find recent file: " recentf-list))
;;       (message "Opening file...")
;;     (message "Aborting")))

(global-set-key (kbd "C-x C-r") 'ido-recentf)

(defun ido-recentf ()
  "Use ido to select a recently opened file from the `recentf-list'"
  (interactive)
  (let
      ((home (expand-file-name (getenv "HOME"))))
    (find-file
     (ido-completing-read
      "Recentf open: "
      (mapcar (lambda (path)
                (replace-regexp-in-string home "~" path))
              recentf-list)
      nil t))))

;; This is my configuration for RefTeX
;; ========================================================
(require 'reftex)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)   ; with AUCTeX LaTeX mode
(add-hook 'latex-mode-hook 'turn-on-reftex)   ; with Emacs latex mode
(setq reftex-plug-into-AUCTeX t)

;; So that RefTeX also recognizes \addbibresource. Note that you
;; can't use $HOME in path for \addbibresource but that "~"
;; works.
(setq reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource"))
;; (setq reftex-bibpath-environment-variables '("~//Dropbox//PhD//writing//thesis//bib//"))

(setq reftex-default-bibliography
      (quote
       ("~/Dropbox/PhD/all.bib"
        ;; "~/Dropbox/PhD/writing/thesis/bib/roots.bib"
        ;; "~/Dropbox/PhD/writing/thesis/bib/roots-modelling.bib"
        ;; "~/Dropbox/PhD/writing/thesis/bib/canopy-temperature.bib"
        ;; "~/Dropbox/PhD/writing/thesis/bib/hydraulic-redistribution.bib"
)))

(eval-after-load 'reftex-vars
  '(progn
     (setq reftex-cite-format '((?\C-m . "[@%l]")))))

;; This is my color theme
;; ========================================================
(load-theme 'tango-dark)

;; This is how I prefer text to behave
;; ========================================================
(delete-selection-mode 1)
(setq shift-select-mode t)
(transient-mark-mode t)
(setq-default line-spacing 1)
(setq auto-save-default nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode 1)
(electric-pair-mode 1)
(visual-line-mode 1)
(setq ispell-program-name "aspell")
(prefer-coding-system 'utf-8)

(auto-fill-mode -1)

;; (remove-hook 'text-mode-hook #'turn-on-auto-fill)

(setq-default cursor-type 'bar)

(blink-cursor-mode 1)

(mapc
 (lambda (face)
   (set-face-attribute face nil :weight 'normal :underline nil))
 (face-list))

;; Conventional selection/deletion
(cua-mode 0)
(setq org-support-shift-select t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

;; Show line number in the mode line.
(line-number-mode 1)

;; I've found that it's better and a best practice not to wrap lines
;; when editing in LaTeX
(set-default 'truncate-lines t)
;; That said, the following must be deactivated
;; (global-visual-line-mode 1)

;; Display line numbers in margin
(global-linum-mode 1)

(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single
    logical line.  This is useful, e.g., for use with
    `visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

;; Handy key definition
(define-key global-map "\C-\M-Q" 'unfill-region)

;; Smooth movement of buffer when scrolling or moving with arrow keys
(setq redisplay-dont-pause t
  scroll-margin 1
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

;; Uniquify
;; ========================================================
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
; Slightly more debatable
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Yasnippets
;; ========================================================
(require 'yasnippet)
(yas-global-mode 1)
(global-set-key (kbd "C-.") 'yas/expand)

;; I need smex
;; ========================================================
(require 'smex)
(global-set-key (kbd "M-x") 'smex)
(setq smex-save-file "~/.smex-items")
(defun smex-update-after-load (unused)
      (when (boundp 'smex-cache)
        (smex-update)))
    (add-hook 'after-load-functions 'smex-update-after-load)

;; To answer quicker
;; ========================================================
(defalias 'yes-or-no-p 'y-or-n-p)

;; This is for dired mode to omit extensions I don't want to see
(require 'dired-x)
;; (setq-default dired-omit-files-p t) ; Buffer-local variable
;; (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))

;; So that I can make beamer presentations in org-mode
(require 'ox-latex)
(add-to-list 'org-latex-classes
             '("beamer"
               "\\documentclass\[presentation\]\{beamer\}"
               ("\\section\{%s\}" . "\\section*\{%s\}")
               ("\\subsection\{%s\}" . "\\subsection*\{%s\}")
               ("\\subsubsection\{%s\}" . "\\subsubsection*\{%s\}")))

;; Ignore case in eshell
(setq eshell-cmpl-ignore-case t)

;; Save backups in a separate, dedicated directory
(setq backup-directory-alist '(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

;; Start emacs in eshell
(add-hook 'emacs-startup-hook
          (lambda ()
            (cd default-directory)
            (eshell)))

;; In dired, sort directories first
(setq dired-listing-switches "-aBhl  --group-directories-first")
