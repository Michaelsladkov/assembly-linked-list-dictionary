%include "colon.inc"
global _start
%include "lib.inc"
%include "dict.inc"
%include "words.inc"
section .rodata
input_greet: db 'enter key to search: ', 0
input_fail_message: db 'your key is not valid (empty or too long)', 0
find_fail_message: db 'nothing found for this key', 0

section .data
input_buffer: times 256 db 0

section .text
_start:
    mov rdi, input_greet
    call print_err ; выводим в stderr вспомогательное сообщение - приглашение к вводу
    mov rsi, 256
    mov rdi, input_buffer
    call read_word ; читаем ключ в буфер из 256 символов
    test rax, rax 
    jz .input_fail ; если вернулся ноль - ключ оказалсся слишком длинным или нудевым
    mov rdi, input_buffer ; указатель на ключ -> rdi
    mov rsi, NEXT_ELEM ; указатель на словарь -> rsi
    call find_word
    test rax, rax
    jz .find_fail ; если вернулся 0, ничего не нашли
    mov rdi, rax
    call print_string
    call print_newline_std_err ; перевод строки в err, чтобы не мешать использовать программу как утилиту
    xor rdi, rdi
    call exit

.find_fail:
    mov rdi, find_fail_message
    call print_err
    call print_newline_std_err
    mov rdi, 3
    call exit
.input_fail:
    mov rdi, input_fail_message
    call print_err
    call print_newline_std_err
    mov rdi, 2
    call exit