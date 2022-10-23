# naselin_infra
naselin Infra repository
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
$ find . -iname "reqprovider" -exec mv {} {}.tf \;
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
