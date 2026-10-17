-- Interop sample: prints the arithmetic mean of the numbers given on the
-- command line.
--
-- Invoked by main.clj; see README.md for build and run instructions.

if #arg == 0 then
  io.stderr:write("error: no numbers supplied\n")
  os.exit(1)
end

local total = 0

for _, token in ipairs(arg) do
  local value = tonumber(token)

  if not value then
    io.stderr:write(("error: '%s' is not a number\n"):format(token))
    os.exit(1)
  end

  total = total + value
end

print(("%.2f"):format(total / #arg))
