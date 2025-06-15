#!/bin/bash

# === Safe Mode ===
set -euo pipefail

# === Colors ===
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}🚀 Hyperspace Node One-Click Installer 🚀${RESET}"

# === Prompt for Private Key ===
read -rp "$(echo -e "${YELLOW}👉 Enter your Hyperspace PRIVATE KEY: ${RESET}")" PRIVATE_KEY

# === Validate input ===
if [[ -z "$PRIVATE_KEY" ]]; then
  echo -e "${YELLOW}⚠️  No Private Key entered. Exiting!${RESET}"
  exit 1
fi

# === Save key ===
echo "$PRIVATE_KEY" > my.pem
chmod 600 my.pem
echo -e "${GREEN}✅ Private key saved to my.pem${RESET}"

# === Check & Install CLI ===
if ! command -v aios-cli &>/dev/null; then
  echo -e "${CYAN}🔑 Installing Hyperspace CLI...${RESET}"
  curl -s https://download.hyper.space/api/install | bash
  echo -e "${CYAN}🔄 Reloading shell...${RESET}"
  if [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi
  export PATH="$HOME/.local/bin:$PATH"
fi

# === Confirm CLI works ===
if ! command -v aios-cli &>/dev/null; then
  echo -e "${YELLOW}❌ aios-cli not found even after install. Please check manually.${RESET}"
  exit 1
fi

# === Start in screen ===
SESSION="hyperspace"

if screen -list | grep -q "$SESSION"; then
  echo -e "${YELLOW}⚡ Screen session '$SESSION' already exists. Skipping start.${RESET}"
else
  echo -e "${CYAN}🟢 Starting node in screen session '$SESSION'...${RESET}"
  screen -dmS "$SESSION" bash -c "aios-cli start"
fi

# === Wait for node to initialize ===
echo -e "${CYAN}⏳ Waiting 15 seconds for node to initialize...${RESET}"
sleep 15

# === Run Hive setup ===
echo -e "${CYAN}🔧 Running node setup commands...${RESET}"

aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf || echo "Model add step skipped if already added"
aios-cli hive import-keys ./my.pem || echo "Keys import skipped if already done"
aios-cli hive login || echo "Login skipped if already logged in"
aios-cli hive connect || echo "Connect skipped if already connected"
aios-cli hive select-tier 5 || echo "Tier select skipped if already selected"

echo -e "${GREEN}✅ Setup complete! Node is running inside screen session '$SESSION'.${RESET}"
echo -e "${CYAN}👉 To view logs: ${YELLOW}screen -r $SESSION${RESET}"
echo -e "${CYAN}👉 To detach: Press ${YELLOW}Ctrl+A then D${RESET}"

echo -e "${GREEN}🎉 Happy Node Running! Jai Hind! 🇮🇳${RESET}"
