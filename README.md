# Freebuff Termux Installer 🚀

Native `freebuff` AI coding assistant installer for **Termux** on Android (No `proot` required!).

## ⚡ Quick One-Line Installation

Run this single command in your Termux terminal to install:

```bash
curl -fsSL https://raw.githubusercontent.com/D153a53/freebuff-termux/main/install.sh | bash
```

Or from local directory:

```bash
git clone https://github.com/D153a53/freebuff-termux.git
cd freebuff-termux
bash install.sh
```

---

## 🛠️ Features
- **Native Performance**: Runs directly in Termux using `termux-glibc` without container/proot overhead.
- **No SIGSEGV Crash**: Properly patches the ELF dynamic interpreter without corrupting Bun runtime's internal payload (`--set-rpath` avoided).
- **Auto Dependency Resolution**: Automatically installs `glibc-repo`, `glibc`, `patchelf`, and `clang`.
- **Global Binary**: Compiles a native C wrapper executable into `$PREFIX/bin/freebuff` for global terminal usage.

---

## 📋 Prerequisite & Dependency Installation Commands

If you prefer installing all required dependencies manually before running the script:

```bash
# 1. Setup Storage Permission
termux-setup-storage

# 2. Update Termux package repositories
pkg update && pkg upgrade -y

# 3. Add the glibc repository
pkg install -y glibc-repo

# 4. Install all required packages
pkg install -y glibc patchelf clang curl tar git
```

---

## 💻 Usage

```bash
# Check version
freebuff --version

# Display help menu
freebuff --help

# Start coding assistant
freebuff
```

---

## 🗑️ Uninstallation

To remove `freebuff` from Termux:

```bash
bash uninstall.sh
```
