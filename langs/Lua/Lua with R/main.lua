-- Interop sample: Lua driving an R script.
--
-- Lua passes the numbers as command-line arguments to `average_calculator.R`
-- and reads the average R prints back through a pipe.
--
-- See README.md for build and run instructions.

local SCRIPT = "average_calculator.R"

local function parse_numbers(tokens)
  local numbers = {}

  for _, token in ipairs(tokens) do
    local value = tonumber(token)
    if value then
      numbers[#numbers + 1] = value
    else
      io.stderr:write(("warning: skipping non-numeric argument '%s'\n"):format(token))
    end
  end

  return numbers
end

local function build_command(numbers)
  local parts = { "Rscript", SCRIPT }
  for _, value in ipairs(numbers) do
    parts[#parts + 1] = tostring(value)
  end
  return table.concat(parts, " ")
end

local numbers

if #arg > 0 then
  numbers = parse_numbers(arg)
else
  numbers = { 10, 20, 30, 40, 50 }
end

if #numbers == 0 then
  io.stderr:write("error: no numbers to average\n")
  os.exit(1)
end

local pipe = io.popen(build_command(numbers), "r")
if not pipe then
  io.stderr:write("error: could not run Rscript\n")
  os.exit(1)
end

local output = pipe:read("*a")
local ok = pipe:close()

if not ok then
  io.stderr:write("error: the R helper exited with an error\n")
  os.exit(1)
end

local average = tonumber(output)
if not average then
  io.stderr:write(("error: unexpected output from R: %s\n"):format(output))
  os.exit(1)
end

print(("The average of %d value(s) is: %.2f"):format(#numbers, average))
