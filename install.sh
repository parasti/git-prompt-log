#!/usr/bin/env bash
set -euo pipefail

# git-prompt-note installer
# Installs the CLI binary and prompts before applying global Git or agent configurations.

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="${PREFIX}/bin"
SKILL_DIR="${HOME}/.gemini/config/skills/git-prompt-note"

GLOBAL_GIT=""
GLOBAL_SKILL=""

usage() {
    cat << 'HELP'
Usage: ./install.sh [options]

Options:
  --prefix <dir>       Installation prefix (default: ~/.local)
  --global             Configure Git and install assistant skill globally without asking
  --local-only         Install only the CLI binary; skip all global configurations
  -y, --yes            Assume yes to all prompts
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
        --global)
            GLOBAL_GIT=true
            GLOBAL_SKILL=true
            shift
            ;;
        --local-only)
            GLOBAL_GIT=false
            GLOBAL_SKILL=false
            shift
            ;;
        -y|--yes)
            GLOBAL_GIT=true
            GLOBAL_SKILL=true
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

echo "==> Installing git-prompt-note CLI..."

# 1. Install CLI binary
mkdir -p "${BIN_DIR}"
install -m 755 "${SOURCE_BIN}" "${BIN_DIR}/git-prompt-note"
echo "  [+] Installed executable: ${BIN_DIR}/git-prompt-note"

# Helper for interactive prompt
prompt_yes_no() {
    local prompt_msg="$1"
    local default_ans="$2" # 'y' or 'n'

    # Non-interactive environment fallback to default
    if [[ ! -t 0 ]]; then
        [[ "$default_ans" == "y" ]] && return 0 || return 1
    fi

    local ans
    read -r -p "${prompt_msg} " ans || true
    ans="$(echo "${ans}" | tr '[:upper:]' '[:lower:]')"
    if [[ -z "${ans}" ]]; then
        ans="${default_ans}"
    fi
    [[ "${ans}" == "y" || "${ans}" == "yes" ]]
}

echo ""
echo "Configuration:"

# 2. Global Git config
if [[ -z "${GLOBAL_GIT}" ]]; then
    if prompt_yes_no "Configure Git globally to rewrite notes on rebase/amend? [y/N]" "n"; then
        GLOBAL_GIT=true
    else
        GLOBAL_GIT=false
    fi
fi

if [[ "${GLOBAL_GIT}" = true ]]; then
    git config --global notes.rewrite.rebase true
    git config --global notes.rewrite.amend true
    git config --global notes.rewriteRef refs/notes/commits
    echo "  [+] Configured Git global: notes.rewriteRef = refs/notes/commits"
else
    echo "  [-] Skipped global Git config"
fi

# 3. Global Antigravity skill
if [[ -z "${GLOBAL_SKILL}" ]]; then
    if prompt_yes_no "Install Antigravity assistant skill globally (~/.gemini/config/skills)? [y/N]" "n"; then
        GLOBAL_SKILL=true
    else
        GLOBAL_SKILL=false
    fi
fi

if [[ "${GLOBAL_SKILL}" = true && -f "${SOURCE_SKILL}" ]]; then
    mkdir -p "${SKILL_DIR}"
    cp "${SOURCE_SKILL}" "${SKILL_DIR}/SKILL.md"
    echo "  [+] Installed global skill: ${SKILL_DIR}/SKILL.md"
else
    echo "  [-] Skipped global skill installation"
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
echo "==> Installation complete!"
if [[ "${GLOBAL_GIT}" = false || "${GLOBAL_SKILL}" = false ]]; then
    echo ""
    echo "To enable git-prompt-note for a specific repository, run:"
    echo "  cd /path/to/my-repo"
    echo "  git prompt-note init"
fi
