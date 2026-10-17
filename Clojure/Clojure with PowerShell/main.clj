;; Interop sample: Clojure driving a PowerShell script.
;;
;; Clojure passes the numbers as command-line arguments to the PowerShell
;; helper and reads the average it prints back from stdout.
;;
;; See README.md for build and run instructions.

(require '[clojure.java.io :as io]
         '[clojure.java.shell :as shell]
         '[clojure.string :as str])

;; Resolve the helper next to this script so the sample runs from anywhere.
(def ^:private script
  (.getPath (io/file (.getParentFile (.getAbsoluteFile (io/file (or *file* "main.clj"))))
                     "average_calculator.ps1")))

(defn powershell
  "Return the PowerShell executable to use: pwsh where it is installed,
  otherwise the Windows-only powershell."
  []
  (let [works? (fn [exe]
                 (try
                   (zero? (:exit (shell/sh exe "-NoProfile" "-Command" "exit 0")))
                   (catch Exception _ false)))]
    (cond
      (works? "pwsh") "pwsh"
      (works? "powershell") "powershell"
      :else (throw (ex-info "PowerShell was not found on PATH" {})))))

(defn calculate-average
  "Run the PowerShell helper and return the average it prints."
  [numbers]
  (let [result (apply shell/sh
                      (powershell)
                      (concat ["-NoProfile" "-ExecutionPolicy" "Bypass" "-File" script]
                              (map str numbers)))]
    (when-not (zero? (:exit result))
      (throw (ex-info (or (not-empty (str/trim (:err result)))
                          (str "PowerShell exited with " (:exit result)))
                      {})))
    (Double/parseDouble (str/trim (:out result)))))

(defn parse-numbers
  "Convert command-line tokens to doubles, skipping anything invalid."
  [tokens]
  (keep (fn [token]
          (try
            (Double/parseDouble token)
            (catch NumberFormatException _
              (binding [*out* *err*]
                (println (str "warning: skipping non-numeric argument '" token "'")))
              nil)))
        tokens))

(defn -main [& args]
  (let [numbers (if (seq args) (parse-numbers args) [10.0 20.0 30.0 40.0 50.0])]
    (if (empty? numbers)
      (do
        (binding [*out* *err*] (println "error: no numbers to average"))
        (System/exit 1))
      (try
        (let [average (calculate-average numbers)]
          ;; Format with the root locale so the decimal separator is stable.
          (println (String/format java.util.Locale/ROOT
                                  "The average of %d value(s) is: %.2f"
                                  (to-array [(count numbers) (double average)]))))
        (catch Exception e
          (binding [*out* *err*] (println (str "error: " (.getMessage e))))
          (System/exit 1))))))

(apply -main *command-line-args*)
