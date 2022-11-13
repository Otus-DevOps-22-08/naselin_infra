# naselin_infra
naselin Infra repository
---
## HW-10 (lesson-14).
#### Ansible: работа с ролями и окружениями.
1. Созданные плейбуки перенесены в раздельные роли
   1. с помощью ```ansible-galaxy init``` созданы заготовки под роли ```app``` и ```db```;
   2. секции плейбуков разнесены по соответствующим файлам и директориям, определены переменные по умолчанию;
   3. в плейбуках вызовы тасков и хендлеров заменены на вызов ролей.
2. Описаны два окружения
   1. созданы директории ```ansible/environments/stage```, ```ansible/environments/prod```;
   2. инвентори файлы файлы перенесены в созданные папки, в ```ansible.cfg``` настроено окружение по умолчанию;
   3. настроены переменные;
   4. нерелевантные файлы из предыдущих заданий перенесены в ```ansible/old```.
3. Использована коммьюнити роль nginx:
   1. установлена роль ```jdauphant.nginx```, добавлена соответствующая запись в ```.gitignore```;
   2. настроено минимальное проксирование, вызов роли ```jdauphant.nginx``` добавлен в плейбук ```app.yml```;
   3. дополнительных манипуляций в конфигурации terraform не потребовалось (80й порт открыт, приложение доступно).
4. Используем Ansible Vault для наших окружений
   1. подготовлен плейбук ```users.yml```, в ```credentials.yml``` добавлены и зашифрованы реквизиты пользователей;
   2. ```vault.key``` вынесен за пределы репозитория;
   3. вызов плейбука ```users.yml``` добавлен в файл ```site.yml```, при выполнении для stage окружения создаются пользователи ```admin``` и ```qauser```.

##### Работа с динамическим инвентори.
Фактически, было выполнено в предыдущем ДЗ.
В пункте 2.ii ```yc_compute.yml``` был скопирован в ```environments/(stage|prod)```
Соответственно, при запуске плейбука достаточно указать нужный инвентори файл (-i).

