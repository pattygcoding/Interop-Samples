; ---------------------------------------------------------------------------
; calculate_average - arithmetic mean of a signed 32-bit integer array.
;
;   The routine adapts to the target object format, so a single source file
;   builds for both Linux (System V AMD64 ABI) and Windows (Microsoft x64 ABI):
;
;       Linux / macOS : rdi = numbers, rsi = count   -> returns in xmm0
;       Windows       : rcx = numbers, rdx = count   -> returns in xmm0
;
;   An empty array (count <= 0) returns 0.0 instead of dividing by zero.
; ---------------------------------------------------------------------------

global calculate_average

%ifidn __OUTPUT_FORMAT__, win64
    %define NUMBERS rcx
    %define COUNT   edx
%else
    %define NUMBERS rdi
    %define COUNT   esi
%endif

section .text

calculate_average:
    pxor xmm0, xmm0                 ; sum = 0.0
    test COUNT, COUNT
    jle  .empty

    mov  r8, NUMBERS                ; r8  = pointer to the array
    mov  r9d, COUNT                 ; r9d = remaining element count

.loop:
    cvtsi2sd xmm1, dword [r8]       ; xmm1 = (double)*r8
    addsd    xmm0, xmm1             ; sum += value
    add      r8, 4                  ; advance to the next int (32-bit)
    dec      r9d
    jnz      .loop

    cvtsi2sd xmm1, COUNT            ; xmm1 = (double)count
    divsd    xmm0, xmm1             ; xmm0 = sum / count

.empty:
    ret

%ifidn __OUTPUT_FORMAT__, elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

