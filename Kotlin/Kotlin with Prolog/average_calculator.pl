%% Interop sample: prints the arithmetic mean of the numbers given on the
%% command line.
%%
%% Usage: swipl -q -f average_calculator.pl -g main -- <numbers...>
%%
%% Invoked by Main.kt; see README.md for build and run instructions.

%% average(+Numbers, -Mean)
average(Numbers, Mean) :-
    sum_list(Numbers, Total),
    length(Numbers, Count),
    Mean is Total / Count.

%% parse_numbers(+Arguments, -Numbers) - every argument must be a number.
parse_numbers(Arguments, Numbers) :-
    maplist(atom_number, Arguments, Numbers).

%% Entry point used by the `-g main` goal. It halts explicitly so that `swipl`
%% does not drop into its interactive top level after the goal runs.
main :-
    current_prolog_flag(argv, Arguments),
    (   parse_numbers(Arguments, Numbers)
    ->  (   Numbers = []
        ->  format(user_error, 'error: no numbers supplied~n', []),
            halt(1)
        ;   average(Numbers, Mean),
            format('~2f~n', [Mean]),
            halt
        )
    ;   format(user_error, 'error: every argument must be a number~n', []),
        halt(1)
    ).
