section .data

section .text
global calculate_average

; Function: calculate_average
; Arguments:
;   rdi - pointer to the array of integers
;   rsi - count of the array elements
; Return:
;   xmm0 - calculated average (double)

calculate_average:
    ; Initialize sum to 0
    pxor xmm0, xmm0       ; clear xmm0 (used to store sum)
    mov rcx, rsi          ; move count to rcx for the loop

.loop:
    ; Check if the loop is done
    test rcx, rcx
    jz .done

    ; Load the next integer from the array and add it to the sum
    mov eax, [rdi + 4*(rcx-1)]  ; load integer from the array
    cvtsi2sd xmm1, eax           ; convert int to double and store in xmm1
    addsd xmm0, xmm1             ; add xmm1 to xmm0 (sum += number)

    ; Decrement loop counter
    dec rcx
    jmp .loop

.done:
    ; Calculate the average by dividing the sum by the count
    cvtsi2sd xmm1, rsi           ; convert count to double and store in xmm1
    divsd xmm0, xmm1             ; divide sum by count (xmm0 /= xmm1)

    ret
