global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global read_char
global read_word
global parse_uint
global parse_int
global string_equals
global string_copy
global print_err


section .data
newline: db 10
dec_numbers: db '0123456789'
section .text
 
 
; Принимает код возврата и завершает текущий процесс
exit:
    mov rax, 60 
    syscall
    ret 

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
    .loop:
        cmp byte [rdi + rax], 0
        je .end
        inc rax
        jmp .loop
    .end:    
        ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi
    call string_length
    pop rdi
    mov rsi, rdi
    mov rdi, 1
    mov rdx, rax
    mov rax, 1
    syscall
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stderr
print_err:
    push rdi
    call string_length
    pop rdi
    mov rsi, rdi
    mov rdi, 2
    mov rdx, rax
    mov rax, 1
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    xor rax, rax
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rax, 1
    mov rdi, 1;
    mov rsi, newline
    mov rdx, 1
    syscall
    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r10, 10
    mov rax, rdi
    push 0
    .div_loop:
        xor rdx, rdx
        div r10
        add rdx, '0'
        push rdx
        cmp rax, 0
        je .print_loop
        jmp .div_loop
    .print_loop:
        pop rdi
        cmp rdi, 0
        je .end
        call print_char
        jmp .print_loop
    .end:
        ret         

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    cmp rdi, 0
    jns .print_uns
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    .print_uns:
        call print_uint
    ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
; str1 -> rdi
; str2 -> rsi
string_equals:
    .compare_char:
        mov al, byte [rsi]
        cmp al, byte [rdi]
        jne .not_eq
        cmp al, 0
        je .eq
        inc rsi
        inc rdi
        jmp .compare_char
    .not_eq:
        xor rax, rax
        ret
    .eq:
        xor rax, rax
        inc rax
        ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    xor rdi, rdi
    xor rax, rax
    push 0
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rax
    ret 

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
; адрес буфера в rdi, размер в rsi
read_word:
    push rdi
    push rsi
    .read_before_word:
        call read_char
        cmp al, 0x20
        je .read_before_word
        cmp al, 0x9
        je .read_before_word
        cmp al, 0xa
        je .read_before_word
    pop r11 ; размер буфера в r11
    pop r10 ; адрес буфера в r10
    push r13
    xor r13, r13   
    .read_word:
        cmp r11, r13
        je .fail
        mov byte[r10+r13], al
        cmp al, 0x20
        je .end
        cmp al, 0x9
        je .end
        cmp al, 0xa
        je .end
        cmp al, 0
        je .end
        inc r13

        push r10
        push r11
        call read_char
        pop r11
        pop r10

        jmp .read_word  
    .fail:
        pop r13
        xor rax, rax
        ret     
    .end:
        mov byte[r10+r13], 0
        mov rax, r10
        mov rdx, r13
        pop r13
        ret 

; Принимает указатель на строку в rdi, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    mov al, byte[rdi]
    cmp al, '0'
    jl .fail
    cmp al, '9'
    jg .fail
    push rdi ;сохраняем на стеке изначальное значение указателя, чтобы потом посчитать длину
    xor rax, rax
    mov rcx, 10
    .parse_loop:
        xor r10, r10
        mov r10b, byte[rdi]
        cmp r10b, '0'
        jl .end
        cmp r10b, '9'
        jg .end
        inc rdi
        sub r10b, '0'
        mul rcx
        add rax, r10
        jmp .parse_loop
    .end:
        pop rdx
        sub rdx, rdi
        neg rdx
        ret
    .fail:
        xor rax, rax
        xor rdx, rdx
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    mov al, byte[rdi]
    cmp al, '-'
    jne .parse_positive
    inc rdi
    mov al, byte[rdi]
    cmp al, '0'
    jl .fail
    cmp al, '9'
    jg .fail
    call parse_uint
    neg rax
    inc rdx
    ret
    .parse_positive:
        call parse_uint
        ret   
    .fail:
        xor rax, rax
        xor rdx, rdx
        ret    

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor rax, rax
    push rdi
    push rsi ;сохранение этих регистров не обяхательно в данной реалихаци,
    push rdx ;но рекомендовано соглашением и позволяет менять реализацию string_length
    call string_length
    pop rdx
    pop rsi
    pop rdi
    cmp rdx, rax ; Проверяем, что буфер имеет достаточный размер
    jb .fail
    xor rax, rax
    .loop:
        xor r10, r10
        mov r10b, byte[rdi]
        mov byte[rsi], r10b
        cmp r10, 0
        je .end
        inc rax
        inc rdi 
        inc rsi
        jmp .loop
    .fail:
        xor rax, rax
        ret
    .end:
        ret
