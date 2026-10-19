! Interop sample: prints the arithmetic mean of the numbers given on the
! command line.
!
! Diagnostics go to stdout rather than stderr so the host program, which only
! captures stdout, can report them.
!
! Invoked by main.exs; see README.md for build and run instructions.

program average_calculator
    implicit none

    integer, parameter :: max_numbers = 64

    real :: numbers(max_numbers)
    integer :: count
    integer :: i
    integer :: status
    character(len=64) :: buffer
    real :: value

    count = 0

    do i = 1, command_argument_count()
        call get_command_argument(i, buffer)
        read (buffer, *, iostat=status) value

        if (status /= 0) then
            write (*, '(A)') 'error: ' // trim(buffer) // ' is not a number'
            stop 1
        end if

        count = count + 1
        numbers(count) = value
    end do

    if (count == 0) then
        write (*, '(A)') 'error: no numbers supplied'
        stop 1
    end if

    write (*, '(F0.2)') sum(numbers(1:count)) / count
end program average_calculator
