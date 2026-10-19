; ---------------------------------------------------------------------------
; sum_calc - adds the integers stored in one file and writes the total to
; another file.
;
;   Usage  : sum_calc <input-file> <output-file>
;   Input  : decimal integers separated by spaces, tabs or newlines
;   Output : the sum, followed by a newline
;
;   Build  : nasm -f elf64 sum_calc.asm -o sum_calc.o
;            ld sum_calc.o -o sum_calc
;
;   Targets Linux x86-64 and talks to the kernel directly through the syscall
;   instruction - it does not link against libc.
;
;   Invoked by main.hs; see README.md for build and run instructions.
; ---------------------------------------------------------------------------

default rel

%define SYS_READ   0
%define SYS_WRITE  1
%define SYS_OPEN   2
%define SYS_CLOSE  3
%define SYS_EXIT   60

%define O_RDONLY             0
%define O_WRONLY_CREAT_TRUNC 0x241      ; O_WRONLY | O_CREAT | O_TRUNC
%define MODE_0644            0o644

section .rodata
usage_msg db 'usage: sum_calc <input-file> <output-file>', 10
usage_len equ $ - usage_msg
error_msg db 'sum_calc: cannot open file', 10
error_len equ $ - error_msg

section .bss
buf     resb 4096
out_buf resb 32

section .text
    global _start

_start:
    mov  rbx, [rsp]                 ; argc
    cmp  rbx, 3
    jl   .usage

    mov  r12, [rsp + 16]            ; argv[1] = input path
    mov  r13, [rsp + 24]            ; argv[2] = output path

    ; --- read the whole input file ----------------------------------------
    mov  eax, SYS_OPEN
    mov  rdi, r12
    mov  esi, O_RDONLY
    xor  edx, edx
    syscall
    test rax, rax
    js   .error
    mov  r14, rax                   ; input fd

    mov  eax, SYS_READ
    mov  rdi, r14
    lea  rsi, [buf]
    mov  edx, 4096
    syscall
    test rax, rax
    js   .error
    mov  r15, rax                   ; bytes read

    mov  eax, SYS_CLOSE
    mov  rdi, r14
    syscall

    ; --- parse the integers and accumulate the sum ------------------------
    xor  rcx, rcx                   ; index into buf
    xor  r8,  r8                    ; running total
    xor  r9,  r9                    ; sign flag

.parse:
    cmp  rcx, r15
    jge  .format

    movzx eax, byte [buf + rcx]

    cmp  al, ' '
    je   .skip
    cmp  al, 10
    je   .skip
    cmp  al, 13
    je   .skip
    cmp  al, 9
    je   .skip

    xor  r9, r9                     ; assume positive
    cmp  al, '-'
    jne  .maybe_digit
    mov  r9, 1
    inc  rcx
    cmp  rcx, r15
    jge  .format
    movzx eax, byte [buf + rcx]

.maybe_digit:
    cmp  al, '0'
    jb   .skip
    cmp  al, '9'
    ja   .skip

    xor  r10, r10                   ; value accumulator
.digit_loop:
    imul r10, r10, 10
    sub  al, '0'
    add  r10, rax
    inc  rcx
    cmp  rcx, r15
    jge  .apply
    movzx eax, byte [buf + rcx]
    cmp  al, '0'
    jb   .apply
    cmp  al, '9'
    ja   .apply
    jmp  .digit_loop

.apply:
    test r9, r9
    jz   .add
    neg  r10
.add:
    add  r8, r10
    jmp  .parse

.skip:
    inc  rcx
    jmp  .parse

    ; --- render the total as decimal and write it out ---------------------
.format:
    lea  rcx, [out_buf + 31]
    mov  byte [rcx], 10             ; trailing newline
    dec  rcx

    mov  rax, r8
    xor  r9, r9
    test rax, rax
    jns  .convert
    neg  rax
    mov  r9, 1

.convert:
    mov  rbx, 10
.convert_loop:
    xor  rdx, rdx
    div  rbx                        ; rax = quotient, rdx = remainder
    add  dl, '0'
    mov  [rcx], dl
    dec  rcx
    test rax, rax
    jnz  .convert_loop

    test r9, r9
    jz   .write
    mov  byte [rcx], '-'
    dec  rcx

.write:
    inc  rcx                        ; rcx -> first character
    mov  r14, rcx                   ; buffer pointer
    lea  rax, [out_buf + 32]
    sub  rax, rcx
    mov  r15, rax                   ; length

    mov  eax, SYS_OPEN
    mov  rdi, r13
    mov  esi, O_WRONLY_CREAT_TRUNC
    mov  edx, MODE_0644
    syscall
    test rax, rax
    js   .error
    mov  rdi, rax                   ; output fd

    mov  eax, SYS_WRITE
    mov  rsi, r14
    mov  rdx, r15
    syscall

    mov  eax, SYS_CLOSE
    syscall

    mov  eax, SYS_EXIT
    xor  edi, edi
    syscall

.usage:
    mov  eax, SYS_WRITE
    mov  edi, 2
    lea  rsi, [usage_msg]
    mov  edx, usage_len
    syscall
    mov  eax, SYS_EXIT
    mov  edi, 1
    syscall

.error:
    mov  eax, SYS_WRITE
    mov  edi, 2
    lea  rsi, [error_msg]
    mov  edx, error_len
    syscall
    mov  eax, SYS_EXIT
    mov  edi, 1
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits

