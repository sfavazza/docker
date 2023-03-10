;;; .emacs.el --- Static init file loading the complete one on a host volume -*- lexical-binding: t -*-

;; Author: Samuele Favazza
;; Maintainer: Samuele Favazza
;; Version: 0.0
;; Package-Requires: ()
;; Homepage: 
;; Keywords: 



;;; Commentary:

;; Emacs looks for initialization files in multiple locations, the first being ~/.emacs. To prevent adding new
;; layers to the emacs-image for every customization, a simple .emacs file is committed in the image which in
;; turn sources an external file on the host and mapped into the docker container file-system.

;;; Code:

(setq EMACSD_HOME "~/.emacs.d/")
(setq user-emacs-directory EMACSD_HOME)

(unless (file-exists-p "~/store/emacs_git/.setup-complete")
  (load-file "~/store/emacs_git/all_package_install.el"))

;; copy the ~/store/configs content to the ~/ folder (check if at least one known folder is present
(unless (file-exists-p "~/.ssh")
  (copy-directory "~/store/configs" "~/" nil nil t))

;; load the emacs configuration file found in the store/ folder mapped from the host fs
(load-file "~/store/init_emacs.el")
