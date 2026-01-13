#!/usr/bin/env bash
set -e

echo "🚀 Installing GitLab Runner via APT repository"

# =========================
# Fancy helpers (ASCII)
# =========================
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

SPINNER_PID=""

spin() {
  local msg="$1"
  local frames='|/-\'
  local i=0

  printf "${CYAN}%s ${NC}" "$msg"
  while :; do
    i=$(( (i + 1) % 4 ))
    printf "\b%s" "${frames:$i:1}"
    sleep 0.1
  done
}

start_spinner() {
  local msg="$1"
  spin "$msg" &
  SPINNER_PID=$!
  disown
}

stop_spinner() {
  if [[ -n "${SPINNER_PID}" ]]; then
    kill "${SPINNER_PID}" >/dev/null 2>&1 || true
    wait "${SPINNER_PID}" 2>/dev/null || true
    SPINNER_PID=""
    printf "\b${GREEN}✓${NC}\n"
  fi
}

fail() {
  stop_spinner || true
  echo -e "${RED}❌ Error: $1${NC}"
  exit 1
}

trap 'fail "Script interrupted"' INT TERM

# =========================
# 1. ROOT CHECK
# =========================
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}❌ Please run this script with sudo or as root${NC}"
  exit 1
fi

# =========================
# 2. ADD GITLAB RUNNER REPO
# =========================
start_spinner "➕ Adding GitLab Runner repository..."
curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash >/dev/null 2>&1 || fail "Failed to add GitLab Runner repo"
stop_spinner

# =========================
# 3. INSTALL / UPDATE GITLAB RUNNER
# =========================
start_spinner "⬇️ apt-get update..."
apt-get update -y >/dev/null 2>&1 || fail "apt-get update failed"
stop_spinner

start_spinner "📦 Installing gitlab-runner package..."
apt-get install -y gitlab-runner >/dev/null 2>&1 || fail "gitlab-runner install failed"
stop_spinner

# =========================
# 4. ENABLE & START SERVICE
# =========================
start_spinner "▶️ Enabling gitlab-runner service..."
systemctl enable gitlab-runner >/dev/null 2>&1 || fail "Failed to enable service"
stop_spinner

start_spinner "🔄 Restarting gitlab-runner service..."
systemctl restart gitlab-runner >/dev/null 2>&1 || fail "Failed to restart service"
stop_spinner

# =========================
# 5. STATUS + FINAL ASCII
# =========================
echo
echo -e "${YELLOW}📊 GitLab Runner status:${NC}"
systemctl --no-pager --full status gitlab-runner || true

echo
echo -e "${CYAN}ℹ️ GitLab Runner version:${NC}"
gitlab-runner --version || true

echo
cat <<'EOF'
✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
   _____ _ _   _          _       ____                        
  / ____(_) | | |        | |     |  _ \                       
 | |  __ _| |_| |     __ _| |__   | |_) | ___  _   _ _ __     
 | | |_ | | __| |    / _` | '_ \  |  _ < / _ \| | | | '_ \    
 | |__| | | |_| |___| (_| | |_) | | |_) | (_) | |_| | | | |   
  \_____|_|\__|______\__,_|_.__/  |____/ \___/ \__,_|_| |_|   
                                                             
✅ GitLab Runner installed & service is running!
Next step:
  sudo gitlab-runner register
✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
EOF
