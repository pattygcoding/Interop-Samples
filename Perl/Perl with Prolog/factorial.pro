% Define the factorial predicate
factorial(0, 1). % Base case: factorial of 0 is 1
factorial(N, F) :-
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

% Entry point for Prolog when called from Perl
main :-
    current_prolog_flag(argv, Argv),
    nth0(0, Argv, NStr),
    atom_number(NStr, N),
    factorial(N, Result),
    write(Result), nl,
    halt.
