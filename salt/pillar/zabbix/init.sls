zabbix:
  db:
    name: zabbix
    user: zabbix
    password: zabbix
    data_dir: /srv/pgdata


systemd:
  server:
    name: "zabbix-server"
    docker_image: "zabbix/zabbix-server-pgsql:ubuntu-6.4-latest"
  web:
    name: "zabbix-web"
    docker_image: "zabbix/zabbix-web-nginx-pgsql:ubuntu-6.4-latest"
  db:
    name: "zabbix-db"
    docker_image: "postgres:16.1"
  