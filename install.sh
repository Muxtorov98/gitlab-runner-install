#!/usr/bin/env bash
set -e

echo "🚀 Running install_user.sh inside CI runner"

# =========================
# 1. Validate env vars
# =========================
: "${RUNNER_HOSTNAME:?Missing RUNNER_HOSTNAME}"
: "${RUNNER_USER:?Missing RUNNER_USER}"
: "${RUNNER_IP:?Missing RUNNER_IP}"

# =========================
# 2. Show where we are
# =========================
echo "🖥 Hostname : $RUNNER_HOSTNAME"
echo "👤 User     : $RUNNER_USER"
echo "📂 PWD      : $RUNNER_PWD"
echo "🌐 IP       : $RUNNER_IP"
echo "🕒 Date     : $RUNNER_DATE"
echo "📦 Project  : $CI_PROJECT_PATH_EX"
echo "🔀 Branch   : $CI_BRANCH_EX"
echo "🆔 Pipeline : $CI_PIPELINE_EX"

# =========================
# 3. Create proof folder
# =========================
TEST_DIR="/tmp/ci-proof"
mkdir -p "$TEST_DIR"

cat <<EOF > "$TEST_DIR/runner-info.txt"
Hostname : $RUNNER_HOSTNAME
User     : $RUNNER_USER
IP       : $RUNNER_IP
PWD      : $RUNNER_PWD
Date     : $RUNNER_DATE
Project  : $CI_PROJECT_PATH_EX
Branch   : $CI_BRANCH_EX
Pipeline : $CI_PIPELINE_EX
EOF

echo "✅ Proof file created: $TEST_DIR/runner-info.txt"

# =========================
# 4. Telegram notify (optional)
# =========================
if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
  MESSAGE="🧪 *CI RUNNER CONFIRMED*

🖥 Host: $RUNNER_HOSTNAME
👤 User: $RUNNER_USER
🌐 IP: $RUNNER_IP
📦 Project: $CI_PROJECT_PATH_EX
🔀 Branch: $CI_BRANCH_EX
🆔 Pipeline: $CI_PIPELINE_EX
"

  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d parse_mode="Markdown" \
    --data-urlencode text="$MESSAGE"

  echo "📨 Telegram notification sent"
else
  echo "ℹ️ Telegram vars not set, skipping notify"
fi

echo "🎉 install_user.sh finished successfully"
