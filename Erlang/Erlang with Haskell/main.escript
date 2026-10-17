#!/usr/bin/env escript

%% Interop sample: Erlang driving a compiled Haskell program.
%%
%% The escript opens the Haskell helper as an Erlang port, passes the numbers
%% as command-line arguments and reads the average it prints back from stdout.
%%
%% See README.md for build and run instructions.

main(Args) ->
    Numbers =
        case Args of
            [] -> default_numbers();
            _ -> parse_numbers(Args, [])
        end,

    case Numbers of
        [] ->
            io:format(standard_error, "error: no numbers to average~n", []),
            halt(1);
        _ ->
            case average(Numbers) of
                {ok, Value} ->
                    io:format("The average of ~b value(s) is: ~.2f~n", [length(Numbers), Value]);
                {error, Reason} ->
                    io:format(standard_error, "error: ~s~n", [Reason]),
                    halt(1)
            end
    end.

default_numbers() ->
    [10, 20, 30, 40, 50].

%% Parse the command line, skipping anything that is not an integer.
parse_numbers([], Acc) ->
    lists:reverse(Acc);
parse_numbers([Token | Rest], Acc) ->
    case string:to_integer(Token) of
        {Value, ""} ->
            parse_numbers(Rest, [Value | Acc]);
        _ ->
            io:format(standard_error, "warning: skipping non-integer argument '~s'~n", [Token]),
            parse_numbers(Rest, Acc)
    end.

%% Run the Haskell helper through a port so its exit status is available.
average(Numbers) ->
    Port = open_port(
        {spawn_executable, executable()},
        [binary, exit_status, stderr_to_stdout, {args, [integer_to_list(N) || N <- Numbers]}]
    ),
    collect(Port, <<>>).

collect(Port, Acc) ->
    receive
        {Port, {data, Data}} ->
            collect(Port, <<Acc/binary, Data/binary>>);
        {Port, {exit_status, 0}} ->
            parse_result(Acc);
        {Port, {exit_status, Code}} ->
            {error, io_lib:format("the Haskell helper exited with status ~b: ~s", [Code, trim(Acc)])}
    after 30000 ->
        port_close(Port),
        {error, "the Haskell helper timed out"}
    end.

parse_result(Output) ->
    Text = trim(Output),
    try
        {ok, list_to_float(Text)}
    catch
        error:badarg ->
            {error, io_lib:format("unexpected output from the Haskell helper: ~s", [Text])}
    end.

%% Normalise port output to a string, whatever list/binary shape OTP hands us.
trim(Data) ->
    unicode:characters_to_list(string:trim(Data)).

executable() ->
    filename:absname("average_calculator" ++ extension()).

extension() ->
    case os:type() of
        {win32, _} -> ".exe";
        _ -> ""
    end.
