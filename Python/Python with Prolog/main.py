from pyswip import Prolog

# Initialize the Prolog engine
prolog = Prolog()

# Load the Prolog file
prolog.consult('family.pl')

# Query the Prolog facts or rules
result = list(prolog.query("father(X, jane)"))

# Print the results
for r in result:
    print(f"{r['X']} is the father of Jane")
