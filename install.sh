#!/usr/bin/env bash
set -e

echo "🚀 Installing GitLab Runner via APT repository"

# =========================
# 1. ROOT CHECK
# =========================
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script with sudo or as root"
  exit 1
fi

# =========================
# 2. ADD GITLAB RUNNER REPO
# =========================
echo "➕ Adding GitLab Runner repository..."
curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash

# =========================
# 3. INSTALL GITLAB RUNNER
# =========================
echo "⬇️ Installing gitlab-runner package..."
apt-get update -y
apt-get install -y gitlab-runner

# =========================
# 4. ENABLE & START SERVICE
# =========================
echo "▶️ Enabling and starting GitLab Runner service..."
systemctl enable gitlab-runner
systemctl restart gitlab-runner

# =========================
# 5. STATUS
# =========================
echo "📊 GitLab Runner status:"
systemctl status gitlab-runner --no-pager

echo "🎉 GitLab Runner installed successfully!"
echo "👉 Next step:"
echo "   sudo gitlab-runner register"
