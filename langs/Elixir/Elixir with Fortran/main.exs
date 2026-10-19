# Interop sample: Elixir driving a compiled Fortran program.
#
# Elixir passes the numbers as command-line arguments to the Fortran helper and
# reads the average it prints back from stdout.
#
# See README.md for build and run instructions.

defmodule Main do
  @moduledoc """
  Interop sample: runs the Fortran helper and reports the average it computes.
  """

  @doc "Entry point: parses `System.argv/0` and prints the result."
  @spec run([String.t()]) :: :ok
  def run(args) do
    numbers =
      case args do
        [] -> [10, 20, 30, 40, 50]
        _ -> parse_numbers(args, [])
      end

    if numbers == [] do
      IO.puts(:stderr, "error: no numbers to average")
      System.halt(1)
    end

    case average(numbers) do
      {:ok, value} ->
        :io.format("The average of ~b value(s) is: ~.2f~n", [length(numbers), value])

      {:error, message} ->
        IO.puts(:stderr, "error: " <> message)
        System.halt(1)
    end
  end

  # Convert command-line tokens to integers, skipping anything invalid.
  defp parse_numbers([], acc), do: Enum.reverse(acc)

  defp parse_numbers([token | rest], acc) do
    case Integer.parse(token) do
      {value, ""} ->
        parse_numbers(rest, [value | acc])

      _ ->
        IO.puts(:stderr, "warning: skipping non-integer argument '#{token}'")
        parse_numbers(rest, acc)
    end
  end

  # Run the Fortran helper and return the average it prints.
  defp average(numbers) do
    executable = "average_calculator" <> extension()
    arguments = Enum.map(numbers, &Integer.to_string/1)

    try do
      case System.cmd(executable, arguments) do
        {output, 0} -> parse_output(output)
        {output, status} -> {:error, failure_message(output, status)}
      end
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  defp parse_output(output) do
    text = String.trim(output)

    case Float.parse(text) do
      {value, _rest} -> {:ok, value}
      :error -> {:error, "unexpected output from the Fortran helper: #{text}"}
    end
  end

  defp failure_message(output, status) do
    case String.trim(output) do
      "" -> "the Fortran helper exited with status #{status}"
      detail -> detail
    end
  end

  defp extension() do
    case :os.type() do
      {:win32, _} -> ".exe"
      _ -> ""
    end
  end
end

Main.run(System.argv())
