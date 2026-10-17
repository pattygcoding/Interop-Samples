Imports System
Imports System.Collections.Generic
Imports System.Diagnostics
Imports System.Globalization

''' <summary>
''' Interop sample: VB.NET driving a compiled D program.
'''
''' VB.NET passes the numbers as command-line arguments to the D helper and reads
''' the average it prints back from stdout.
'''
''' See README.md for build and run instructions.
''' </summary>
Module Program
    ''' <summary>The helper is built beside this project, with .exe on Windows.</summary>
    ReadOnly HelperName As String = If(OperatingSystem.IsWindows(), "average_calculator.exe", "average_calculator")

    Function Main(args As String()) As Integer
        Dim numbers As New List(Of Double)

        If args.Length = 0 Then
            numbers.AddRange({10.0, 20.0, 30.0, 40.0, 50.0})
        Else
            For Each token In args
                Dim value As Double

                If Double.TryParse(token, NumberStyles.Float, CultureInfo.InvariantCulture, value) Then
                    numbers.Add(value)
                Else
                    Console.Error.WriteLine($"warning: skipping non-numeric argument '{token}'")
                End If
            Next
        End If

        If numbers.Count = 0 Then
            Console.Error.WriteLine("error: no numbers to average")
            Return 1
        End If

        Dim startInfo As New ProcessStartInfo(HelperName) With {
            .RedirectStandardOutput = True,
            .RedirectStandardError = True,
            .UseShellExecute = False
        }

        For Each value In numbers
            startInfo.ArgumentList.Add(value.ToString(CultureInfo.InvariantCulture))
        Next

        Dim helper As Process = Process.Start(startInfo)

        Dim output As String = helper.StandardOutput.ReadToEnd()
        Dim errors As String = helper.StandardError.ReadToEnd()

        helper.WaitForExit()

        If helper.ExitCode <> 0 Then
            Dim detail As String = errors.Trim()

            If String.IsNullOrEmpty(detail) Then
                Console.Error.WriteLine($"error: the D helper exited with code {helper.ExitCode}")
            Else
                Console.Error.WriteLine($"error: {detail}")
            End If

            Return 1
        End If

        Dim average As Double

        If Not Double.TryParse(output.Trim(), NumberStyles.Float, CultureInfo.InvariantCulture, average) Then
            Console.Error.WriteLine($"error: unexpected output from the D helper: '{output.Trim()}'")
            Return 1
        End If

        ' Invariant culture keeps the decimal separator machine-independent.
        Console.Out.WriteLine(
            $"The average of {numbers.Count} value(s) is: {average.ToString("F2", CultureInfo.InvariantCulture)}"
        )

        Return 0
    End Function
End Module
