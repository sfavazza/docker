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


;; link all files found in ~/store/configs to a configuration file under the ~/ folder
(let ((config-file-list (directory-files "~/store/configs" nil)))
  (while config-file-list
    (let ((config-file-name (car config-file-list)))
      (if (and
           (not (string= config-file-name "."))
           (not (string= config-file-name "..")))
          (progn
            ;; create a symbolic link in the home dir from the host config one, don't care about existing files
            (copy-file
             (concat "~/store/configs/" config-file-name)
             (concat "~/" config-file-name) t)
            (message "linking in docker home folder the configuration file %s" config-file-name))))

    ;; pop out a name from the list
    (setq config-file-list (cdr config-file-list))))

;; load the emacs configuration file found in the store/ folder mapped from the host fs
(load-file "~/store/init_emacs.el")
