# Конфигурация домашней станции
Использую Debian. На системе установлены только системные утилиты.

## Последовательность запуска плейбуков
Запускаем  scripts/install_ansible.sh для установки Ansible.

Конфигурируем Ansible:
```
sudo ansible-playbook configure-ansible.yml
```
Плейбук добавит в систему пользователя ansible, задаст ему рандомный пароль, 
сохранит его на диск и зашифрует с помощью ansible-vault.
Дальнейшая работа с ansible-playbook производится с параметром --ask-vault-pass

Конфигурация позволяет в работать от пользователя ansible.
С помощью плейбука configure-ansible.yml можно периодически рандомить пароль ansible 
и изменять vault password для файла с паролем.

После выполнения скрипта можно сконфигурировать домашнюю станцию:
```
sudo ansible-playbook home.yml --ask-vault-pass
```

Для пользователей, если они не присутствуют в системе, будут сконфигурированы рандомные пароли.

Плейбук задает станции роли:
- work
- nvidia

## Действия ролей
Роль **nvidia** зависит от роли **media**, которая в свою очередь зависит от роли **common**.

Действия роли **common**:
- Обновление репозитория apt и установка пакетов sudo, openssl (для генерации рандомных паролей).
- Добавляет пользователей в систему (указанных в переменной users).
- Настраивает файл sudoers для пользователей (см ansible-home/roles/common/{files,templates}/

Роли **media** устанавливает в систему следующие пакеты:
- xfce4
- xfce4-goodies
- greybird-gtk-theme
- numix-icon-theme
- breeze-cursor-theme
- vlc

Роль **nvidia** устанавливает драйвера Nvidia из репозиториев contrib и non-free. 
Для Debian Buster это производится путем установки nvidia-driver.
После установки драйвера система перезагружается.

Роль **work** устанавливает в систему пакеты, необходимые для работы. На данный момент это:
- vim
- rsync
- git
- remmina
- cups