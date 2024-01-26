# Zabbix in docker

See https://www.zabbix.com/documentation/current/en/manual/installation/containers

В этом репозитории описана saltstack конфигурация zabbix сервера и его компонентов, запускаемых в docker контейнерах. 
Конфигурация запускалась и тестировалась в ВМ с Ubuntu 22.04.
Используются:
 - postgresql 16.1
 - zabbix-server 6.4
 - zabbix-web-server 6.4

NOTE: Всё что описано ниже применялось для серверов на Debian\Ubuntu и используется лишь как заметки. 
Если вам что-то непонятно, всегда можно обратиться к оригинальной документации.

# Порядок развертывания
## Сервер
  1. Перейти в директорию `/srv`
  2. Склонировать этот репозиторий
  3. Запустить `env_prepare.sh` - скрипт установит `salt-minion` и настроит его в `masterless` режим. Создаст симлинк для salt директории.
  4. Перейти в директорию `/srv/salt`
  5. Запустить `salt-call --local state.apply docker` - установит docker
  6. Запустить `salt-call --local state.apply zabbix.server` - создаст systemd сервисы, которые будут запускать docker контейнеры, и запустит их. А также установит zabbig-agent.

### Настройка
Для начала сбора метрик с агентов необходимо добавить информацию об агентах. Тут есть 2 пути:
  - автоматический поиск и регистрация серверов - подходит для доверенных сетей
  - ручное указание каждого из серверов
  
При ручном указании заведении сервера, необходимо указать: 
  - hostname
  - interface
  - hostgroups
  - templates

## Агент
### Установка
  1. Необходимо подключить репозиторий
  2. Далее установить `zabbix-agent` 


### *NOTE: Про Windows*

По умолчанию конфиг лежит по пути: `C:\Program Files\zabbix\conf\zabbix_agentd.win.conf`, однако может использоваться и другой.
Чтобы его найти, необходимо открыть оснастку управления службами, найти там `Zabbix Agent`, и посмотреть параметры запуска.

### *NOTE: Про версии сервера и агентов*

Обязательное правило - версия агента должна быть ниже или равна версии сервера.
Но даже если версия агент будет младше могут возникнуть ситуации, когда не все метрики из Template работают. 
Например для метрик собираемых с `nginx` в новых версиях сервера используется команда с раздельным указанием параметров:
`web.page.get["{$NGINX.STUB_STATUS.HOST}","{$NGINX.STUB_STATUS.PATH}","{$NGINX.STUB_STATUS.PORT}"]`

Однако на старых агентах может работать только вариант с указанием одного параметра: `web.page.get["http://127.0.0.1/basic_status"]`


### Настройка в active режим
`Active` режим - агент самостоятельно подключается к серверу, получает с него список проверок и потравляет результат. 
Позволяет лучше утилизировать ресурсы сервера, но не может использоваться если агенты находятся в недоверенных сетях.

В конфинге агента добавить адрес сервера или доверенную сеть в параметр `ActiveServer`. И перезапустить сервис. 
Тут стоит обратить внимание на то, что парметры могут быть разнесены по разным файлам, которые можно поискать тут: `/etc/zabbix/zabbix_agentd.d/`.
В примере ниже `10.0.0.0/8` условная доверенная сеть, используйте то значение, которое нужно вам. 
```bash
sudo sed -i -E 's/^(ActiveServer=.*)/\1,10.0.0.0\/8/' /etc/zabbix/zabbix_agentd.conf;
sudo systemctl restart zabbix-agent.service;
```  
Чтобы убедиться что агент успешно подключился к серверу можно посмотреть лог, в случае неудачи там будет запись:
```bash
sudo tail -f /var/log/zabbix/zabbix_agentd.log;
```


### Настройка в passive режим
`Passive` режим - сервер подключается к агенту, запускает проверку и получает результат. 
В таком режиме сервер более нагружен, как правило используется в случае когда с агентов нет доступа до сервера.

В конфинге агента добавить адрес сервера или доверенную сеть в параметр `Server`. И перезапустить сервис. 
Тут стоит обратить внимание на то, что парметры могут быть разнесены по разным файлам, которые можно поискать тут: `/etc/zabbix/zabbix_agentd.d/`.
В примере ниже `10.0.0.0/8` условная доверенная сеть, используйте то значение, которое нужно вам.
```bash
sudo sed -i -E 's/^(Server=.*)/\1,10.0.0.0\/8/' /etc/zabbix/zabbix_agentd.conf;
sudo systemctl restart zabbix-agent.service;
```  
Чтобы убедиться что агент успешно подключился к серверу можно посмотреть лог, в случае неудачи там будет запись:
```bash
sudo tail -f /var/log/zabbix/zabbix_agentd.log;
```


# Возможные проблемы
 - systemd-сервисы не показывают актуальное состояние контейнеров, а лишь запускают их при старте системы. Возможно это место стоит улучшить.
 - при подстановке ip адресов используется первый элемент из списка. Возможно это место стоит улучшить
 - пароль базы данных хранится в описании systemd-сервиса, безопаснее его хранить в файле и при старте сервисов читать из файла.
