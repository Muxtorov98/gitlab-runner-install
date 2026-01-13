#!/usr/bin/env bash
set -e

echo "🚀 GitLab Runner install / update (system-mode)"

# 1. SUDO CHECK
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run with sudo"
  exit 1
fi

# 2. DOWNLOAD / UPDATE BINARY
echo "⬇️ Downloading GitLab Runner binary..."
curl -L --output /usr/local/bin/gitlab-runner \
  https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

chmod +x /usr/local/bin/gitlab-runner

# 3. CREATE USER IF NEEDED
if ! id gitlab-runner &>/dev/null; then
  echo "👤 Creating gitlab-runner user..."
  useradd --comment 'GitLab Runner' --create-home --shell /bin/bash gitlab-runner
else
  echo "👤 gitlab-runner user already exists"
fi

# 4. INSTALL SERVICE IF NOT EXISTS
if [[ ! -f /etc/systemd/system/gitlab-runner.service ]]; then
  echo "⚙️ Installing GitLab Runner system service..."
  gitlab-runner install \
    --user=gitlab-runner \
    --working-directory=/home/gitlab-runner
else
  echo "⚙️ GitLab Runner service already installed"
fi

# 5. ENABLE + START
echo "▶️ Enabling & starting GitLab Runner..."
systemctl enable gitlab-runner
systemctl restart gitlab-runner

# 6. STATUS
echo "📊 GitLab Runner status:"
systemctl status gitlab-runner --no-pager

echo "✅ Done!"
echo "👉 Next step (if not registered yet):"
echo "   sudo gitlab-runner register"
