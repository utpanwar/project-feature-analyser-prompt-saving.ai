---
description: "Install and configure the Copilot Toolkit. Supports new and existing projects, all feature toggles, and version upgrades. Copies files from user-level install when available."
agent: "agent"
tools: [read, edit, execute]
argument-hint: "Optional: 'new' or 'existing', --exclude <component>, --interactive"
---

# Setup Copilot Toolkit

You are the Copilot Toolkit setup assistant. Your job is to install, configure, and upgrade the toolkit for both new and existing projects.

## Step 1: Determine Context

Detect the current situation:

### Am I in the toolkit repo itself?
Check if `.github/prompts/scaffold-project.prompt.md` AND `install.ps1` (or `install.sh`) AND `templates/feature-config-template.md` all exist in the current directory. If yes, this is the **toolkit source repo** -> run the install script to copy files to VS Code user folder (Step 3A).

### Am I in a user project?
If the above check fails, this is a **user project** -> proceed to Step 2.

## Step 2: Determine Project Mode

If in a user project, detect whether this is a new or existing project:

### Auto-detection:
- **Existing Project**: Has source code files (`.ts`, `.js`, `.py`, `.cs`, `.go`, etc.), has a package manifest (`package.json`, `requirements.txt`, `*.csproj`, `go.mod`, etc.), or already has `.github/` toolkit files
- **New Project**: Empty or near-empty directory, no source code, no package manifest

### User override:
If the user said "new" or "existing" in their prompt, use that. Otherwise, auto-detect.

## Step 3A: Toolkit Repo Mode (Install to VS Code)

1. Detect the operating system:
   - If Windows -> run `./install.ps1` from the repo root
   - If Mac/Linux -> run `./install.sh` from the repo root

2. Pass along any user arguments:
   - `--exclude <component>` -> skip specific components
   - `--interactive` / `-Interactive` -> ask which components to install

3. After the script completes, confirm:
   - Which files were installed
   - Where they were installed
   - Which slash commands are now available

## Step 3B: Existing Project Mode

1. **Check for existing toolkit files in THIS project:**
   - Does `.github/instructions/prompt-logger.instructions.md` exist?
   - Does `.github/project-feature-analyser-prompt-saving.ai-config.json` exist?
   - If yes -> this is an **upgrade/reconfigure**. Check version (see Step 5).
   - If no -> this is a **first-time setup** for an existing project.

