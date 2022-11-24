;; TODO: swap the theme to be more easily readable on white background

(defun nix-course--clean-dir (file-liste)
  (nix-course--rm-special
   (delete "*.html" (delete "README.org" file-liste))))

(defun nix-course--rm-special (file-liste)
  (delete "." (delete ".." file-liste)))

(defun export-all-courses ()
  "Export all courses from a particular course-tree to HTML"
  (interactive)

  (setq nix-course-export-root (read-directory-name "Select root of course tree"))
  
  ;; Manually require ox-reveal
  (require 'ox-reveal)
  
  ;; Make sure org-reveal is loaded and set-up
  (load-library "reveal")
  (setq org-reveal-root (concat nix-course-export-root "../.templates"))
  (setq org-html-preamble nil)
  (setq org-html-postamble nil)
  
  ;; Export the root README
  (find-file (concat nix-course-export-root "../README.org"))
  (org-html-export-to-html)

  ;; Export all the sub-course README's
  (mapcar
   ;; This function takes a directory, and for every .org file in it,
   ;; executes another lambda
   (lambda (dir)
     (mapcar
      ;; This function takes a file, constructs an absolute path to it
      ;; and exports it to reveal HTML.  If the file was not
      ;; previously open, it closes the buffer again to prevent buffer
      ;; spam
      (lambda (file)
        (setq target-file (concat nix-course-export-root dir "/" file))
        (setq buffer-exists (get-buffer file))
        (find-file target-file)
        (org-reveal-export-to-html)
        (unless buffer-exists
          (kill-buffer file))
        )
      ;; Construct a list of files based on the current course category
      (nix-course--clean-dir (directory-files (concat nix-course-export-root dir) nil "\.org$" t))
      )
     )
   ;; Construct a list of directories from the nix-course-export-root
   (nix-course--clean-dir (directory-files nix-course-export-root))
   )
  
  ;; Then iterate over the same directories but only export the README.org files
  (mapcar (lambda (dir)
            (setq target-file (concat nix-course-export-root dir "/" "README.org"))
            (find-file target-file)
            (org-html-export-to-html))
          ;; Construct a list of directories based on the
          ;; nix-course-export-root variable
          (nix-course--rm-special (directory-files nix-course-export-root))))

(provide 'export-course)
