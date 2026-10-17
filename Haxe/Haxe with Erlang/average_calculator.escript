#!/usr/bin/env escript

%% Interop sample: prints the arithmetic mean of the numbers given on the
%% command line.
%%
%% Invoked by Main.hx; see README.md for build and run instructions.

main(Args) ->
    case parse_numbers(Args, []) of
        [] ->
            io:format(standard_error, "error: no numbers supplied~n", []),
            halt(1);
        Numbers ->
            io:format("~.2f~n", [lists:sum(Numbers) / length(Numbers)])
    end.

%% Accept both `10` and `10.5`; anything else is an error.
parse_numbers([], Acc) ->
    lists:reverse(Acc);
parse_numbers([Token | Rest], Acc) ->
    case string:to_float(Token) of
        {Value, ""} ->
            parse_numbers(Rest, [Value | Acc]);
        _ ->
            case string:to_integer(Token) of
                {Integer, ""} ->
                    parse_numbers(Rest, [Integer * 1.0 | Acc]);
                _ ->
                    io:format(standard_error, "error: '~s' is not a number~n", [Token]),
                    halt(1)
            end
    end.
