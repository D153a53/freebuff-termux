#!/data/data/com.termux/files/usr/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}Removing Freebuff...${NC}"

rm -f "$PREFIX/bin/freebuff"
rm -rf "$HOME/.local/share/freebuff"
rm -rf "$HOME/.config/fresh"
rm -rf "$HOME/.config/manicode"

echo -e "${GREEN}✓ Freebuff uninstalled successfully.${NC}"
