section .data
    input_file db 'numbers.txt', 0
    output_file db 'result.txt', 0
    format db '%lf', 0

section .bss
    numbers resd 100  ; Reserve space for up to 100 floats
    sum resd 1

section .text
    global _start

_start:
    ; Open the input file
    mov eax, 5          ; sys_open (Linux syscall)
    mov ebx, input_file ; filename
    xor ecx, ecx        ; flags = O_RDONLY
    int 0x80            ; interrupt to invoke syscall
    mov ebx, eax        ; save file descriptor

    ; Read the file content into buffer
    mov eax, 3          ; sys_read
    mov ecx, numbers    ; buffer
    mov edx, 400        ; max number of bytes
    int 0x80            ; interrupt to invoke syscall

    ; Calculate the sum of the numbers
    xor eax, eax        ; clear eax for sum
    xor ecx, ecx        ; counter index
    fldz                ; st(0) = 0.0
.sum_loop:
    fld dword [numbers + ecx * 4]
    faddp st1, st0      ; sum = sum + numbers[i]
    inc ecx
    cmp ecx, 5          ; compare counter with number of elements
    jl .sum_loop

    ; Store the result in 'sum'
    fstp dword [sum]

    ; Open the output file
    mov eax, 5          ; sys_open
    mov ebx, output_file
    mov ecx, 2          ; O_WRONLY
    int 0x80

    ; Write the sum to the output file
    mov eax, 4          ; sys_write
    mov edx, 4          ; number of bytes to write
    int 0x80

    ; Exit program
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; status 0
    int 0x80            ; interrupt to invoke syscall
