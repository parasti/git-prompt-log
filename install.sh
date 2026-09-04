#!/usr/bin/env bash
set -euo pipefail

# git-prompt-note one-command installer
# Installs git-prompt-note into PATH and configures global Git notes rewriting.

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="${PREFIX}/bin"
SKILL_DIR="${HOME}/.gemini/config/skills/agy-prompt-note"

INSTALL_SKILL=true
CONFIGURE_GIT=true

usage() {
    cat << 'HELP'
Usage: ./install.sh [options]

Options:
  --prefix <dir>       Installation prefix (default: ~/.local)
  --no-skill           Skip installing Antigravity global skill
  --no-git-config      Skip configuring global Git notes rewrite settings
  -h, --help           Show this help message
HELP
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            BIN_DIR="${PREFIX}/bin"
            shift 2
            ;;
        --no-skill)
            INSTALL_SKILL=false
            shift
            ;;
        --no-git-config)
            CONFIGURE_GIT=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_BIN="${SCRIPT_DIR}/bin/git-prompt-note"
SOURCE_SKILL="${SCRIPT_DIR}/SKILL.md"

if [[ ! -f "${SOURCE_BIN}" ]]; then
    echo "Error: Cannot find ${SOURCE_BIN}" >&2
    exit 1
fi

echo "==> Installing git-prompt-note..."

# 1. Install CLI binary
mkdir -p "${BIN_DIR}"
install -m 755 "${SOURCE_BIN}" "${BIN_DIR}/git-prompt-note"
echo "  [+] Installed executable: ${BIN_DIR}/git-prompt-note"

# 2. Configure Git global settings for notes rewriting
if [[ "${CONFIGURE_GIT}" = true ]]; then
    git config --global notes.rewrite.rebase true
    git config --global notes.rewrite.amend true
    git config --global notes.rewriteRef refs/notes/commits
    echo "  [+] Configured Git global notes.rewriteRef = refs/notes/commits"
fi

# 3. Install Antigravity global skill
if [[ "${INSTALL_SKILL}" = true && -f "${SOURCE_SKILL}" ]]; then
    mkdir -p "${SKILL_DIR}"
    cp "${SOURCE_SKILL}" "${SKILL_DIR}/SKILL.md"
    echo "  [+] Installed Antigravity skill: ${SKILL_DIR}/SKILL.md"
fi

# 4. Check PATH
case ":$PATH:" in
    *":${BIN_DIR}:"*)
        ;;
    *)
        echo ""
        echo "Notice: ${BIN_DIR} is not currently in your PATH."
        echo "Add it to your shell configuration (e.g. ~/.zshrc or ~/.bashrc):"
        echo "  export PATH=\"${BIN_DIR}:\$PATH\""
        ;;
esac

echo ""
echo "Installation complete!"
echo "Run 'git prompt-note --help' or 'git prompt-note install-hook' inside a repo."
