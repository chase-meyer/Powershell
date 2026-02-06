#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_SRC="${REPO_ROOT}/theme.omp.json"
POSH_THEMES_DIR="${HOME}/.poshthemes"

command_exists() { command -v "$1" >/dev/null 2>&1; }

install_pwsh_debian() {
  local codename release pkg_url
  codename=$(lsb_release -cs 2>/dev/null || echo "jammy")
  release=$(lsb_release -rs 2>/dev/null || echo "22.04")
  pkg_url="https://packages.microsoft.com/config/ubuntu/${release}/packages-microsoft-prod.deb"

  echo "Installing PowerShell via packages.microsoft.com for ${release} (${codename})..."
  sudo apt-get update -y
  sudo apt-get install -y wget apt-transport-https software-properties-common gpg
  wget -q "$pkg_url" -O /tmp/packages-microsoft-prod.deb
  sudo dpkg -i /tmp/packages-microsoft-prod.deb
  sudo apt-get update -y
  sudo apt-get install -y powershell
}

ensure_pwsh() {
  if command_exists pwsh; then
    echo "pwsh already installed"
    return
  fi

  if command_exists apt-get; then
    install_pwsh_debian
  else
    echo "pwsh not found and no apt-get available. Install PowerShell 7 manually: https://aka.ms/powershell-release" >&2
    exit 1
  fi
}

ensure_oh_my_posh() {
  if command_exists oh-my-posh; then
    echo "oh-my-posh already installed"
    return
  fi
  echo "Installing oh-my-posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s
}

copy_theme() {
  mkdir -p "$POSH_THEMES_DIR"
  if [ -f "$THEME_SRC" ]; then
    cp "$THEME_SRC" "$POSH_THEMES_DIR/theme.omp.json"
  fi
}

ensure_bashrc_pwsh() {
  local bashrc="${HOME}/.bashrc"
  local marker_start="# >>> pwsh-auto >>>"
  local marker_end="# <<< pwsh-auto <<<"

  if grep -Fq "$marker_start" "$bashrc" 2>/dev/null; then
    echo "pwsh auto-launch already present in .bashrc"
    return
  fi

  cat <<'EOF' >> "$bashrc"
# >>> pwsh-auto >>>
if [ -t 1 ] && command -v pwsh >/dev/null 2>&1; then
  exec pwsh
fi
# <<< pwsh-auto <<<
EOF
  echo "Added pwsh auto-launch to .bashrc"
}

main() {
  ensure_pwsh
  ensure_oh_my_posh
  copy_theme
  ensure_bashrc_pwsh

  echo "Running PowerShell setup..."
  pwsh "${REPO_ROOT}/Scripts/setup.ps1" -InstallPwshIfMissing:\$false

  if [ -f "${REPO_ROOT}/Scripts/install-modules.ps1" ]; then
    echo "Installing modules from pinned list..."
    pwsh "${REPO_ROOT}/Scripts/install-modules.ps1" || true
  fi

  echo "WSL setup complete. Restart your shell to load the new profile."
}

main "$@"
