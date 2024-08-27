(ns average-calculator)

(defn calculate-average [numbers]
  (if (empty? numbers)
    0.0
    (let [sum (reduce + numbers)]
      (/ sum (count numbers)))))
