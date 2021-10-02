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
    add rsi, 8 ; переместили указатель на ключ
    call string_equals ; сравнили ключ в блоке и введённый
    pop rsi ; получили указатель на блок
    pop rdi ; получили указатель на ключ
    cmp rax, 1
    je .success
    .fail:
        cmp [rsi], byte 0 ; если указатель на след. блок нулевой, то мы на последнем блоке - пора заканчивать
        jne .continue ; иначе го на следующий блок
        xor rax, rax
        ret 
    .continue:
        mov rsi, [rsi] ; взяли указатель на следующий блок
        jmp find_word ; пошли делать то же самое для следующего блока
    .success:
        call string_length
        add rsi, 8 ; сместили указатель на блок на 8 - получили указатель на ключ в блоке
        add rsi, rax ; добавили к указателю длину ключа - получили указатель на конец ключа
        inc rsi ; получили указатель на начало значения
        mov rax, rsi
        ret     
