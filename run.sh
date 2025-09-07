#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <имя_файла.asm>"
  exit 1
fi

filename="$1"

# Собираем объектный файл
nasm -f elf64 "$filename" -o exec.o
if [ $? -ne 0 ]; then
  echo "Ошибка сборки с nasm"
  exit 1
fi

# Линкуем
ld -o exec exec.o
if [ $? -ne 0 ]; then
  echo "Ошибка линковки"
  exit 1
fi

# Запускаем
./exec