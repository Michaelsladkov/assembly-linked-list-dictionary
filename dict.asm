global find_word
extern string_equals
extern string_length
extern print_err
extern print_newline

section .text
; указатель на строку, по которой мы ищем -> rdi
; указатель на начало словаря -> rsi
find_word:
    push rdi
    push rsi
    add rsi, 8

    ;кусок для дебага эквивалентности строк
    push rsi
    push rdi
    call print_err
    call print_newline
    mov rdi, rsi
    call print_err
    call print_newline
    pop rdi
    pop rsi

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
