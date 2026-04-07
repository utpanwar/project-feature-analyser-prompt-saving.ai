#!/usr/bin/env bash
# Copilot Toolkit — Project-Level Installer
# Installs toolkit files into the current project's .github/ folder.
# Priority: copies from user-level VS Code prompts folder first, falls back to GitHub download.
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

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }

download_file() {
    local url="$1"
    local dest="$2"
    local dir
    dir=$(dirname "$dest")
    mkdir -p "$dir"
    if curl -sSfL "$url" -o "$dest" 2>/dev/null; then
        success "Downloaded: $dest"
        return 0
    else
        warn "Failed to download: $dest (skipped)"
        return 1
    fi
}

# ─── Detect user-level prompts folder ────────────────────────────────────────
USER_PROMPTS=""

case "$(uname -s)" in
    Darwin)
        for candidate in \
            "$HOME/Library/Application Support/Code/User/prompts" \
            "$HOME/Library/Application Support/Code - Insiders/User/prompts"; do
            if [ -f "$candidate/prompts/scaffold-project.prompt.md" ]; then
                USER_PROMPTS="$candidate"
                break
            fi
        done
        ;;
    Linux)
        for candidate in \
            "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/Code - Insiders/User/prompts"; do
            if [ -f "$candidate/prompts/scaffold-project.prompt.md" ]; then
                USER_PROMPTS="$candidate"
                break
            fi
        done
        ;;
esac

# ─── Main ────────────────────────────────────────────────────────────────────
printf "\n${BLUE}+==========================================+${NC}\n"
printf "${BLUE}|  Copilot Toolkit v2.0 — Project Install  |${NC}\n"
printf "${BLUE}+==========================================+${NC}\n\n"

info "Installing into: $(pwd)"

# Check if this is a re-install (upgrade)
IS_UPGRADE=false
if [ -f ".github/prompts/scaffold-project.prompt.md" ]; then
    IS_UPGRADE=true
    info "Existing toolkit detected — upgrading to latest version"
fi

if [ -n "$USER_PROMPTS" ]; then
    info "Source: user-level prompts ($USER_PROMPTS)"
else
    info "Source: GitHub ($BASE_URL)"
fi

# File mappings: user_src|gh_src|dest|is_config
FILE_MAPPINGS=(
    "instructions/prompt-logger.instructions.md|.github/instructions/prompt-logger.instructions.md|.github/instructions/prompt-logger.instructions.md|no"
    "instructions/auto-docs.instructions.md|.github/instructions/auto-docs.instructions.md|.github/instructions/auto-docs.instructions.md|no"
    "prompts/scaffold-project.prompt.md|.github/prompts/scaffold-project.prompt.md|.github/prompts/scaffold-project.prompt.md|no"
    "prompts/analyze-project.prompt.md|.github/prompts/analyze-project.prompt.md|.github/prompts/analyze-project.prompt.md|no"
    "prompts/setup-toolkit.prompt.md|.github/prompts/setup-toolkit.prompt.md|.github/prompts/setup-toolkit.prompt.md|no"
    "project-feature-analyser-prompt-saving.ai-config.json|.github/copilot-toolkit-config.json|.github/project-feature-analyser-prompt-saving.ai-config.json|yes"
    "templates/feature-config-template.md|templates/feature-config-template.md|templates/feature-config-template.md|no"
)

INSTALLED=0
SKIPPED=0
FAILED=0

for mapping in "${FILE_MAPPINGS[@]}"; do
    IFS='|' read -r user_src gh_src dest is_config <<< "$mapping"
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"

    # Config file: merge instead of overwrite if exists
    if [ "$is_config" = "yes" ] && [ -f "$dest" ]; then
        # For config, we need to merge. Use a simple approach:
        # Download/copy new config to temp, then merge keys
        tmp_config=$(mktemp)
        got_source=false

        if [ -n "$USER_PROMPTS" ] && [ -f "$USER_PROMPTS/$user_src" ]; then
            cp "$USER_PROMPTS/$user_src" "$tmp_config"
            got_source=true
        elif curl -sSfL "${BASE_URL}/${gh_src}" -o "$tmp_config" 2>/dev/null; then
            got_source=true
        fi

        if [ "$got_source" = true ] && command -v python3 &>/dev/null; then
            # Use python3 to merge JSON (add missing keys, update version, keep existing values)
            python3 -c "
import json, sys
with open('$dest') as f: existing = json.load(f)
with open('$tmp_config') as f: source = json.load(f)
for k, v in source.items():
    if k not in existing:
        existing[k] = v
if 'version' in source:
    existing['version'] = source['version']
with open('$dest', 'w') as f: json.dump(existing, f, indent=2)
print('ok')
" && success "Merged config: $dest (preserved your settings, added new keys)" && ((INSTALLED++)) || { warn "Config merge failed — kept existing: $dest"; ((SKIPPED++)); }
        elif [ "$got_source" = true ]; then
            # No python3 — just use jq if available, otherwise skip
            if command -v jq &>/dev/null; then
                jq -s '.[0] * .[1] | .version = .[1].version' "$dest" "$tmp_config" > "${dest}.tmp" && mv "${dest}.tmp" "$dest"
                success "Merged config: $dest (preserved your settings, added new keys)"
                ((INSTALLED++))
            else
                warn "No python3 or jq — kept existing config: $dest"
                ((SKIPPED++))
            fi
        else
            warn "Could not fetch source config — kept existing: $dest"
            ((SKIPPED++))
        fi
        rm -f "$tmp_config"
        continue
    fi

    # Non-config files: try user-level first, then GitHub
    copied=false
    if [ -n "$USER_PROMPTS" ] && [ -f "$USER_PROMPTS/$user_src" ]; then
        cp "$USER_PROMPTS/$user_src" "$dest"
        success "Copied: $dest (from user-level)"
        copied=true
        ((INSTALLED++))
    fi

    if [ "$copied" = false ]; then
        if download_file "${BASE_URL}/${gh_src}" "$dest"; then
            ((INSTALLED++))
        else
            ((FAILED++))
        fi
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
if [ "$IS_UPGRADE" = true ]; then
    printf "${GREEN}  Upgrade complete!${NC}\n"
else
    printf "${GREEN}  Installation complete!${NC}\n"
fi
printf "${GREEN}  Files installed: ${INSTALLED}${NC}\n"
if [ "$SKIPPED" -gt 0 ]; then
    printf "${YELLOW}  Files skipped: ${SKIPPED}${NC}\n"
fi
if [ "$FAILED" -gt 0 ]; then
    printf "${YELLOW}  Files failed: ${FAILED}${NC}\n"
fi
printf "${GREEN}==========================================${NC}\n\n"

cat << 'EOF'
Quick Start:
  1. Open this project in VS Code (reload if already open)
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