#!/bin/bash

echo $(date) 'Скрипт запущен.'

# Функция для конвертации байтов в удобный формат (KB, MB, GB)
function human_readable_size {
    local bytes=$1
    # Если количество байтов больше или равно 1 ГБ
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$((bytes / 1073741824))G"  # Конвертируем в гигабайты
    # Если больше или равно 1 МБ
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$((bytes / 1048576))M"  # Конвертируем в мегабайты
    # Если больше или равно 1 КБ
    elif [[ $bytes -ge 1024 ]]; then
        echo "$((bytes / 1024))K"  # Конвертируем в килобайты
    else
        echo "${bytes}B"  # Оставляем в байтах, если меньше 1 КБ
    fi
}

# Функция для рекурсивного подсчёта размера каталога
function get_directory_size {
    local total_size=0  # Инициализируем переменную для хранения общего размера
    # Проходим по всем элементам в каталоге
    for item in "$1"/*; do
        # Если элемент - это каталог, рекурсивно вызываем функцию для подсчета его размера
        if [[ -d "$item" ]]; then
            dir_size=$(get_directory_size "$item")  # Рекурсивный вызов функции
            total_size=$((total_size + dir_size))  # Добавляем размер подкаталога
        # Если элемент - файл, используем команду stat для получения его размера в байтах
        elif [[ -f "$item" ]]; then
            file_size=$(stat --format=%s "$item")  # Получаем размер файла
            total_size=$((total_size + file_size))  # Добавляем к общему размеру
        fi
    done
    echo $total_size  # Возвращаем общий размер каталога (в байтах)
}

# Определяем целевой каталог, если аргумент не передан, используем текущий каталог (.)
target_dir="${1:-.}"

# Проверяем, существует ли указанный каталог
if [[ ! -d "$target_dir" ]]; then
    echo "Ошибка: каталог $target_dir не существует."
    exit 1  # Выходим с кодом ошибки, если каталог не существует
fi

# Массив для хранения размеров и названий файлов/каталогов
declare -A sizes  # Ассоциативный массив, где ключ - это путь к файлу или каталогу, а значение - его размер

# Проходим по всем элементам целевого каталога
echo  $(date) "Старт подсчёта размера элементов..."
for item in "$target_dir"/*; do
    # Если это каталог, получаем его размер с помощью рекурсивной функции
    if [[ -d "$item" ]]; then
        size=$(get_directory_size "$item")  # Вызываем функцию для подсчёта размера каталога
    # Если это файл, получаем его размер напрямую
    elif [[ -f "$item" ]]; then
        size=$(stat --format=%s "$item")  # Получаем размер файла с помощью команды stat
    else
        continue  # Пропускаем, если это не файл и не каталог
    fi
    sizes["$item"]=$size  # Сохраняем размер в ассоциативный массив
done

echo $(date) "Подсчёт размера элементов закончен!"

# Создаём массив для сортировки ключей (путей к файлам/каталогам)
sorted_items=()

# Копируем ключи из ассоциативного массива в обычный массив
for key in "${!sizes[@]}"; do
    sorted_items+=("$key")  # Добавляем ключи (пути) в массив sorted_items
done

echo $(date) "Запуск сортировки элементов по убыванию размера..."
# Реализация пузырьковой сортировки по убыванию размера
# Внешний цикл по элементам массива
for ((i = 0; i < ${#sorted_items[@]} - 1; i++)); do
    # Внутренний цикл сравнивает соседние элементы
    for ((j = 0; j < ${#sorted_items[@]} - i - 1; j++)); do
        # Сравниваем размеры двух соседних элементов
        if [[ ${sizes[${sorted_items[$j]}]} -lt ${sizes[${sorted_items[$((j+1))]}]} ]]; then
            # Если размер текущего элемента меньше следующего, меняем их местами
            temp="${sorted_items[$j]}"  # Временная переменная для обмена значениями
            sorted_items[$j]="${sorted_items[$((j+1))]}"
            sorted_items[$((j+1))]="$temp"
        fi
    done
done

echo $(date) "Сортировка завершена!"
echo $(date) "Вывод результатов работы:"

# Вывод результатов в человеко-читаемом формате
for item in "${sorted_items[@]}"; do
    human_size=$(human_readable_size "${sizes[$item]}")  # Конвертируем размер в человеко-читаемый формат
    echo "$human_size: $item"  # Выводим путь к файлу/каталогу и его размер
done

echo $(date) 'Работа завершена!'
