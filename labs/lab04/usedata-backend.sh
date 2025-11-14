#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data-backend.log | logger -t user-data-backend -s 2>/dev/console) 2>&1
echo "=== user-data-backend: start ==="

retry() { n=0; until "$@"; do n=$((n+1)); [[ $n -ge 8 ]] && exit 1; echo "retry $n..."; sleep $((5*n)); done; }

retry amazon-linux-extras install -y docker || retry yum install -y docker
systemctl enable --now docker

docker rm -f lab04-server || true
docker pull "${back_image}"

docker run -d --name lab04-server \
  -p ${backend_port}:${backend_port} \
  -e PORT=${backend_port} \
  --restart unless-stopped \
  "${back_image}"

ss -lnt | grep ":${backend_port}" || (docker ps -a; docker logs --tail 200 lab04-server; exit 1)
echo "=== user-data-backend: done ==="
