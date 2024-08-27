section .data

section .text
global calculate_average

; Function: calculate_average
; Arguments:
;   - [esp+4] -> pointer to the array of integers
;   - [esp+8] -> count of the array elements
; Return:
;   - ST(0) -> calculated average (double)

calculate_average:
    ; Prologue
    push ebp
    mov ebp, esp
    fldz                    ; Load 0.0 into the FPU register stack (ST(0) = 0.0)

    mov ecx, [ebp+8]        ; Load count into ecx
    mov edx, [ebp+4]        ; Load pointer to array into edx

.loop:
    ; Check if the loop is done
    test ecx, ecx
    jz .done

    ; Load the next integer from the array and add it to the sum
    fld dword [edx + 4*(ecx-1)] ; Load integer as float onto FPU stack
    faddp st1, st0              ; Add ST(0) to ST(1) and pop

    ; Decrement loop counter
    dec ecx
    jmp .loop

.done:
    ; Calculate the average by dividing the sum by the count
    mov eax, [ebp+8]            ; Load count into eax
    cdq                         ; Sign-extend eax to edx:eax
    fld1                        ; Load 1.0 onto the FPU stack
    fidiv dword [ebp+8]         ; Divide ST(0) by count

    ; Epilogue
    leave
    ret
