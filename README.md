# Конфигурация домашней станции
Использую Debian. На системе изначально установлены только системные утилиты 
и пакет git.

## Последовательность запуска плейбуков
Запускаем bash script для установки Ansible. Сценарий совместим с Debian и 
CentOS.
```
# ./scripts/install_ansible.sh
```
Настраиваем Ansible с помощью плейбука:
```
# ansible-playbook ansible-configure.yml
```
Плейбук ansible-configure.yml задает станции роль ansible.

Дальнейшая работа с ansible-playbook производится с параметром --ask-vault-pass

Для дальнейшей работы нужно указать список пользователей компьютера в переменной 
users (либо через --extra-vars, либо в файле ansible-home/host_vars/localhost/main.yml.
В файле уже присутствуют данные о моей учетной записи с указанием роли admin 
(см. раздел **Безопасность**).

Для пользователей, указанных в переменной users, будут заданы рандомные пароли, 
если пользователь не зарегистрирован в системе. Пароли нигде не сохраняются, 
так что сменить их можно будет только от пользователя root.

После выполнения настройки Ansible можно произвести настройку домашней станции:
```
# ansible-playbook home.yml --ask-vault-pass
```

Плейбук задает станции роли:
- work
- nvidia

## Действия ролей
Действия роли **ansible**:
- Установка пакетов openssh-client и openssl (для генерации рандомных паролей).
- Добавление в систему пользователя ansible.
+ Настройки для пользователя ansible:
  + Генерация SSH ключей (тип rsa, 4096 бит) с passphrase.
  + Добавление SSH pub ключей ansible клиентам в файл по адресу /home/ansible/.ssh/authorized_keys.
  + Настройка SSH клиента для мультиплексирования SSH сессий.
  + Сохранение пароля в файл /etc/ansible/.passwd/ansible.<inventory_hostname>.yml.
  + Шифрование созданного файла с паролем программой ansible-vault для локального хоста.
  + Для пользователя ansible на удаленных машинах пароли шифруются с помощью vault-id лейбла prov, 
    т.к. выполнение плейбуков в приложениях типа vagrant при запуске сразу нескольких 
    машин не дает адекватного интерфейса для ввода пароля vault.
  + Создание паролей vault-id лейблов prov, dev, stage, prod по адресу /home/ansible/.vault_pass/<label>_pass

Роль **nvidia** зависит от роли **media**, которая в свою очередь зависит от роли **common**.

Действия роли **common**:
- Установка пакетов sudo, openssl (для генерации рандомных паролей).
- Добавляет пользователей в систему (указанных в переменной users).
- Если в переменной users присутствует пользователь ansible, то генерируется новый пароль и сохраняется на сервере Ansible.
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

## Безопасность
Для пользователей с ролью **admin** будет произведена настройка файла sudoers с 
правилом **user_name ALL=(ALL) ALL**. Можно в настройке переменной users задать 
значение nopass ключа sudo для пользователя. Тогда в sudoers будет указано 
правило Defaults:user_name !authenticate.

Конфигурация позволяет работать от пользователя ansible.
С помощью плейбука configure-ansible.yml можно периодически рандомить пароль ansible 
и изменять vault password для файла с паролем. Для домашней станции это избыточно, 
но подход позволяет привычно работать при конфигурации виртуальных машин 
сервером Ansible.

Аутентификация на клиенте Ansible производится в два этапа. Во-первых, 
необходимо указать пароль для зашифрованного файла с паролем пользователя 
ansible на сервере Ansible. Во-вторых, необходимо указать passphrase для ключа 
при SSH соединении с клиентом сервера Ansible. Работа на клиенте производится 
от пользователя ansible.
Файлы с паролями пользователей ansible на клиентах хранятся в папке 
/etc/ansible/.passwd/ansible.<inventory_hostname>.yml.