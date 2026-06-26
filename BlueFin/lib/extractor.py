import os

def extract_dart_files(root_dir, output_file='dart_files_content.txt'):
    """
    Рекурсивно обходит root_dir, находит все .dart файлы
    и записывает их путь и содержимое в output_file.
    """
    with open(output_file, 'w', encoding='utf-8') as out:
        for dirpath, dirnames, filenames in os.walk(root_dir):
            for filename in filenames:
                if filename.endswith('.dart'):
                    file_path = os.path.join(dirpath, filename)
                    # Относительный путь от корневой папки
                    rel_path = os.path.relpath(file_path, root_dir)
                    
                    out.write(f'===== {rel_path} =====\n')
                    try:
                        with open(file_path, 'r', encoding='utf-8') as dart_file:
                            content = dart_file.read()
                            out.write(content)
                    except Exception as e:
                        out.write(f'[Ошибка чтения файла: {e}]\n')
                    out.write('\n\n')  # разделитель между файлами

    print(f'Готово. Результат сохранён в {output_file}')

if __name__ == '__main__':
    # Замените '.' на путь к вашей папке, если нужно
    target_folder = input("Введите путь к папке (Enter для текущей): ").strip()
    if not target_folder:
        target_folder = '.'
    if os.path.isdir(target_folder):
        extract_dart_files(target_folder)
    else:
        print('Указанная папка не существует.')