;; Interop sample: prints the arithmetic mean of the numbers given on the
;; command line.
;;
;; Invoked by Main.hs; see README.md for build and run instructions.

;; Every token must be a number; anything else is reported and stops the run.
(defn parse-numbers [tokens]
  (mapv (fn [token]
          (try
            (Double/parseDouble token)
            (catch NumberFormatException _
              (binding [*out* *err*]
                (println (str "error: '" token "' is not a number")))
              (System/exit 1))))
        tokens))

(defn -main [& args]
  (if (empty? args)
    (do
      (binding [*out* *err*] (println "error: no numbers supplied"))
      (System/exit 1))
    (let [numbers (parse-numbers args)
          average (/ (reduce + numbers) (count numbers))]
      ;; Format with the root locale so the decimal separator is stable.
      (println (String/format java.util.Locale/ROOT "%.2f" (to-array [average]))))))

(apply -main *command-line-args*)
