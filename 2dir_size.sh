#!/bin/bash

# Функция для конвертации байтов в удобный формат
function human_readable_size {
    local bytes=$1
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$((bytes / 1073741824))G"
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$((bytes / 1048576))M"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$((bytes / 1024))K"
    else
        echo "${bytes}B"
    fi
}

# Функция для подсчёта размера каталога рекурсивно
function get_directory_size {
    local total_size=0
    for item in "$1"/*; do
        if [[ -d "$item" ]]; then
            dir_size=$(get_directory_size "$item")
            total_size=$((total_size + dir_size))
        elif [[ -f "$item" ]]; then
            file_size=$(stat --format=%s "$item")
            total_size=$((total_size + file_size))
        fi
    done
    echo $total_size
}

# Определяем целевой каталог
target_dir="${1:-.}"

# Проверяем, существует ли указанный каталог
if [[ ! -d "$target_dir" ]]; then
    echo "Ошибка: каталог $target_dir не существует."
    exit 1
fi

# Массив для хранения размеров и названий файлов/каталогов
declare -A sizes

# Проход по всем элементам целевого каталога
for item in "$target_dir"/*; do
    if [[ -d "$item" ]]; then
        size=$(get_directory_size "$item")
    elif [[ -f "$item" ]]; then
        size=$(stat --format=%s "$item")
    else
        continue
    fi
    sizes["$item"]=$size
done

# Создаём массив для сортировки
sorted_items=()

# Копируем ключи в массив и сортируем их по размеру (пузырьковая сортировка)
for key in "${!sizes[@]}"; do
    sorted_items+=("$key")
done

# Реализация пузырьковой сортировки по убыванию
for ((i = 0; i < ${#sorted_items[@]} - 1; i++)); do
    for ((j = 0; j < ${#sorted_items[@]} - i - 1; j++)); do
        if [[ ${sizes[${sorted_items[$j]}]} -lt ${sizes[${sorted_items[$((j+1))]}]} ]]; then
            # Меняем местами элементы
            temp="${sorted_items[$j]}"
            sorted_items[$j]="${sorted_items[$((j+1))]}"
            sorted_items[$((j+1))]="$temp"
        fi
    done
done

# Вывод результатов в человеко-читаемом формате
for item in "${sorted_items[@]}"; do
    human_size=$(human_readable_size "${sizes[$item]}")
    echo "$item: $human_size"
done
