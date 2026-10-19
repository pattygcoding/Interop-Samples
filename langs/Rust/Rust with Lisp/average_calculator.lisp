;;; Interop sample: prints the arithmetic mean of the numbers given on the
;;; command line.
;;;
;;; Invoked by main.rs; see README.md for build and run instructions.

(defun parse-numbers (tokens)
  "Convert every command-line token to a number."
  (mapcar (lambda (token)
            (handler-case
                (let ((value (read-from-string token)))
                  (unless (numberp value)
                    (error "not a number"))
                  value)
              (error ()
                (format *error-output* "error: '~a' is not a number~%" token)
                (sb-ext:exit :code 1))))
          tokens))

(defun main ()
  ;; `sbcl --script script.lisp 1 2 3` leaves the arguments in *posix-argv*,
  ;; whose first entry is the script name itself.
  (let ((numbers (parse-numbers (cdr sb-ext:*posix-argv*))))
    (when (null numbers)
      (format *error-output* "error: no numbers supplied~%")
      (sb-ext:exit :code 1))
    (format t "~,2f~%" (float (/ (reduce #'+ numbers) (length numbers))))))

(main)
