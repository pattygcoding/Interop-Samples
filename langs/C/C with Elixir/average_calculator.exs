# Interop sample: prints the arithmetic mean of the integers given on the
# command line.
#
# Invoked by main.c; see README.md for build and run instructions.

defmodule AverageCalculator do
  @moduledoc """
  Interop sample: computes the arithmetic mean of the integers passed as
  command-line arguments and prints it to standard output.
  """

  @doc "Entry point: parses `System.argv/0` and prints the mean."
  @spec run([String.t()]) :: :ok
  def run(args) do
    case parse(args) do
      {:error, token} ->
        IO.puts(:stderr, "error: '#{token}' is not an integer")
        System.halt(1)

      [] ->
        IO.puts(:stderr, "error: no numbers supplied")
        System.halt(1)

      numbers ->
        average = Enum.sum(numbers) / length(numbers)
        :io.format("~.2f~n", [average])
    end
  end

  defp parse(tokens) do
    tokens
    |> Enum.reduce_while([], fn token, acc ->
      case Integer.parse(token) do
        {value, ""} -> {:cont, [value | acc]}
        _ -> {:halt, {:error, token}}
      end
    end)
    |> case do
      {:error, _} = error -> error
      reversed -> Enum.reverse(reversed)
    end
  end
end

AverageCalculator.run(System.argv())
