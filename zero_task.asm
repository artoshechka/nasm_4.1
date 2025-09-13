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
    newline                 db 10
    buffer                  times 21 db 0

section .bss
    numA    resq numsSize
    numB    resq numsSize
    numC    resq numsSize
    strNumA resb strNumsSize
    strNumB resb strNumsSize
    strNumC resb strNumsSize
    maxNum  resq numsSize      ; Переменная для хранения максимума
    
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
    call FuncPrintNumber ;DEDUG

    mov [numA], rax

    mov rsi, strNumB
    call FuncStrToInt
    call FuncPrintNumber ;DEDUG

    mov [numB], rax

    mov rsi, strNumC
    call FuncStrToInt
    call FuncPrintNumber ;DEDUG

    mov [numC], rax

    ; Поиск максимума из трех чисел
    mov rax, [numA]
    mov rbx, [numB]
    call FuncMax              ; rax = max(A, B)
    
    mov rbx, [numC]
    call FuncMax              ; rax = max(max(A, B), C)
    call FuncPrintNumber ;DEDUG

    
    mov [maxNum], rax         ; Сохраняем максимум

    ; Вычисление и вывод разниц
    mov rsi, differenceMsg
    mov rdx, lenDifferenceMsg
    call FuncPrintMsg

    ; Разница между максимумом и числом A
    mov rax, [maxNum]
    sub rax, [numA]
    call FuncPrintNumber
    
    ; Разница между максимумом и числом B
    mov rax, [maxNum]
    sub rax, [numB]
    call FuncPrintNumber
    
    ; Разница между максимумом и числом C
    mov rax, [maxNum]
    sub rax, [numC]
    call FuncPrintNumber

    ; Завершение программы
    xor rdi, rdi
    call FuncEnd

; Функция для печати числа
; Вход: RAX - число для печати
; Используемые регистры: RAX, RBX, RCX, RDX, RSI, RDI
FuncPrintNumber:
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
    mov byte [buffer], ' '
    mov rsi, buffer
    mov rdx, 1
    call FuncPrintMsg
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Функция для вычисления длины строки
; Вход: RSI - указатель на строку
; Выход: RAX - длина строки
; Используемые регистры: RAX, RCX
FuncStrLen:
    xor rcx, rcx
.loop:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .loop
.done:
    mov rax, rcx
    ret

; Функция завершения программы
; Вход: RDI - код возврата
; Используемые регистры: RAX
FuncEnd:
    mov rax, 60
    syscall
    ret

; Функция печати сообщения
; Вход: RSI - указатель на сообщение, RDX - длина сообщения
; Используемые регистры: RAX, RDI
FuncPrintMsg:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; Функция чтения строки
; Вход: RSI - буфер для строки, RDX - размер буфера
; Используемые регистры: RAX, RDI
FuncReadString:
    mov rax, 0
    mov rdi, 0
    syscall
    ret

; Функция преобразования строки в число
; Вход: RSI - указатель на строку
; Выход: RAX - число
; Используемые регистры: RAX, RBX, RCX, RDX
FuncStrToInt:
    xor rax, rax
    xor rcx, rcx
    xor rbx, rbx
    mov rbx, 1              ; Флаг знака: 1 - положительное, -1 - отрицательное

    .loop:
        mov bl, byte [rsi + rcx]
        cmp bl, 0xA         ; Проверка на символ новой строки
        je .done
        cmp bl, 0           ; Проверка на конец строки
        je .done
        cmp bl, '-'         ; Проверка на знак минус
        jne .checkDigit
        mov rbx, -1         ; Устанавливаем флаг отрицательного числа
        inc rcx
        jmp .loop

    .checkDigit:
        cmp bl, '0'
        jl .inputError
        cmp bl, '9'
        jg .inputError
        sub bl, '0'         ; Преобразование символа в цифру
        imul rax, rax, 10   ; Умножение текущего результата на 10
        movzx rdx, bl
        add rax, rdx        ; Добавление новой цифры
        inc rcx
        jmp .loop
    
    .inputError:
        mov rdi, 1
        call FuncEnd

    .done:
        imul rax, rbx       ; Умножение на знак
        ret

; Функция поиска максимума
; Вход: RAX, RBX - числа для сравнения
; Выход: RAX - максимальное число
; Используемые регистры: RAX, RBX
FuncMax:
    cmp rax, rbx
    jge .no_swap
    mov rax, rbx            ; Если RBX > RAX, копируем RBX в RAX
.no_swap:
    ret

; Функция преобразования числа в строку
; Вход: RAX - число, RDI - буфер для строки
; Используемые регистры: RAX, RBX, RCX, RDX, RSI
FuncIntToStr:
    mov rsi, rdi
    xor rcx, rcx
    test rax, rax           ; Проверка знака числа
    jns .convert
    neg rax                 ; Если отрицательное, делаем положительным
    mov cl, 1               ; Устанавливаем флаг отрицательного числа

.convert:
    lea rbx, [rsi + 20]     ; Указатель на конец буфера
    mov byte [rbx], 0       ; Завершающий нуль
    dec rbx

    cmp rax, 0
    jne .loop
    mov byte [rbx], '0'     ; Если число 0
    dec rbx
    jmp .sign

.loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx                 ; Делим RAX на 10
    add dl, '0'             ; Преобразуем остаток в символ
    mov [rbx], dl           ; Сохраняем символ
    dec rbx
    test rax, rax           ; Проверяем, не стало ли частное нулем
    jnz .loop

.sign:
    test cl, cl             ; Проверяем флаг знака
    jz .copy
    mov byte [rbx], '-'     ; Добавляем знак минус
    dec rbx

.copy:
    inc rbx                 ; Перемещаемся к началу числа
.copyLoop:
    mov al, [rbx]           ; Копируем число в начало буфера
    mov [rsi], al
    inc rbx
    inc rsi
    test al, al             ; Проверяем на конец строки
    jnz .copyLoop
    ret