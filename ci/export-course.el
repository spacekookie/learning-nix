;; TODO: swap the theme to be more easily readable on white background
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
  
  ;; Export the README
  (find-file "README.org")
  (org-html-export-to-html)
  
  ;; Then export the rest of the slides
  (mapcar
   (lambda (file)
     (find-file file)
     (org-reveal-export-to-html))
   (delete "*.html"
           (delete "README.org"
                   (directory-files "." nil "\.org$" t)))))

(provide 'export-course)
