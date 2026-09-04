#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="${PREFIX}/bin"
SKILL_DIR="${HOME}/.gemini/config/skills/agy-prompt-note"

echo "==> Uninstalling git-prompt-note..."
if [[ -f "${BIN_DIR}/git-prompt-note" ]]; then
    rm -f "${BIN_DIR}/git-prompt-note"
    echo "  [-] Removed ${BIN_DIR}/git-prompt-note"
fi

if [[ -d "${SKILL_DIR}" ]]; then
    rm -rf "${SKILL_DIR}"
    echo "  [-] Removed ${SKILL_DIR}"
fi

echo "Uninstalled."
