;;; Interop sample: reads whitespace-separated numbers from standard input and
;;; prints their arithmetic mean.
;;;
;;; Invoked by main.fsx; see README.md for build and run instructions.

(defun read-numbers ()
  "Read whitespace-separated numbers from standard input until end of file."
  (let ((numbers '()))
    (handler-case
        (loop for value = (read *standard-input* nil :eof)
              until (eq value :eof)
              do (unless (numberp value)
                   (format *error-output* "error: '~a' is not a number~%" value)
                   (sb-ext:exit :code 1))
                 (push value numbers))
      (error (condition)
        (format *error-output* "error: ~a~%" condition)
        (sb-ext:exit :code 1)))
    (nreverse numbers)))

(defun main ()
  (let ((numbers (read-numbers)))
    (when (null numbers)
      (format *error-output* "error: no numbers on stdin~%")
      (sb-ext:exit :code 1))
    (format t "~,2f~%" (/ (reduce #'+ numbers) (length numbers)))))

(main)
