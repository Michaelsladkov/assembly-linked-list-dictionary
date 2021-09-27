%include "colon.inc"
global _start
extern exit
extern print_string
extern find_word
extern read_word
extern print_newline
extern print_err

%include "words.inc"
section .rodata
input_greet: db 'enter key to search: ', 0
input_fail_message: db 'your input is too big', 0
find_fail_message: db 'nothing found for this key', 0

section .data
input_buffer: times 256 db 0

section .text
_start:
    mov rdi, input_greet
    call print_string
    mov rsi, 256
    mov rdi, input_buffer
    call read_word

    ;кусок для дебага на считывании ключа
    push rax
    mov rdi, input_buffer
    call print_err
    call print_newline
    call print_newline
    pop rax

    test rax, rax
    jz .input_fail
    mov rdi, input_buffer
    mov rsi, NEXT_ELEM
    call find_word
    test rax, rax
    jz .find_fail
    mov rdi, rax
    push rdi
    call print_newline
    pop rdi
    call print_string
    xor rdi, rdi
    call exit

.find_fail:
    mov rdi, find_fail_message
    call print_err
    mov rdi, 3
    call exit
.input_fail:
    mov rdi, input_fail_message
    call print_err
    mov rdi, 2
    call exit