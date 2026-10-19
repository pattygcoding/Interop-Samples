; ---------------------------------------------------------------------------
; sum_calc - adds the integers stored in one file and writes the total to
; another file.
;
;   Usage  : sum_calc <input-file> <output-file>
;   Input  : decimal integers separated by spaces, tabs or newlines
;   Output : the sum, followed by a newline
;
;   Build  : nasm -f elf32 sum_calc.asm -o sum_calc.o
;            ld -m elf_i386 sum_calc.o -o sum_calc
;
;   Targets Linux i386 and talks to the kernel directly through int 0x80 -
;   it does not link against libc.
;
;   Invoked by main.hs; see README.md for build and run instructions.
; ---------------------------------------------------------------------------

%define SYS_EXIT   1
%define SYS_READ   3
%define SYS_WRITE  4
%define SYS_OPEN   5
%define SYS_CLOSE  6

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
nread   resd 1
total   resd 1
out_ptr resd 1
out_len resd 1

section .text
    global _start

_start:
    mov  ebp, esp
    cmp  dword [ebp], 3
    jl   .usage

    mov  edi, [ebp + 8]             ; argv[1] = input path
    mov  esi, [ebp + 12]            ; argv[2] = output path

    ; --- read the whole input file ----------------------------------------
    mov  eax, SYS_OPEN
    mov  ebx, edi
    xor  ecx, ecx                   ; O_RDONLY
    int  0x80
    test eax, eax
    js   .error
    mov  ebx, eax                   ; input fd

    mov  eax, SYS_READ
    mov  ecx, buf
    mov  edx, 4096
    int  0x80
    test eax, eax
    js   .error
    mov  [nread], eax

    mov  eax, SYS_CLOSE
    int  0x80                       ; ebx still holds the fd

    ; --- parse the integers and accumulate the sum ------------------------
    xor  ecx, ecx                   ; index into buf
    mov  dword [total], 0

.parse:
    cmp  ecx, [nread]
    jge  .format

    movzx eax, byte [buf + ecx]

    cmp  al, ' '
    je   .skip
    cmp  al, 10
    je   .skip
    cmp  al, 13
    je   .skip
    cmp  al, 9
    je   .skip

    xor  edi, edi                   ; assume positive
    cmp  al, '-'
    jne  .maybe_digit
    mov  edi, 1
    inc  ecx
    cmp  ecx, [nread]
    jge  .format
    movzx eax, byte [buf + ecx]

.maybe_digit:
    cmp  al, '0'
    jb   .skip
    cmp  al, '9'
    ja   .skip

    xor  edx, edx                   ; value accumulator
.digit_loop:
    imul edx, edx, 10
    sub  al, '0'
    movzx eax, al
    add  edx, eax
    inc  ecx
    cmp  ecx, [nread]
    jge  .apply
    movzx eax, byte [buf + ecx]
    cmp  al, '0'
    jb   .apply
    cmp  al, '9'
    ja   .apply
    jmp  .digit_loop

.apply:
    test edi, edi
    jz   .add
    neg  edx
.add:
    add  [total], edx
    jmp  .parse

.skip:
    inc  ecx
    jmp  .parse

    ; --- render the total as decimal and write it out ---------------------
.format:
    mov  eax, [total]
    lea  ecx, [out_buf + 31]
    mov  byte [ecx], 10             ; trailing newline
    dec  ecx

    xor  edi, edi
    test eax, eax
    jns  .convert
    neg  eax
    mov  edi, 1

.convert:
    mov  ebx, 10
.convert_loop:
    xor  edx, edx
    div  ebx                        ; eax = quotient, edx = remainder
    add  dl, '0'
    mov  [ecx], dl
    dec  ecx
    test eax, eax
    jnz  .convert_loop

    test edi, edi
    jz   .write
    mov  byte [ecx], '-'
    dec  ecx

.write:
    inc  ecx                        ; ecx -> first character
    mov  [out_ptr], ecx
    lea  edx, [out_buf + 32]
    sub  edx, ecx
    mov  [out_len], edx

    mov  eax, SYS_OPEN
    mov  ebx, esi                   ; output path
    mov  ecx, O_WRONLY_CREAT_TRUNC
    mov  edx, MODE_0644
    int  0x80
    test eax, eax
    js   .error
    mov  ebx, eax                   ; output fd

    mov  eax, SYS_WRITE
    mov  ecx, [out_ptr]
    mov  edx, [out_len]
    int  0x80

    mov  eax, SYS_CLOSE
    int  0x80

    mov  eax, SYS_EXIT
    xor  ebx, ebx
    int  0x80

.usage:
    mov  eax, SYS_WRITE
    mov  ebx, 2
    mov  ecx, usage_msg
    mov  edx, usage_len
    int  0x80
    mov  eax, SYS_EXIT
    mov  ebx, 1
    int  0x80

.error:
    mov  eax, SYS_WRITE
    mov  ebx, 2
    mov  ecx, error_msg
    mov  edx, error_len
    int  0x80
    mov  eax, SYS_EXIT
    mov  ebx, 1
    int  0x80

section .note.GNU-stack noalloc noexec nowrite progbits

