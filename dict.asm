global find_word
extern string_equals
extern string_length
section .text
; указатель на строку, по которой мы ищем -> rdi
; указатель на начало словаря -> rsi
find_word:
    push rdi
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    pop rdi
    cmp rax, 1
    je .success
    .fail:
        cmp [rsi], byte 0
        jne .continue
        xor rax, rax
        ret 
    .continue:
        mov rsi, [rsi]
        jmp find_word
    .success:
        call string_length
        add rsi, rax
        add rsi, 8
        mov rax, rsi
        ret     
