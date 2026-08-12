#!/data/data/com.termux/files/usr/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}    Freebuff Termux Installer       ${NC}"
echo -e "${BLUE}=====================================${NC}"

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo -e "${RED}Error: Currently only aarch64 (arm64) architecture is supported.${NC}"
    exit 1
fi

# Ensure storage permission option
if [ ! -d "$HOME/storage" ]; then
    echo -e "${BLUE}[+] Initializing Termux storage permission...${NC}"
    termux-setup-storage || true
fi

# Install dependencies
echo -e "${BLUE}[1/5] Checking & installing packages...${NC}"
pkg update -y || true

if [ ! -f "$PREFIX/etc/apt/sources.list.d/glibc.list" ]; then
    pkg install -y glibc-repo || true
fi

pkg install -y glibc patchelf clang curl tar git

# Fetch latest version
echo -e "${BLUE}[2/5] Fetching latest Freebuff release version...${NC}"
VERSION=$(curl -fsSL https://registry.npmjs.org/freebuff/latest | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "0.0.145")
echo "Latest version: $VERSION"

# Setup data directory
DATA_DIR="$HOME/.local/share/freebuff"
mkdir -p "$DATA_DIR"

# Download binary
echo -e "${BLUE}[3/5] Downloading Freebuff binary...${NC}"
curl -fsSL "https://codebuff.com/api/releases/download/${VERSION}/freebuff-linux-arm64.tar.gz" -o "$DATA_DIR/freebuff.tar.gz"
tar -zxf "$DATA_DIR/freebuff.tar.gz" -C "$DATA_DIR"
rm -f "$DATA_DIR/freebuff.tar.gz"
chmod +x "$DATA_DIR/freebuff"

# Patch binary ELF interpreter (DO NOT USE --set-rpath: it corrupts Bun binary)
echo -e "${BLUE}[4/5] Patching glibc dynamic linker interpreter...${NC}"
$PREFIX/glibc/bin/patchelf --set-interpreter "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" "$DATA_DIR/freebuff"

# Compile launcher helper
echo -e "${BLUE}[5/5] Compiling native launcher wrapper...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER_SRC="$SCRIPT_DIR/src/freebuff_helper.c"

if [ ! -f "$HELPER_SRC" ]; then
    cat << 'EOF' > "$DATA_DIR/freebuff_helper.c"
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <limits.h>
#include <stdio.h>

int main(int argc, char** argv) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");

    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE", "/data/data/com.termux/files/usr/etc/tls/cert.pem", 1);

    char real_bin[] = "/data/data/com.termux/files/home/.local/share/freebuff/freebuff";

    char** new_argv = malloc((argc + 1) * sizeof(char*));
    if (!new_argv) {
        return 1;
    }

    new_argv[0] = real_bin;

    for (int i = 1; i < argc; i++) {
        new_argv[i] = argv[i];
    }
    new_argv[argc] = NULL;

    execv(real_bin, new_argv);

    perror("execv");
    free(new_argv);
    return 1;
}
EOF
    HELPER_SRC="$DATA_DIR/freebuff_helper.c"
fi

clang -O2 -o "$PREFIX/bin/freebuff" "$HELPER_SRC"
chmod +x "$PREFIX/bin/freebuff"

echo -e "${GREEN}✓ Freebuff installed successfully!${NC}"
echo -e "Run ${BLUE}freebuff${NC} or ${BLUE}freebuff --help${NC} to start."
