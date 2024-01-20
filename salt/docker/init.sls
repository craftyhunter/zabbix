docker-pre:
  cmd.run:
  - name: |
      sudo apt-get update
      sudo apt-get install ca-certificates curl gnupg
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo rm /etc/apt/keyrings/docker.gpg | true
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update

docker:
  pkg.installed:
  - pkgs:
    - docker-ce
    - docker-ce-cli
    - containerd.io
    - docker-buildx-plugin
    - docker-compose-plugin
  - require:
    - cmd: docker-pre
