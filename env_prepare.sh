sudo apt-get install -y vim curl
curl -L https://bootstrap.saltstack.com -o bootstrap_salt.sh
sudo sh bootstrap_salt.sh
echo "file_client: local" >> /etc/salt/minion
echo -e "pillar_roots:\n  base:\n    - /srv/salt/pillar" >> /etc/salt/minion
sudo systemctl restart salt-minion

# create symlink to default salt directory
sudo ln -s /srv/zabbix/salt/ srv/salt

# sudo pvcreate /dev/sda
# sudo vgcreate pgdata /dev/sda
# sudo lvcreate -n pgdata -l 12799 pgdata
# sudo mkfs.ext4 -L pgdata /dev/mapper/backup-backup
# echo "/dev/mapper/pgdata-pgdata	/srv/pgdata	ext4	errors=remount-ro 0       1" | sudo tee -a /etc/fstab

# sudo pvcreate /dev/sdc
# sudo vgcreate backup /dev/sdc
# sudo lvcreate -n backup -l 25599 backup
# sudo mkfs.ext4 -L backup /dev/mapper/backup-backup
# echo "/dev/mapper/backup-backup	/srv/backup	ext4	errors=remount-ro 0       1" | sudo tee -a /etc/fstab
