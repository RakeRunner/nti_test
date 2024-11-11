#!/bin/bash

# Функция для получения размера файла или каталога
get_size() {
    local path="$1"
    local size=$(du -hs "$path" 2>/dev/null | cut -f1)
    echo $size
}

# Собираем элементы каталога
items=$(ls -A)

# Массив для хранения результата
result=()
for item in $items; do
    size=$(get_size "$item")
    result+=("$size $item")
done

# Вывод с сортировкой по убыванию и форматированием колонок
printf "%s\n" "${result[@]}" | sort -rh | column -t
