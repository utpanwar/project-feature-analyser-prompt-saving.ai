#!/usr/bin/env bash
# Copilot Toolkit — User-Level Installer (Mac/Linux)
# Installs toolkit files to the VS Code user prompts folder so they're available in ALL workspaces.
# Usage: ./install.sh [--exclude <component>] [--interactive]

set -euo pipefail

# ─── Parse Arguments ─────────────────────────────────────────────────────────
EXCLUDE=()
INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --exclude)
            shift
            EXCLUDE+=("$1")
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            echo "[ERR] Unknown argument: $1"
            exit 1
            ;;
    esac
done

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }

# ─── Detect VS Code Prompts Folder ──────────────────────────────────────────
PROMPTS_FOLDER=""

case "$(uname -s)" in
    Darwin)
        for candidate in \
            "$HOME/Library/Application Support/Code/User/prompts" \
            "$HOME/Library/Application Support/Code - Insiders/User/prompts"; do
            parent_dir=$(dirname "$candidate")
            if [ -d "$parent_dir" ]; then
                PROMPTS_FOLDER="$candidate"
                break
            fi
        done
        ;;
    Linux)
        for candidate in \
            "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/Code - Insiders/User/prompts"; do
            parent_dir=$(dirname "$candidate")
            if [ -d "$parent_dir" ]; then
                PROMPTS_FOLDER="$candidate"
                break
            fi
        done
        ;;
    *)
        printf "${RED}[ERR] Unsupported OS: $(uname -s)${NC}\n"
        exit 1
        ;;
esac

if [ -z "$PROMPTS_FOLDER" ]; then
    printf "${RED}[ERR] Could not find VS Code user folder. Is VS Code installed?${NC}\n"
    exit 1
fi

# ─── Detect Repo Root ────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$REPO_ROOT/.github/prompts" ]; then
    printf "${RED}[ERR] Run this script from the project-feature-analyser-prompt-saving.ai repo root.${NC}\n"
    exit 1
fi

# ─── Interactive Mode ────────────────────────────────────────────────────────
if [ "$INTERACTIVE" = true ]; then
    printf "\n${BLUE}╔══════════════════════════════════════════╗${NC}\n"
    printf "${BLUE}║  Copilot Toolkit — Interactive Install   ║${NC}\n"
    printf "${BLUE}╚══════════════════════════════════════════╝${NC}\n\n"
    printf "${YELLOW}Select components to install:${NC}\n\n"

    declare -A COMP_NAMES=(
        ["promptLogger"]="Prompt Logger (auto-logs implementation prompts)"
        ["scaffolder"]="Project Scaffolder (/scaffold-project)"
        ["analyzer"]="Project Analyzer (/analyze-project)"
        ["setup"]="Setup Toolkit (/setup-toolkit)"
        ["config"]="Toolkit Configuration"
        ["template"]="Feature Config Template"
    )

    for comp in promptLogger scaffolder analyzer setup config template; do
        read -rp "  Install ${COMP_NAMES[$comp]}? [Y/n] " response
        if [[ "$response" =~ ^[nN]$ ]]; then
            EXCLUDE+=("$comp")
        fi
    done
    echo ""
fi

# ─── File Mappings ───────────────────────────────────────────────────────────
declare -A FILE_MAP=(
    ["promptLogger"]=".github/instructions/prompt-logger.instructions.md|instructions/prompt-logger.instructions.md"
    ["scaffolder"]=".github/prompts/scaffold-project.prompt.md|prompts/scaffold-project.prompt.md"
    ["analyzer"]=".github/prompts/analyze-project.prompt.md|prompts/analyze-project.prompt.md"
    ["setup"]=".github/prompts/setup-toolkit.prompt.md|prompts/setup-toolkit.prompt.md"
    ["config"]=".github/project-feature-analyser-prompt-saving.ai-config.json|project-feature-analyser-prompt-saving.ai-config.json"
    ["template"]="templates/feature-config-template.md|templates/feature-config-template.md"
)

# ─── Main ────────────────────────────────────────────────────────────────────
printf "\n${BLUE}╔══════════════════════════════════════════╗${NC}\n"
printf "${BLUE}║  Copilot Toolkit — User-Level Installer  ║${NC}\n"
printf "${BLUE}╚══════════════════════════════════════════╝${NC}\n\n"

info "Target: $PROMPTS_FOLDER"
echo ""

INSTALLED=0
SKIPPED=0

for comp in promptLogger scaffolder analyzer setup config template; do
    # Check exclusions
    skip=false
    for ex in "${EXCLUDE[@]+"${EXCLUDE[@]}"}"; do
        if [ "$ex" = "$comp" ]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = true ]; then
        IFS='|' read -r _ dst <<< "${FILE_MAP[$comp]}"
        warn "Skipped: $dst (excluded: $comp)"
        ((SKIPPED++))
        continue
    fi

    IFS='|' read -r src dst <<< "${FILE_MAP[$comp]}"
    src_path="$REPO_ROOT/$src"
    dst_path="$PROMPTS_FOLDER/$dst"
    dst_dir=$(dirname "$dst_path")

    mkdir -p "$dst_dir"

    if [ -f "$src_path" ]; then
        cp "$src_path" "$dst_path"
        success "Installed: $dst"
        ((INSTALLED++))
    else
        warn "Source not found: $src"
    fi
done

# ─── Summary ─────────────────────────────────────────────────────────────────
printf "\n${GREEN}══════════════════════════════════════════${NC}\n"
printf "${GREEN}  Installation complete!${NC}\n"
printf "${GREEN}  Files installed: ${INSTALLED}${NC}\n"
if [ "$SKIPPED" -gt 0 ]; then
    printf "${YELLOW}  Files skipped: ${SKIPPED}${NC}\n"
fi
printf "${GREEN}  Location: ${PROMPTS_FOLDER}${NC}\n"
printf "${GREEN}══════════════════════════════════════════${NC}\n\n"

cat << EOF
Available Slash Commands (in any VS Code workspace):
  /scaffold-project  — Generate or build from feature checklist
  /analyze-project   — Scan existing project and detect features
  /setup-toolkit     — Re-run this installer from VS Code

To disable prompt logging:
  Edit: $PROMPTS_FOLDER/project-feature-analyser-prompt-saving.ai-config.json
  Set:  "promptLogger": false

To uninstall:
  Delete the folder: $PROMPTS_FOLDER

Docs: https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai#readme
EOF
