;; TODO: swap the theme to be more easily readable on white background
(defun export-course ()
  "Export a course tree as a set of HTML files"
  (interactive)

  ;; Manually require ox-reveal
  (require 'ox-reveal)
  
  ;; Make sure org-reveal is loaded and set-up
  (load-library "reveal")
  (setq org-reveal-root "../../.templates")
  
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
