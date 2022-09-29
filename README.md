# naselin_infra
naselin Infra repository

## HW-03 (lesson-05).
#### Самостоятельное задание: исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства.
Предварительно включаем SSH forwarding (рабочее устройство - CentOS Linux release 7.9.2009):
```
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

#### Дополнительное задание: использование валидного сертификата для панели управления VPN сервера
Настроено подключение c помощью Let’s Encrypt и sslip.io по адресу:
```
130.193.39.94.sslip.io
```
