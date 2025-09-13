global _start

section .data
    userStartMsg:           db "Введите 3 числа для поиска максимума и вывода разницы с другими числами",10
    lenUserStartMsg         equ $-userStartMsg
    strNumberEntrenceMsg:   db "Введите число: "
    lenstrNumberEntrenceMsg equ $-strNumberEntrenceMsg
    differenceMsg:          db "Разницы: "
    lenDifferenceMsg        equ $-differenceMsg
    strNumsSize             equ 256
    numsSize                equ 8
    space                   db " "
    buffer                  times 21 db 0

section .bss
    numA    resq numsSize
    numB    resq numsSize
    numC    resq numsSize
    strNumA resb strNumsSize
    strNumB resb strNumsSize
    strNumC resb strNumsSize
    maxNum  resq numsSize

section .text

_start:
    ; Вывод стартового сообщения
    mov rsi, userStartMsg
    mov rdx, lenUserStartMsg
    call FuncPrintMsg

    ; Ввод числа A
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncPrintMsg
    mov rsi, strNumA
    mov rdx, strNumsSize
    call FuncReadString

    ; Ввод числа B
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncPrintMsg
    mov rsi, strNumB
    mov rdx, strNumsSize
    call FuncReadString

    ; Ввод числа C
    mov rsi, strNumberEntrenceMsg
    mov rdx, lenstrNumberEntrenceMsg
    call FuncPrintMsg
    mov rsi, strNumC
    mov rdx, strNumsSize
    call FuncReadString

    ; Конвертация строк в числа
    mov rsi, strNumA
    call FuncStrToInt
    mov [numA], rax

    mov rsi, strNumB
    call FuncStrToInt
    mov [numB], rax

    mov rsi, strNumC
    call FuncStrToInt
    mov [numC], rax

    ; Поиск максимума из трех чисел
    mov rax, [numA]
    mov rbx, [numB]
    call FuncMax              ; rax = max(A, B)
    
    mov rbx, [numC]
    call FuncMax              ; rax = max(max(A, B), C)
    mov [maxNum], rax         ; Сохраняем максимум

    ; Вычисление и вывод разниц
    mov rsi, differenceMsg
    mov rdx, lenDifferenceMsg
    call FuncPrintMsg

    ; Разница между числом A и максимумом
    mov rax, [numA]
    cmp rax, [maxNum]
    je .simple_printA
    sub rax, [maxNum]
.simple_printA:
    call FuncPrintNumber
    
    ; Разница между числом B и максимумом
    mov rax, [numB]
    cmp rax, [maxNum]
    je .simple_printB
    sub rax, [maxNum]
.simple_printB:
    call FuncPrintNumber
    
    ; Разница между числом C и максимумом
    mov rax, [numC]
    cmp rax, [maxNum]
    je .simple_printC
    sub rax, [maxNum]
.simple_printC:
    call FuncPrintNumber

    ; Завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall

FuncPrintNumber:
; Функция: FuncPrintNumber
; Назначение: Печать числа в десятичном формате
; Вход: RAX - число для печати
; Используемые регистры: RAX, RBX, RCX, RDX, RSI, RDI
; Сохраняемые регистры: Все (push/pop)

    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rdi, buffer
    call FuncIntToStr
    
    ; Вычисляем длину строки
    mov rsi, buffer
    call FuncStrLen
    mov rdx, rax
    
    mov rsi, buffer
    call FuncPrintMsg
    
    ; Вывод пробела
    mov rsi, space
    mov rdx, 1
    call FuncPrintMsg
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

FuncStrLen:
; Функция: FuncStrLen
; Назначение: Вычисление длины строки
; Вход: RSI - указатель на строку (нуль-терминированную)
; Выход: RAX - длина строки
; Используемые регистры: RAX, RCX

    xor rcx, rcx
.loop:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .loop
.done:
    mov rax, rcx
    ret

FuncPrintMsg:
; Функция: FuncPrintMsg
; Назначение: Вывод сообщения на экран
; Вход: RSI - указатель на сообщение, RDX - длина сообщения
; Используемые регистры: RAX, RDI
    mov rax, 1
    mov rdi, 1
    syscall
    ret

FuncReadString:
; Функция: FuncReadString
; Назначение: Чтение строки из stdin
; Вход: RSI - буфер для строки, RDX - размер буфера
; Используемые регистры: RAX, RDI
    mov rax, 0
    mov rdi, 0
    syscall
    ret

FuncStrToInt:
; Функция: FuncStrToInt
; Назначение: Преобразование строки в целое число
; Вход: RSI - указатель на строку
; Выход: RAX - преобразованное число
; Используемые регистры: RAX, RBX, RCX, RDX, R8
    xor rax, rax
    xor rcx, rcx
    mov r8, 1               ; Флаг знака: 1 - положительное, -1 - отрицательное

    ; Пропускаем пробелы в начале
.skip_spaces:
    mov bl, byte [rsi + rcx]
    cmp bl, ' '
    jne .check_sign
    inc rcx
    jmp .skip_spaces

.check_sign:
    mov bl, byte [rsi + rcx]
    cmp bl, '-'
    jne .convert_loop
    mov r8, -1
    inc rcx

.convert_loop:
    mov bl, byte [rsi + rcx]
    cmp bl, 0xA         ; Проверка на символ новой строки
    je .done
    cmp bl, 0           ; Проверка на конец строки
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    
    sub bl, '0'         ; Преобразование символа в цифру
    imul rax, 10        ; Умножение текущего результата на 10
    movzx rdx, bl
    add rax, rdx        ; Добавление новой цифры
    inc rcx
    jmp .convert_loop

.done:
    imul rax, r8        ; Умножение на знак
    ret

FuncMax:
; Функция: FuncMax
; Назначение: Поиск максимального из двух чисел
; Вход: RAX - первое число, RBX - второе число
; Выход: RAX - максимальное число
; Используемые регистры: RAX, RBX
    cmp rax, rbx
    jge .no_swap
    mov rax, rbx
.no_swap:
    ret

FuncIntToStr:
; Функция: FuncIntToStr
; Назначение: Преобразование целого числа в строку
; Вход: RAX - число для преобразования, RDI - буфер для строки
; Используемые регистры: RAX, RBX, RCX, RDX, RSI, RDI
    mov rsi, rdi
    test rax, rax
    jns .convert
    neg rax
    mov byte [rsi], '-'
    inc rsi

.convert:
    mov rbx, 10
    mov rcx, 0
    mov rdi, rsi

.convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert_loop

.pop_loop:
    pop rax
    mov [rdi], al
    inc rdi
    loop .pop_loop

    mov byte [rdi], 0
    ret