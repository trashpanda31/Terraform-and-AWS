#!/usr/bin/env bash
set -euo pipefail
dnf -y update
dnf -y install nginx
systemctl enable --now nginx
