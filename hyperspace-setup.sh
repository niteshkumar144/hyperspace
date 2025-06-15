#!/bin/bash

set -euo pipefail

# === Colors ===
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}🚀 Hyperspace Node One-Click Installer 🚀${RESET}"

# === Ask for Private Key ===
echo -e "${YELLOW}Please paste your Hyperspace PRIVATE KEY and press [ENTER]:${RESET}"
read -r PRIVATE_KEY

# === Save private key to my.pem ===
echo "$PRIVATE_KEY" > my.pem
chmod 600 my.pem
echo -e "${GREEN}✅ Private key saved to my.pem${RESET}"

# === Install CLI if missing ===
if ! command -v aios-cli >/dev/null 2>&1; then
  echo -e "${CYAN}🔑 Installing Hyperspace CLI...${RESET}"
  curl -s https://download.hyper.space/api/install | bash
  source ~/.bashrc || true
fi

# === Start node in screen ===
SESSION="hyperspace"

if screen -list | grep -q "$SESSION"; then
  echo -e "${YELLOW}⚡ Screen session '$SESSION' already running. Skipping node start.${RESET}"
else
  echo -e "${CYAN}🔄 Starting node in new screen session '$SESSION'...${RESET}"
  screen -dmS "$SESSION" bash -c "aios-cli start"
fi

# === Wait for node to boot up ===
echo -e "${CYAN}⏳ Waiting 10 seconds for node to initialize...${RESET}"
sleep 10

# === Run setup commands ===
echo -e "${CYAN}🔧 Running initial setup commands...${RESET}"

aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf || true
aios-cli hive import-keys ./my.pem || true
aios-cli hive login || true
aios-cli hive connect || true
aios-cli hive select-tier 5 || true

echo -e "${GREEN}✅ All done! Node is running inside screen session '$SESSION'.${RESET}"
echo -e "${CYAN}👉 To view: ${YELLOW}screen -r $SESSION${RESET}"
echo -e "${CYAN}👉 To detach: Press ${YELLOW}Ctrl+A then D${RESET}"

echo -e "${GREEN}🎉 Happy Node Running! 🚀${RESET}"
