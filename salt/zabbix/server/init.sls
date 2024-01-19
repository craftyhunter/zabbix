{{ pillar.systemd.db.name }}:
  file.managed:
    - name: /etc/systemd/system/{{ pillar.systemd.db.name }}.service
    - source: salt://{{slspath}}/files/zabbix-db.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: /usr/bin/docker pull {{ pillar.systemd.db.docker_image }}
  service.running:
    - enable: True
    - watch:
      - file: {{ pillar.systemd.db.name }}
    - require:
      - cmd: {{ pillar.systemd.db.name }}

{{ pillar.systemd.server.name }}:
  file.managed:
    - name: /etc/systemd/system/{{ pillar.systemd.server.name }}.service
    - source: salt://{{slspath}}/files/zabbix-server.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: /usr/bin/docker pull {{ pillar.systemd.server.docker_image }}    
  service.running:
    - enable: True
    - watch:
      - file: {{ pillar.systemd.server.name }}
    - require:
      - service: {{ pillar.systemd.db.name }}
      - cmd: {{ pillar.systemd.server.name }}

{{ pillar.systemd.web.name }}:
  file.managed:
    - name: /etc/systemd/system/{{ pillar.systemd.web.name }}.service
    - source: salt://{{slspath}}/files/zabbix-web.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: /usr/bin/docker pull {{ pillar.systemd.web.docker_image }}    
  service.running:
    - enable: True
    - watch:
      - file: {{ pillar.systemd.web.name }}
    - require:
      - service: {{ pillar.systemd.db.name }}
      - cmd: {{ pillar.systemd.web.name }}

zabbix-agent:
  pkg.installed:
    - require:
      - service: {{ pillar.systemd.server.name }}
  {# file.managed:
    - name: /etc/zabbix/zabbix_agent.conf
    - source: salt://{{slspath}}/files/zabbix-agent.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: zabbix-agent #}
  service.running:
    - enable: True
    {# - watch:
      - file: zabbix-agent #}
    - require:
      - pkg: zabbix-agent
