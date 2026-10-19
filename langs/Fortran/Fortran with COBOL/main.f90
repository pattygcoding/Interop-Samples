! Interop sample: Fortran driving a compiled COBOL program.
!
! Fortran writes the numbers onto the COBOL helper's command line, runs it with
! its output redirected to a file, and reads the average back.
!
! See README.md for build and run instructions.

program main
    implicit none

    integer, parameter :: max_numbers = 64
    real, parameter :: default_numbers(5) = [10.0, 20.0, 30.0, 40.0, 50.0]

    character(len=*), parameter :: executable = './average_calculator'
    character(len=*), parameter :: result_file = 'average_result.txt'

    real :: numbers(max_numbers)
    integer :: count
    integer :: i
    integer :: status
    integer :: unit
    character(len=1024) :: command
    character(len=256) :: buffer
    character(len=64) :: line
    real :: average

    ! --- collect the numbers -------------------------------------------------
    count = 0

    if (command_argument_count() == 0) then
        do i = 1, size(default_numbers)
            count = count + 1
            numbers(count) = default_numbers(i)
        end do
    else
        do i = 1, command_argument_count()
            call get_command_argument(i, buffer)
            call parse_number(buffer, numbers, count)
        end do
    end if

    if (count == 0) then
        write (*, '(A)') 'error: no numbers to average'
        stop 1
    end if

    ! --- build and run the helper -------------------------------------------
    command = executable

    do i = 1, count
        write (buffer, '(F0.6)') numbers(i)
        command = trim(command) // ' ' // trim(adjustl(buffer))
    end do

    command = trim(command) // ' > ' // result_file

    call execute_command_line(trim(command), wait=.true., exitstat=status)

    if (status /= 0) then
        write (*, '(A, I0)') 'error: the COBOL helper exited with status ', status
        stop 1
    end if

    ! --- read the result -----------------------------------------------------
    open (newunit=unit, file=result_file, status='old', action='read', iostat=status)

    if (status /= 0) then
        write (*, '(A)') 'error: the COBOL helper produced no output'
        stop 1
    end if

    read (unit, '(A)') line
    close (unit, status='delete')

    read (line, *, iostat=status) average

    if (status /= 0) then
        write (*, '(A)') 'error: unexpected output from the COBOL helper: ' // trim(line)
        stop 1
    end if

    write (*, '(A, I0, A, F0.2)') 'The average of ', count, ' value(s) is: ', average

contains

    ! Convert one command-line token to a number, skipping anything invalid.
    subroutine parse_number(text, values, tally)
        character(len=*), intent(in) :: text
        real, intent(inout) :: values(:)
        integer, intent(inout) :: tally

        real :: value
        integer :: ios

        read (text, *, iostat=ios) value

        if (ios /= 0) then
            write (*, '(A)') 'warning: skipping non-numeric argument ' // trim(text)
            return
        end if

        if (tally >= size(values)) then
            write (*, '(A)') 'error: too many numbers'
            stop 1
        end if

        tally = tally + 1
        values(tally) = value
    end subroutine parse_number

end program main
