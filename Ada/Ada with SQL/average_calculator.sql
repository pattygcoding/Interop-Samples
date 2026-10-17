-- Interop sample: computes the arithmetic mean of the values in the `numbers`
-- table.
--
-- The table is created and populated by main.adb, which feeds this file's text
-- to the `sqlite3` shell. See README.md for build and run instructions.

SELECT AVG(value) FROM numbers;
