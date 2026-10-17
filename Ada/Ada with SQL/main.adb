--  Interop sample: Ada driving the SQLite command-line shell.
--
--  Ada loads the numbers into an in-memory SQLite database and runs the query in
--  average_calculator.sql, so the mean is computed in SQL.
--
--  See README.md for build and run instructions.

with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;

with GNAT.Expect;            use GNAT.Expect;
with GNAT.OS_Lib;            use GNAT.OS_Lib;

procedure Main is
   Default_Numbers : constant array (Positive range <>) of Float :=
     (10.0, 20.0, 30.0, 40.0, 50.0);

   Max_Numbers : constant := 64;

   Numbers : array (1 .. Max_Numbers) of Float;
   Count   : Natural := 0;

   Sqlite_Arguments : constant Argument_List :=
     (1 => new String'("-batch"),
      2 => new String'(":memory:"));

   --  Render a float in a form SQLite can read. Float'Image inserts a leading
   --  space for non-negative values, so drop it.
   function Image_Of (Value : Float) return String is
      Raw : constant String := Float'Image (Value);
   begin
      if Raw (Raw'First) = ' ' then
         return Raw (Raw'First + 1 .. Raw'Last);
      end if;

      return Raw;
   end Image_Of;

   --  Strip every kind of whitespace, including the newline sqlite3 writes.
   function Trimmed (Text : String) return String is
      First : Positive := Text'First;
      Last  : Natural := Text'Last;

      function Is_Space (Item : Character) return Boolean is
        (Item = ' '
         or else Item = Ada.Characters.Latin_1.LF
         or else Item = Ada.Characters.Latin_1.CR
         or else Item = Ada.Characters.Latin_1.HT);
   begin
      while First <= Last and then Is_Space (Text (First)) loop
         First := First + 1;
      end loop;

      while Last >= First and then Is_Space (Text (Last)) loop
         Last := Last - 1;
      end loop;

      if First > Last then
         return "";
      end if;

      return Text (First .. Last);
   end Trimmed;

   function Is_Number (Text : String) return Boolean is
      Value : Float;
      pragma Unreferenced (Value);
   begin
      Value := Float'Value (Text);
      return True;
   exception
      when Constraint_Error =>
         return False;
   end Is_Number;

   --  Read the committed query file so the SQL stays in one place.
   function Query_File return String is
      File   : Ada.Text_IO.File_Type;
      Line   : String (1 .. 256);
      Last   : Natural;
      Result : Unbounded_String := Null_Unbounded_String;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, "average_calculator.sql");

      while not Ada.Text_IO.End_Of_File (File) loop
         Ada.Text_IO.Get_Line (File, Line, Last);
         Append (Result, Line (1 .. Last));
         Append (Result, Ada.Characters.Latin_1.LF);
      end loop;

      Ada.Text_IO.Close (File);
      return To_String (Result);
   end Query_File;

   Script  : Unbounded_String;
   Output  : Unbounded_String;
   Status  : aliased Integer := 0;
   Average : Float;
begin
   --  1. Collect the numbers from the command line, or fall back to defaults.
   if Ada.Command_Line.Argument_Count = 0 then
      for Value of Default_Numbers loop
         Count := Count + 1;
         Numbers (Count) := Value;
      end loop;
   else
      for I in 1 .. Ada.Command_Line.Argument_Count loop
         declare
            Text : constant String := Ada.Command_Line.Argument (I);
         begin
            if Is_Number (Text) then
               Count := Count + 1;
               Numbers (Count) := Float'Value (Text);
            else
               Ada.Text_IO.Put_Line
                 (Ada.Text_IO.Standard_Error,
                  "warning: skipping non-numeric argument '" & Text & "'");
            end if;
         end;
      end loop;
   end if;

   if Count = 0 then
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error, "error: no numbers to average");
      OS_Exit (1);
   end if;

   --  2. Build the script: load the numbers, then run the committed query.
   Append (Script, "CREATE TABLE numbers (value REAL);");
   Append (Script, Ada.Characters.Latin_1.LF);

   for I in 1 .. Count loop
      Append (Script, "INSERT INTO numbers (value) VALUES (");
      Append (Script, Image_Of (Numbers (I)));
      Append (Script, ");");
      Append (Script, Ada.Characters.Latin_1.LF);
   end loop;

   Append (Script, Query_File);

   Output :=
     To_Unbounded_String
       (Get_Command_Output
          (Command   => "sqlite3",
           Arguments => Sqlite_Arguments,
           Input     => To_String (Script),
           Status    => Status'Access));

   if Status /= 0 then
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error,
         "error: sqlite3 exited with status" & Integer'Image (Status));
      OS_Exit (1);
   end if;

   --  3. Report the result.
   Average := Float'Value (Trimmed (To_String (Output)));

   Ada.Text_IO.Put
     ("The average of" & Natural'Image (Count) & " value(s) is: ");

   if Average < 0.0 then
      Ada.Float_Text_IO.Put (Average, Fore => 2, Aft => 2, Exp => 0);
   else
      Ada.Float_Text_IO.Put (Average, Fore => 1, Aft => 2, Exp => 0);
   end if;

   Ada.Text_IO.New_Line;
end Main;
