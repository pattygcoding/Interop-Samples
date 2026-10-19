Imports System
Imports System.Collections.Generic
Imports System.Globalization

''' <summary>
''' Interop sample: prints the arithmetic mean of the numbers given on the
''' command line.
'''
''' Invoked by main.sh; see README.md for build and run instructions.
''' </summary>
Module Program
    Function Main(args As String()) As Integer
        If args.Length = 0 Then
            Console.Error.WriteLine("error: no numbers supplied")
            Return 1
        End If

        Dim numbers As New List(Of Double)

        For Each token In args
            Dim value As Double

            If Double.TryParse(token, NumberStyles.Float, CultureInfo.InvariantCulture, value) Then
                numbers.Add(value)
            Else
                Console.Error.WriteLine($"error: '{token}' is not a number")
                Return 1
            End If
        Next

        Dim sum As Double = 0.0

        For Each value In numbers
            sum += value
        Next

        ' Invariant culture keeps the decimal separator machine-independent, and
        ' the shell has no way to format floats, so format here.
        Console.Out.WriteLine((sum / numbers.Count).ToString("0.00", CultureInfo.InvariantCulture))
        Return 0
    End Function
End Module
