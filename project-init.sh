#!/usr/bin/env bash
# Copilot Toolkit — Project-Level Installer
# Downloads toolkit files from GitHub directly into the current project's .github/ folder.
# Usage: curl -sSL https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.sh | bash

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
REPO_OWNER="${PFA_OWNER:-utpanwar}"
REPO_NAME="${PFA_REPO:-project-feature-analyser-prompt-saving.ai}"
BRANCH="${PFA_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ─── Helper Functions ────────────────────────────────────────────────────────
info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error()   { printf "${RED}[ERR]${NC}  %s\n" "$1"; exit 1; }

download_file() {
    local url="$1"
    local dest="$2"
    local dir
    dir=$(dirname "$dest")
    mkdir -p "$dir"
    if curl -sSfL "$url" -o "$dest" 2>/dev/null; then
        success "Downloaded: $dest"
    else
        warn "Failed to download: $dest (skipped)"
        return 1
    fi
}

# ─── Main ────────────────────────────────────────────────────────────────────
printf "\n${BLUE}+==========================================+${NC}\n"
printf "${BLUE}|  Copilot Toolkit v2.0 — Project Install  |${NC}\n"
printf "${BLUE}+==========================================+${NC}\n\n"

info "Installing into: $(pwd)"

# Files to download (source path in repo → destination in project)
declare -A FILES=(
    [".github/instructions/prompt-logger.instructions.md"]=".github/instructions/prompt-logger.instructions.md"
    [".github/instructions/auto-docs.instructions.md"]=".github/instructions/auto-docs.instructions.md"
    [".github/prompts/scaffold-project.prompt.md"]=".github/prompts/scaffold-project.prompt.md"
    [".github/prompts/analyze-project.prompt.md"]=".github/prompts/analyze-project.prompt.md"
    [".github/prompts/setup-toolkit.prompt.md"]=".github/prompts/setup-toolkit.prompt.md"
    [".github/copilot-toolkit-config.json"]=".github/project-feature-analyser-prompt-saving.ai-config.json"
    ["templates/feature-config-template.md"]="templates/feature-config-template.md"
)

INSTALLED=0
FAILED=0

for src in "${!FILES[@]}"; do
    dest="${FILES[$src]}"
    if download_file "${BASE_URL}/${src}" "$dest"; then
        ((INSTALLED++))
    else
        ((FAILED++))
    fi
done

# ─── Update .gitignore ──────────────────────────────────────────────────────
GITIGNORE_ENTRIES=(
    ".github/project-feature-analyser-prompt-saving.ai-config.json"
    "prompt-log.md"
    "coding-fixes-log.md"
    "functional-fixes-log.md"
    "feature-config.md"
    "functionality-config.md"
)

if [ -f ".gitignore" ]; then
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qxF "$entry" .gitignore 2>/dev/null; then
            echo "$entry" >> .gitignore
            info "Added '$entry' to .gitignore"
        fi
    done
else
    printf "%s\n" "${GITIGNORE_ENTRIES[@]}" > .gitignore
    info "Created .gitignore with toolkit entries"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
printf "\n${GREEN}==========================================${NC}\n"
printf "${GREEN}  Installation complete!${NC}\n"
printf "${GREEN}  Files installed: ${INSTALLED}${NC}\n"
if [ "$FAILED" -gt 0 ]; then
    printf "${YELLOW}  Files failed: ${FAILED}${NC}\n"
fi
printf "${GREEN}==========================================${NC}\n\n"

cat << 'EOF'
Quick Start:
  1. Open this project in VS Code
  2. Type /scaffold-project in Copilot Chat to generate a feature checklist
  3. Type /analyze-project to scan existing code and detect features
  4. Type /setup-toolkit to configure all feature toggles

Features (v2.0):
  - Prompt logging       → prompt-log.md
  - Coding fixes log     → coding-fixes-log.md (training-oriented)
  - Functional fixes log → functional-fixes-log.md (training-oriented)
  - Auto README/docs     → auto-updates README.md + project-details.md
  - Feature config       → technical feature matrix (any language)
  - Functionality config → user-facing functionality matrix

Config: .github/project-feature-analyser-prompt-saving.ai-config.json

Docs: https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai#readme
EOF