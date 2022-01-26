;;; .emacs.el --- Static init file loading the complete one on a host volume -*- lexical-binding: t -*-

;; Author: Samuele Favazza
;; Maintainer: Samuele Favazza
;; Version: 0.0
;; Package-Requires: ()
;; Homepage: 
;; Keywords: 



;;; Commentary:

;; Emacs looks for initialization files in multiple locations, the first is ~/.emacs. To allow changes to it
;; without adding another layer to the docker image. This file is copied and committed in the docker image to
;; load the real .emacs file from the host folder mapped into the docker container file-system.

;;; Code:

(setq EMACSD_HOME "~/store/.emacs.d/")
(setq user-emacs-directory EMACSD_HOME)

(unless (file-exists-p "~/store/emacs_git/.setup-complete")
  (load-file "~/store/emacs_git/all_package_install.el"))

;; load the emacs configuration file found in the store/ folder mapped from the host fs
(load-file "~/store/init_emacs.el")
