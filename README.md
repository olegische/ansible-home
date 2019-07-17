# Homestation
Использую Debian. На системе установлены только системные утилиты.

Запускаем  homestation/scripts/install_ansible.sh для установки Ansible.

Конфигурируем Ansible:
```
sudo ansible-playbook homestation/ansible-home/configure-ansible.yml
```
Плейбук добавит в систему пользователя ansible, задаст ему рандомный пароль, 
сохранит его на диск и зашифрует с помощью ansible-vault.
Дальнейшая работа с ansible-playbook производится с параметром --ask-vault-pass

Конфигурация позволяет в дальнейшем работать от пользователя ansible.
С помощью плейбука configure-ansible.yml можно периодически рандомить пароль ansible 
и изменять vault password для файла с паролем.

После выполнения скрипта можно сконфигурировать домашнюю станцию:
```
sudo ansible-playbook homestation/ansible-home/home.yml --ask-vault-pass
```

Для пользователей, если они не присутствуют в системе, будут сконфигурированы рандомные пароли.