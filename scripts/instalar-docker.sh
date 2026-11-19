
#!/usr/bin/env bash
set -euo pipefail

echo "===== INSTALANDO DEPENDENCIAS ====="
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

echo "===== CONFIGURANDO REPOSITORIO DOCKER ====="
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
  https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "===== INSTALANDO DOCKER ====="
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "===== ATIVANDO DOCKER ====="
sudo systemctl enable --now docker

echo "===== VERSOES ====="
sudo docker --version
sudo docker compose version

echo "===== TESTE ====="
sudo docker run --rm hello-world
