#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="${PREFIX}/bin"
SKILL_DIR="${HOME}/.gemini/config/skills/git-prompt-log"
LEGACY_SKILL_DIR1="${HOME}/.gemini/config/skills/git-prompt-note"
LEGACY_SKILL_DIR2="${HOME}/.gemini/config/skills/agy-prompt-note"

echo "==> Uninstalling git-prompt-log..."
if [[ -f "${BIN_DIR}/git-prompt-log" ]]; then
    rm -f "${BIN_DIR}/git-prompt-log"
    echo "  [-] Removed ${BIN_DIR}/git-prompt-log"
fi

if [[ -f "${BIN_DIR}/git-prompt-note" ]]; then
    rm -f "${BIN_DIR}/git-prompt-note"
    echo "  [-] Removed legacy ${BIN_DIR}/git-prompt-note"
fi

if [[ -d "${SKILL_DIR}" ]]; then
    rm -rf "${SKILL_DIR}"
    echo "  [-] Removed ${SKILL_DIR}"
fi

if [[ -d "${LEGACY_SKILL_DIR1}" ]]; then
    rm -rf "${LEGACY_SKILL_DIR1}"
    echo "  [-] Removed legacy ${LEGACY_SKILL_DIR1}"
fi

if [[ -d "${LEGACY_SKILL_DIR2}" ]]; then
    rm -rf "${LEGACY_SKILL_DIR2}"
    echo "  [-] Removed legacy ${LEGACY_SKILL_DIR2}"
fi

echo "Uninstalled."
