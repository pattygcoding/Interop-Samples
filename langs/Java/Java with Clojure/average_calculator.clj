(ns average-calculator
  "Arithmetic helpers that are invoked from Java.")

(defn calculate-average
  "Returns the arithmetic mean of `numbers` as a double.

  Works with any seqable collection (including Java arrays); an empty or nil
  input yields 0.0. The result is coerced to a primitive double so it maps
  cleanly onto Java's `Double`."
  [numbers]
  (let [values (seq numbers)]
    (if (nil? values)
      0.0
      (double (/ (reduce + values) (count values))))))

