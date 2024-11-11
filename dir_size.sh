#!/bin/bash

# Массивы для хранения файлов и их размеров
declare -A file_sizes
declare -a files_list

# Функция для рекурсивного подсчета размера файлов в каталоге
calculate_dir_size() {
    local dir="$1"
    local total_size=0

    # Проходим по каждому элементу в каталоге
    while IFS= read -r -d $'\0' item; do
        echo "Обрабатывается: $item"  # Отладочный вывод для каждого элемента
        if [ -f "$item" ]; then
            # Если это файл, получаем его размер с помощью stat
            size=$(stat --format="%s" "$item")
            total_size=$((total_size + size))
            file_sizes["$item"]=$size
            files_list+=("$item")
            echo "Добавлен файл: $item с размером $size байт"
        elif [ -d "$item" ]; then
            # Если это каталог, вызываем рекурсию
            echo "Найден подкаталог: $item"
            subdir_size=$(calculate_dir_size "$item")
            total_size=$((total_size + subdir_size))
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0)  # Обрабатываем только текущий уровень

    echo "Общий размер каталога $dir: $total_size байт"
    echo "$total_size"
}

# Проверка переданного аргумента
if [ -z "$1" ]; then
    echo "Укажите каталог для расчета его размера."
    exit 1
fi

echo "Подсчет файлов..."
total_size=$(calculate_dir_size "$1")

# Выводим общий размер каталога
echo "Общий размер каталога '$1': $total_size байт"

# Выводим список файлов после рекурсии
echo "Список файлов:"
for file in "${files_list[@]}"; do
    echo "$file : ${file_sizes["$file"]} байт"
done
