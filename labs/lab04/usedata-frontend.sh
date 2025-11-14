#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data-frontend.log | logger -t user-data-frontend -s 2>/dev/console) 2>&1
echo "=== user-data-frontend: start ==="

yum update -y
amazon-linux-extras install docker -y || yum install -y docker
systemctl enable --now docker

docker rm -f lab04-client || true
docker pull ${front_image}

docker run -d --name lab04-client \
  -p ${frontend_host_port}:80 \
  -e API_ORIGIN="${api_url}" \
  --restart unless-stopped \
  ${front_image}

ss -lnt | grep ":${frontend_host_port}" || (docker ps -a; docker logs --tail 200 lab04-client; exit 1)
echo "=== user-data-frontend: done ==="
