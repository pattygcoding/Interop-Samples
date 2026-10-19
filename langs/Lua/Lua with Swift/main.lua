-- Interop sample: Lua driving a compiled Swift program.
--
-- Lua passes the numbers as command-line arguments to the Swift helper and reads
-- the average it prints back through a pipe.
--
-- See README.md for build and run instructions.

-- Windows needs the extension and a bare name; Unix needs the ./ prefix.
local EXECUTABLE = package.config:sub(1, 1) == "\\" and "average_calculator.exe"
  or "./average_calculator"

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

local parts = { EXECUTABLE }

for _, value in ipairs(numbers) do
  parts[#parts + 1] = tostring(value)
end

local pipe = io.popen(table.concat(parts, " "), "r")
if not pipe then
  io.stderr:write("error: could not run the Swift helper\n")
  os.exit(1)
end

local output = pipe:read("*a")
local ok = pipe:close()

if not ok then
  io.stderr:write("error: the Swift helper exited with an error\n")
  os.exit(1)
end

local average = tonumber(output)
if not average then
  io.stderr:write(("error: unexpected output from the Swift helper: %s\n"):format(output))
  os.exit(1)
end

print(("The average of %d value(s) is: %.2f"):format(#numbers, average))
