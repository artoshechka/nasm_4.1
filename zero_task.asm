global _start

section .data
    userStartMsg:           db "Enter 3 strNumbers to find maximum, and print it's difference from other strNums",10
    lenUserStartMsg         equ $-userStartMsg
    strNumberEntrenceMsg:   db "Enter strNumber: "
    lenstrNumberEntrenceMsg equ $-strNumberEntrenceMsg
    strNumsSize             equ 256
    numsSize                equ 256

section .bss
    numA    resb numsSize
    numB    resb numsSize
    numC    resb numsSize
    strNumA resb strNumsSize
    strNumB resb strNumsSize
    strNumC resb strNumsSize
    
section .text

_start:
    ;Вывод сообщения стратового
    mov rsi, userStartMsg
    mov rdx, lenUserStartMsg
    call FuncStartMsg

    ;Вывод сообщения о вводе числа A
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncStartMsg

    ;Ввод числа A в формате строки
    mov rsi, strNumA
    mov rdx, strNumsSize
    call FuncReadString

    ;Вывод сообщения о вводе числа B
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncStartMsg

    ;Ввод числа B в формате строки
    mov rsi, strNumB
    mov rdx, strNumsSize
    call FuncReadString

    ;Вывод сообщения о вводе числа C
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncStartMsg

    ;Ввод числа C в формате строки
    mov rsi, strNumC
    mov rdx, strNumsSize
    call FuncReadString

    ;Перевод строки числа А в число
    mov rsi, strNumA
    mov [numA], rax

    ;Перевод строки числа B в число
    mov rsi, strNumB
    mov [numB], rax

    ;Перевод строки числа C в число
    mov rsi, strNumC
    mov [numC], rax

    ;Завершение программы
    xor rdi, rdi
    call FuncEnd

FuncEnd:
; Функция завершения работы
    mov rax, 60
    syscall

FuncStartMsg:
;Функция для вывода сообщения в косоль. Ожидается выводимое значение в rcx, а его длина в rdx
    mov rax, 1
    mov rdi, 1
    syscall
    ret

FuncReadString:
;Функция для считывания числа в формате строки. Ожидается переменная для значения в rsi, а его длина в rdx
    mov rax, 0
    mov rdi, 0
    syscall
    ret

FuncStrToInt:
;Функция перевода из строки в число. Ожидается строка для конвертации в rsi, результат будет в eax
        xor rax, rax        ; итоговое число
        xor rcx, rcx        ; индекс в строке
        xor rbx, rbx        ; знак

    .loop:
        mov bl, byte [rsi + rcx]  ; читаем символ
        cmp bl, 0xA               ; проверяем на \n
        je .done
        cmp bl, 0
        je .done
        cmp bl, '-'               ; проверка на знак минус
        jne .checkDigit
        mov rbx, 1                
        inc rcx
        jmp .loop

    .checkDigit:
        cmp bl, '0'
        jl .inputError
        cmp bl, '9'
        jg .inputError

        sub bl, '0'               
        imul rax, rax, 10
        movzx rdx, bl
        add rax, rdx
        inc rcx
        jmp .loop
    
    .inputError:
        mov rdi, 1
        call FuncEnd

    .done:
        test rbx, rbx
        jz .exit
        neg rax

    .exit:
        ret