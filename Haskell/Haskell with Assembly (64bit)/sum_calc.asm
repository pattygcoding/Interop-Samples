section .data
    input_file db 'numbers.txt', 0
    output_file db 'result.txt', 0
    format db '%lf', 0

section .bss
    numbers resq 100  ; Reserve space for up to 100 doubles
    sum resq 1

section .text
    global _start

_start:
    ; Open the input file
    mov rdi, input_file
    call open_file

    ; Read numbers from the file
    mov rdi, numbers
    call read_numbers

    ; Calculate the sum of numbers
    call calculate_sum

    ; Write the sum to the output file
    mov rdi, output_file
    call write_sum

    ; Exit
    call exit_program

open_file:
    ; Open a file (filename in rdi)
    mov rax, 2        ; sys_open
    xor rsi, rsi      ; flags = O_RDONLY
    syscall
    ret

read_numbers:
    ; Read the numbers from the input file into the array
    ; rdi = pointer to array
    mov rsi, rdi
    mov rdx, 100      ; max number of doubles
    mov rax, 0        ; sys_read
    syscall
    ret

calculate_sum:
    ; Calculate the sum of the array
    xor rax, rax      ; rax will store the sum
    mov rcx, 100      ; number of doubles to sum
.sum_loop:
    fld qword [rdi + rax * 8]
    fadd [sum]
    fstp [sum]
    inc rax
    loop .sum_loop
    ret

write_sum:
    ; Write the sum to a file
    mov rax, 1        ; sys_write
    syscall
    ret

exit_program:
    mov rax, 60       ; sys_exit
    xor rdi, rdi      ; status 0
    syscall
    ret
