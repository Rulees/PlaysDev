import os
import re

# Регулярное выражение для поиска модулей
# Будем искать строки вида 'module_name:' (например, 'yum:', 'copy:', 'service:', и т.д.)
MODULE_PATTERN = r'\b([a-zA-Z0-9._-]+):'

# Функция для поиска всех модулей в одном файле
def find_modules_in_file(file_path):
    used_modules = set()  # Используем set, чтобы избежать дублирования модулей
    try:
        with open(file_path, 'r') as file:
            content = file.read()
            
            # Ищем все упоминания модулей с помощью регулярного выражения
            modules = re.findall(MODULE_PATTERN, content)
            used_modules.update(modules)
    except Exception as e:
        print(f"Ошибка при чтении {file_path}: {e}")
    
    return used_modules

# Функция для обхода каталога и поиска всех модулей в файлах
def find_modules_in_directory(directory_path):
    all_used_modules = set()
    
    # Обходим каталог
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.yml') or file.endswith('.yaml'):  # Проверяем только YAML файлы
                file_path = os.path.join(root, file)
                modules_in_file = find_modules_in_file(file_path)
                all_used_modules.update(modules_in_file)
    
    return all_used_modules

# Основная функция
if __name__ == "__main__":
    directory = input("Введите путь к каталогу с вашими Ansible файлами: ")
    
    if not os.path.isdir(directory):
        print("Указанный путь к каталогу некорректен!")
    else:
        used_modules = find_modules_in_directory(directory)
        
        if used_modules:
            print("\nМодули, использованные в ваших Ansible файлах:")
            for module in sorted(used_modules):
                print(module)
        else:
            print("Модули не найдены в указанном каталоге.")