##### Настройка TravisCI.
![Default OTUS auto-tests](https://github.com/Otus-DevOps-22-08/naselin_infra/actions/workflows/run-tests-2022-08.yml/badge.svg)
![Validate packer templates](https://github.com/Otus-DevOps-22-08/naselin_infra/actions/workflows/packer-validate.yml/badge.svg)
---
## HW-09 (lesson-13).
#### Деплой и управление конфигурацией с Ansible.
1. Используем плейбуки, хендлеры, шаблоны для конфигурации окружения и деплоя тестового приложения. Подход "один плейбук, один сценарий" (play) - ```reddit_app_one_play.yml```.
2. Аналогично, один плейбук, но много сценариев - ```reddit_app_multiple_plays.yml```.
3. И много плейбуков - ```app.yml```, ```db.yml```, ```deploy.yml```. Плейбуки импортированы в ```site.yml```, описывающий конфигурацию всей инфраструктуры.
4. Изменим провижн образов Packer на Ansible-плейбуки:
   1. На основании скриптов ```install_ruby.sh``` и ```install_mongodb.sh ``` написаны плейбуки;
   2. собраны новые образы, результаты выполнения ```ansible-playbook site.yml``` соответствуют ожиданиям.

##### Исследование плагина yc_compute.py.
1. Скачал плагин из репозитория автора. Установил зависимости (```$ pip3 install yandexcloud```).
2. Немного поразмыслив, разместил плагин в репозитории (```ansible/plugins/inventory```).
3. Документация и примеры использования есть в коде плагина, можно ознакомиться с помощью ```$ ansible-doc -t inventory yc_compute```.
4. Настроен ```ansible.cfg``` и ```yc_compute.yml``` для использования палагина.
5. Функционал ```keyed_groups``` изучил, но пока не стал применять. Пример для ```key: labels['tags']```:
```commandline
$ ansible-inventory --graph
@all:
  |--@reddit_app:
  |  |--reddit-app.internal
  |--@reddit_db:
  |  |--reddit-db.internal
  |--@ungrouped:
```

P.S. В базовых образах не был установлен git. Соответственно, плейбуки немного отличаются от описанных в методичке.

---
## HW-08 (lesson-12).
#### Знакомство с Ansible.
1. Установлен Ansible, настроен ```ansible.cfg```.
2. Проверена работа c хостами через модули (ping, command, shell, service, etc).
3. Исследованы разные форматы inventory (ini, yaml, json).
4. Создан простейший playbook ```clone.yml```, проверена идемпотентность (changed=1 в случае отсутствия папки с приложением и changed=0 при повторном запуске).
#### Динамическое инвентори.
Написан скрипт для динамического формирования JSON-inventory.
```
./yc-inventory.py --help
usage: yc-inventory.py [-h] [--list] [--host HOST] [--pretty] [--save]

Make an Ansible Inventory file for YC

optional arguments:
  -h, --help   show this help message and exit
  --list       List instances (default: True)
  --host HOST  Print instance hostvars
  --pretty     Pretty output format (default: False)
  --save       Save inventory to file (default: False)
```
1. При запуске без параметров формирует JSON из результатов вывода команды ```yc compute instances list --format json```.
2. При запуске с опцией ```--host``` выводит ```hostvars``` указанного хоста.
3. При указании опции ```--save``` сохраняет вывод скрипта в файл ```dynamic-inventory.json```.
4. Для использования по умолчанию, необходимо указать ```inventory=./yc-inventory.py``` в ```ansible.cfg```.

P.S. ansible.cfg в репозитории настроен на использование статической конфигурации для успешного прохождения автотестов.

---
## HW-07 (lesson-09).
#### Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform.
1. БД вынесена на отдельную VM (собраны новые образы по шаблонам app.json и db.json).
2. Конфигурация Terraform разнесена по разным файлам (отдельно app и db).
3. На основе конфигураций п.2 созданы модули app и db.
4. Модули переиспользованы в окружениях stage и prod (инфраструктура в обоих окружениях идентична).
5. Настроено хранение state-файла в удаленном бэкенде (Yandex Object Storage). Описание вынесено в backend.tf.
6. В модуле app добавлен отдельный null-ресурс для автоматического деплоя и запуска приложения по значению переменной "auto_deploy_app".
####NB! Конфигурация required_providers вынесена в отдельные файлы для успешного прохождения автотестов.
Перед запуском terraform необходимо выполнить команду:
```commandline
$ find . -iname "reqprovider" -exec cp {} {}.tf \;
```
Затем настроить в выбранном окружении переменные (terraform.tfvars), конфигурацию backend.tf.
Пример запуска в prod:
```commandline
$ cd terraform/prod
$ terraform init && terraform apply
```

Для корректной работы приложения (при auto_deploy_app = true) необходимо:
* на инстансе db сменить ```bindIp``` в ```/etc/mongod.conf``` на реальный ```"internal_ip_address_db"```;
* перезапустить MongoDB ```$ sudo systemctl restart mongodb```.

---
## HW-06 (lesson-08).
#### Практика IaC с использованием Terraform.
1. Установлен и инициализирован Terraform.
2. В main.tf добавлен ресурс для создания инстанса VM в YC.
3. Для деплоя тестового приложения использованы provisioners.
4. Входные переменные вынесены в variables.tf, определены значения в terraform.tfvars.
5. Создан HTTP-балансировщик (lb.tf).
6. Внешние IP-адреса всех сущностей вынесены в outputs.tf.
7. Вручную создан второй инстанс VM, добавлен в целевую группу балансировщика. Очевидные проблемы: нарушение подхода DRY, необходимость вручную синхронизировать все изменения.
8. Ручное создание инстансов упразднено, использованы: параметр ресурса count и dynamic target в балансировщике.

---
## HW-05 (lesson-07).
#### Сборка образов VM при помощи Packer.
1. Установлен Packer, в YC создан и настроен сервисный аккаунт для Packer.
2. Создан (packer/ubuntu16.json) и параметризован (packer/variables.json) шаблон для создания образа с
использованием скриптов из предыдущего задания (packer/scripts/install_mongodb.sh, packer/scripts/install_ruby.sh).
3. Собран образ reddit-base:
```
$ cd packer && packer build -var-file=variables.json ubuntu16.json
```
4. Вручную создана VM из подготовленного образа и установлено тестовое приложение. Доступ по ссылке:
```
http://178.154.206.71:9292/
```
5. Опробован подход "Immutable infrastructure":
   1. создан шаблон (packer/immutable.json) со скриптами для автоматического разёртывания (packer/files/deploy_app.sh) и создания systemd unit для запуска (packer/files/create_puma_service.sh) приложения;
   2. собран образ reddit-full: ```$ cd packer && packer build -var-file=variables.json immutable.json```;
   3. создан скрипт автоматического развёртывания VM из образа reddit-full (config-scripts/create-reddit-vm.sh);
   4. cозданная VM доступна по ссылке:
```
http://178.154.220.91:9292/
```
---
## HW-04 (lesson-06).
#### Деплой тестового приложения.
Данные для подключения:
```
testapp_IP = 62.84.117.11
testapp_port = 9292
```

Команда для создания VM:
```
yc compute instance create --name reddit-app --hostname reddit-app --memory=4 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 --metadata serial-port-enable=1 --metadata-from-file user-data=metadata.yaml
```
---
## HW-03 (lesson-05).
#### Самостоятельное задание: исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства.
Предварительно настраиваем SSH forwarding (рабочее устройство - CentOS Linux release 7.9.2009):
```
$ ssh-add -L
$ eval `ssh-agent -s`
$ ssh-add ~/.ssh/appuser
```
* Вариант "в лоб" (ssh command - работает, но нет приглашения):
```
$ ssh -i ~/.ssh/appuser -A appuser@130.193.39.94 ssh appuser@someinternalhost
```
* Развиваем мысль (используем jump host):
```
$ ssh -i ~/.ssh/appuser -J appuser@130.193.39.94 appuser@someinternalhost
```
#### Дополнительное задание: предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost
```
$ cat <<EOF> ~/.ssh/config
Host bastion
HostName 130.193.39.94
IdentityFile ~/.ssh/appuser
User appuser
Host someinternalhost
HostName 10.128.0.22
User appuser
### Use ProxyJump or ProxyCommand - to your taste
# ProxyJump appuser@bastion
ProxyCommand ssh -W %h:%p bastion
EOF
$ chmod 600 ~/.ssh/config
```
Далее по потребностям - ProxyJump / ProxyCommand.

### VPN-сервер для серверов Yandex.Cloud
Реквизиты для подключения:
```
bastion_IP = 130.193.39.94
someinternalhost_IP = 10.128.0.22
```
Примечание: перед выполнением git push на рабочем устройстве необходимо отключить OpenVPN.

#### Дополнительное задание: использование валидного сертификата для панели управления VPN сервера
Настроено подключение c помощью Let’s Encrypt и sslip.io по адресу:
```
130.193.39.94.sslip.io
```
