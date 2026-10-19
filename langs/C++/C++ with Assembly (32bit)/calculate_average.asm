; ---------------------------------------------------------------------------
; calculate_average - arithmetic mean of a signed 32-bit integer array.
;
;   Calling convention : cdecl (32-bit x86). The argument layout is identical
;                        on Linux and Windows; only the symbol decoration
;                        differs, so the target format selects the symbol name.
;
;       [ebp +  8] = const int *numbers
;       [ebp + 12] = int count
;
;   Returns ST(0) = mean (IEEE-754 double).
;   An empty array (count <= 0) returns 0.0 instead of dividing by zero.
; ---------------------------------------------------------------------------

%ifidn __OUTPUT_FORMAT__, win32
    global _calculate_average
    %define SYMBOL _calculate_average
%else
    global calculate_average
    %define SYMBOL calculate_average
%endif

section .text

SYMBOL:
    push ebp
    mov  ebp, esp

    mov  ecx, [ebp + 12]            ; ecx = count
    mov  edx, [ebp + 8]             ; edx = pointer to the array
    test ecx, ecx
    jle  .empty

    fldz                            ; st0 = 0.0  (running sum)

.loop:
    fild dword [edx]                ; st0 = numbers[i], st1 = sum
    faddp st1, st0                  ; sum += numbers[i]
    add  edx, 4                     ; advance to the next int (32-bit)
    dec  ecx
    jnz  .loop

    fild dword [ebp + 12]           ; st0 = count, st1 = sum
    fdivp st1, st0                  ; st0 = sum / count
    leave
    ret

.empty:
    fldz                            ; return 0.0
    leave
    ret

%ifidn __OUTPUT_FORMAT__, elf32
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