2. **Install toolkit files into this project's `.github/` folder:**

   **IMPORTANT: Always try the user-level copy method FIRST, before downloading from GitHub.**

   **Method 1 — Copy from user-level install (preferred, works offline):**

   Check if the VS Code user-level prompts folder has toolkit files:
   - Windows: `%APPDATA%\Code\User\prompts\`
   - Mac: `~/Library/Application Support/Code/User/prompts/`
   - Linux: `~/.config/Code/User/prompts/`

   If that folder exists and contains `prompts/scaffold-project.prompt.md`, copy files from there into THIS project's `.github/` folder using these mappings:

   | Source (user-level prompts folder) | Destination (project .github/) |
   |---|---|
   | `instructions/prompt-logger.instructions.md` | `.github/instructions/prompt-logger.instructions.md` |
   | `instructions/auto-docs.instructions.md` | `.github/instructions/auto-docs.instructions.md` |
   | `prompts/scaffold-project.prompt.md` | `.github/prompts/scaffold-project.prompt.md` |
   | `prompts/analyze-project.prompt.md` | `.github/prompts/analyze-project.prompt.md` |
   | `prompts/setup-toolkit.prompt.md` | `.github/prompts/setup-toolkit.prompt.md` |
   | `project-feature-analyser-prompt-saving.ai-config.json` | `.github/project-feature-analyser-prompt-saving.ai-config.json` |
   | `templates/feature-config-template.md` | `templates/feature-config-template.md` |

   On Windows, run this PowerShell to copy:
   ```powershell
   $src = "$env:APPDATA\Code\User\prompts"
   $dst = ".github"
   $mappings = @(
       @{S="instructions\prompt-logger.instructions.md"; D="$dst\instructions\prompt-logger.instructions.md"},
       @{S="instructions\auto-docs.instructions.md"; D="$dst\instructions\auto-docs.instructions.md"},
       @{S="prompts\scaffold-project.prompt.md"; D="$dst\prompts\scaffold-project.prompt.md"},
       @{S="prompts\analyze-project.prompt.md"; D="$dst\prompts\analyze-project.prompt.md"},
       @{S="prompts\setup-toolkit.prompt.md"; D="$dst\prompts\setup-toolkit.prompt.md"},
       @{S="project-feature-analyser-prompt-saving.ai-config.json"; D="$dst\project-feature-analyser-prompt-saving.ai-config.json"},
       @{S="templates\feature-config-template.md"; D="templates\feature-config-template.md"}
   )
   foreach ($m in $mappings) {
       $s = Join-Path $src $m.S; $d = $m.D
       if (Test-Path $s) {
           $dir = Split-Path -Parent $d
           if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
           Copy-Item -Path $s -Destination $d -Force
           Write-Host "[OK] Copied: $($m.D)"
       }
   }
   ```

   On Mac/Linux, run this bash:
   ```bash
   src="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts"
   [ ! -d "$src" ] && src="$HOME/Library/Application Support/Code/User/prompts"
   dst=".github"
   declare -A MAP=(
       ["instructions/prompt-logger.instructions.md"]="$dst/instructions/prompt-logger.instructions.md"
       ["instructions/auto-docs.instructions.md"]="$dst/instructions/auto-docs.instructions.md"
       ["prompts/scaffold-project.prompt.md"]="$dst/prompts/scaffold-project.prompt.md"
       ["prompts/analyze-project.prompt.md"]="$dst/prompts/analyze-project.prompt.md"
       ["prompts/setup-toolkit.prompt.md"]="$dst/prompts/setup-toolkit.prompt.md"
       ["project-feature-analyser-prompt-saving.ai-config.json"]="$dst/project-feature-analyser-prompt-saving.ai-config.json"
       ["templates/feature-config-template.md"]="templates/feature-config-template.md"
   )
   for s in "${!MAP[@]}"; do
       d="${MAP[$s]}"
       if [ -f "$src/$s" ]; then
           mkdir -p "$(dirname "$d")"
           cp "$src/$s" "$d"
           echo "[OK] Copied: $d"
       fi
   done
   ```

   **IMPORTANT for config file:** If `.github/project-feature-analyser-prompt-saving.ai-config.json` already exists in the target project, do NOT overwrite it. Instead, **merge**: read the existing config, add any new keys from the source config with their defaults, but preserve existing user values.

   **Method 2 — Download from GitHub (fallback, requires internet):**

   Only if user-level prompts folder does NOT have toolkit files, download via:
   - Windows: `irm https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.ps1 | iex`
   - Mac/Linux: `curl -sSL https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.sh | bash`

3. **After installation, run the analysis workflow:**
   - Detect tech stack and ecosystem
   - Generate `feature-config.md` with detected features marked
   - Generate `functionality-config.md` with detected user-facing functionality

4. **Configure all features:**
   Present the user with the current configuration and let them toggle:

   | Feature | Config Key | Default | Current |
   |---|---|---|---|
   | Prompt Logger | `promptLogger` | `true` | [read from config] |
   | Coding Fixes Log | `codingFixesLog` | `true` | [read from config] |
   | Functional Fixes Log | `functionalFixesLog` | `true` | [read from config] |
   | Auto-Sync Features | `autoSyncFeatures` | `false` | [read from config] |
   | Functionality Config | `functionalityConfig` | `true` | [read from config] |
   | Auto README | `autoReadme` | `false` | [read from config] |
   | Auto Project Details | `autoProjectDetails` | `false` | [read from config] |

   Ask: "Would you like to change any of these settings? (list the ones to change, or say 'keep defaults')"

5. **Update .gitignore:**
   Ensure these entries exist in `.gitignore`:
   ```
   .github/project-feature-analyser-prompt-saving.ai-config.json
   prompt-log.md
   coding-fixes-log.md
   functional-fixes-log.md
   feature-config.md
   functionality-config.md
   ```

## Step 3C: New Project Mode

1. **Ask for project details:**
   - "What language/framework will you use?" (e.g., Next.js, Python/FastAPI, .NET, Go)
   - "Briefly describe the project" (optional, helps pre-fill features)

2. **Install toolkit files:**
   - Use the same Method 1 / Method 2 from Step 3B.2 (prefer user-level copy over GitHub download).
   - Create config file with recommended defaults.

3. **Generate feature-config.md:**
   - Run the `/scaffold-project` workflow in Mode A (generate config).
   - Use the language-appropriate template/dynamic generation.
   - Pre-fill based on user's description.

4. **Generate functionality-config.md:**
   - If `functionalityConfig` is `true`, create a blank functionality template.
   - The user will fill this in as they build the project, or it will be auto-synced.

5. **Configure features** (same as Step 3B.4).

6. **Update .gitignore** (same as Step 3B.5).

7. **Tell the user their next steps:**
   > Toolkit is ready! Here is what was set up:
   > - `feature-config.md` — Mark the features you want with `[x]`, then run `/scaffold-project` to build them
   > - `functionality-config.md` — Will auto-track your project's user-facing functionality
   > - Prompt logging is active — implementation tasks are logged to `prompt-log.md`
   > - Coding and functional fixes are logged separately for future learning
   >
   > To build your project, run `/scaffold-project` in Copilot Chat.

## Step 4: Initialize All Subsystems

After setup, verify all subsystems are properly initialized:

1. **Config file exists** at `.github/project-feature-analyser-prompt-saving.ai-config.json`
2. **Prompt logger instruction** exists at `.github/instructions/prompt-logger.instructions.md`
3. **Auto-docs instruction** exists at `.github/instructions/auto-docs.instructions.md`
4. **Templates directory** exists at `templates/` with the feature config template
5. **Gitignore** has all required entries

If any file is missing, copy it from user-level prompts folder (Method 1) or create it with defaults.

## Step 5: Version Check & Upgrade

When running on a project that already has the toolkit:

1. Read the current config's `version` field.
2. The latest version is `2.0.0`.
3. If the current version is older (or missing — treat as `1.0.0`):
   - Inform the user: "Your toolkit is version X. Version 2.0.0 is available with these new features: [list new features]"
   - Offer to upgrade:
     - **Config:** Merge new keys into existing config, preserving user values
     - **Instruction/prompt files:** Overwrite with latest versions from user-level prompts folder (Method 1)
     - If user-level is also outdated, fall back to GitHub download (Method 2)
4. If already on latest version, say so.

### New in v2.0.0:
- Separate fix log files (`coding-fixes-log.md`, `functional-fixes-log.md`) with training-oriented format
- Tag system for fix entries — feeds lessons back into scaffolding
- Language-agnostic project analysis (Python, .NET, Go, Rust, Java support)
- Dynamic feature matrix generation (no hardcoded templates needed)
- Functionality documentation matrix (`functionality-config.md`)
- Auto-generated README and project documentation
- Enhanced setup with new/existing project modes
- Version tracking and upgrade detection

## Components Reference

| Component | Key | What It Does |
|---|---|---|
| `promptLogger` | `promptLogger` | Auto-logs implementation prompts to `prompt-log.md` |
| `codingFixesLog` | `codingFixesLog` | Logs coding bug fixes to `coding-fixes-log.md` with training lessons |
| `functionalFixesLog` | `functionalFixesLog` | Logs functional bug fixes to `functional-fixes-log.md` with training lessons |
| `scaffolder` | — | `/scaffold-project` — generates or builds from feature checklist |
| `analyzer` | — | `/analyze-project` — scans existing project, detects features & functionality |
| `setup` | — | `/setup-toolkit` — this installer/configurator |
| `autoDocs` | `autoReadme`, `autoProjectDetails` | Auto-updates README.md and project-details.md |
| `config` | — | `project-feature-analyser-prompt-saving.ai-config.json` — all feature toggles |
| `template` | — | `feature-config-template.md` — default JS/TS feature checklist |

## Rules

- ALWAYS try copying from user-level prompts folder FIRST before downloading from GitHub
- When upgrading, NEVER overwrite user config values — merge new keys with defaults
- Do NOT manually create prompt/instruction files line by line — use the copy scripts above
- If the install fails, diagnose the error and suggest fixes
- Auto-detect new vs existing project, but let the user override
- Present all configurable features clearly and let the user choose