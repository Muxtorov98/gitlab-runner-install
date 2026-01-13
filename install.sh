#!/usr/bin/env bash
set -e

echo "🚀 Installing GitLab Runner (system-mode, non-root execution)"

# 1. Check sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script with sudo"
  exit 1
fi

# 2. Download runner binary
echo "⬇️ Downloading GitLab Runner binary..."
curl -L --output /usr/local/bin/gitlab-runner \
  https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

chmod +x /usr/local/bin/gitlab-runner

# 3. Create gitlab-runner user if not exists
if ! id gitlab-runner &>/dev/null; then
  echo "👤 Creating gitlab-runner user..."
  useradd \
    --comment 'GitLab Runner' \
    --create-home \
    --shell /bin/bash \
    gitlab-runner
else
  echo "👤 gitlab-runner user already exists"
fi

# 4. Install runner as system service
echo "⚙️ Installing GitLab Runner service..."
gitlab-runner install \
  --user=gitlab-runner \
  --working-directory=/home/gitlab-runner

# 5. Start runner service
echo "▶️ Starting GitLab Runner..."
gitlab-runner start

# 6. Show status
echo "📊 GitLab Runner status:"
systemctl status gitlab-runner --no-pager

echo "✅ GitLab Runner installed successfully!"
echo "👉 Next step: sudo gitlab-runner register"
