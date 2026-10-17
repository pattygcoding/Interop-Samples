%% Interop sample: factorial computed in Prolog and invoked from Perl.
%%
%% Usage: swipl -q -f factorial.pro -g main -- <n>

%% factorial(+N, -F)
%% True when F is N! for a non-negative integer N.
factorial(N, F) :-
    integer(N),
    N >= 0,
    factorial_(N, 1, F).

%% Tail-recursive worker carrying an accumulator, so deep inputs do not
%% exhaust the stack.
factorial_(0, Acc, Acc) :- !.
factorial_(N, Acc, F) :-
    Acc1 is Acc * N,
    N1 is N - 1,
    factorial_(N1, Acc1, F).

%% Entry point used by the `-g main` goal. It halts explicitly so that
%% `swipl` does not drop into its interactive top level after the goal runs.
main :-
    current_prolog_flag(argv, Argv),
    (   Argv = [NStr | _],
        atom_number(NStr, N),
        integer(N),
        N >= 0
    ->  factorial(N, Result),
        write(Result), nl,
        halt
    ;   format(user_error, 'error: expected a non-negative integer, got ~w~n', [Argv]),
        halt(1)
    ).

