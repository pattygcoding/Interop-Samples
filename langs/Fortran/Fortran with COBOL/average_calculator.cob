       IDENTIFICATION DIVISION.
       PROGRAM-ID. AVERAGE-CALCULATOR.
      *
      * Interop sample: prints the arithmetic mean of the numbers given on the
      * command line.
      *
      * Invoked by main.f90; see README.md for build and run instructions.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-ARGUMENT-COUNT   PIC 9(4).
       01  WS-ARGUMENT-NUMBER  PIC 9(4).
       01  WS-ARGUMENT         PIC X(32).
       01  WS-VALUE            USAGE IS COMP-2.
       01  WS-TOTAL            USAGE IS COMP-2 VALUE 0.
       01  WS-AVERAGE          USAGE IS COMP-2.
       01  WS-FORMATTED        PIC Z(9)9.99.
       01  WS-OUTPUT           PIC X(16).
       01  WS-INDEX            PIC 9(4).
       PROCEDURE DIVISION.
           ACCEPT WS-ARGUMENT-COUNT FROM ARGUMENT-NUMBER

           IF WS-ARGUMENT-COUNT = 0
               DISPLAY "error: no numbers supplied" UPON STDERR
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF

           PERFORM VARYING WS-INDEX FROM 1 BY 1
                   UNTIL WS-INDEX > WS-ARGUMENT-COUNT
               MOVE WS-INDEX TO WS-ARGUMENT-NUMBER
               ACCEPT WS-ARGUMENT FROM ARGUMENT-VALUE
               MOVE FUNCTION NUMVAL(WS-ARGUMENT) TO WS-VALUE
               ADD WS-VALUE TO WS-TOTAL
           END-PERFORM

           COMPUTE WS-AVERAGE = WS-TOTAL / WS-ARGUMENT-COUNT
           MOVE WS-AVERAGE TO WS-FORMATTED
           MOVE WS-FORMATTED TO WS-OUTPUT
           DISPLAY FUNCTION TRIM(WS-OUTPUT)

           STOP RUN.
