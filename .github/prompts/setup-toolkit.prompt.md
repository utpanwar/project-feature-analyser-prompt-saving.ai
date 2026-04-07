---
description: "Install and configure the Copilot Toolkit. Supports new and existing projects, all feature toggles, and version upgrades."
agent: "agent"
tools: [read, edit, execute]
argument-hint: "Optional: 'new' or 'existing', --exclude <component>, --interactive"
---

# Setup Copilot Toolkit

You are the Copilot Toolkit setup assistant. Your job is to install, configure, and upgrade the toolkit for both new and existing projects.

## Step 1: Determine Context

Detect the current situation:

### Am I in the toolkit repo itself?
Check if `.github/prompts/scaffold-project.prompt.md` AND `install.ps1` (or `install.sh`) AND `templates/feature-config-template.md` all exist in the current directory. If yes, this is the **toolkit source repo** — run the install script to copy files to VS Code user folder.

### Am I in a user project?
If the above check fails, this is a **user project**. Proceed to Step 2.

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

1. **Check for existing toolkit files:**
   - Does `.github/instructions/prompt-logger.instructions.md` exist?
   - Does `.github/project-feature-analyser-prompt-saving.ai-config.json` exist?
   - If yes -> this is an **upgrade/reconfigure**. Check version (see Step 5).
   - If no -> this is a **first-time setup** for an existing project.

2. **First-time setup for existing project:**
   - Inform the user: "I'll analyze your project and set up the Copilot Toolkit."
   - If toolkit source files are available (user-level install exists), use those.
   - Otherwise, download via `project-init.ps1` / `project-init.sh`.
   - After installation, automatically run the `/analyze-project` workflow:
     - Detect tech stack and ecosystem
     - Generate `feature-config.md` with detected features marked
     - Generate `functionality-config.md` with detected user-facing functionality
   - Create the config file with recommended defaults.

3. **Configure all features:**
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

## Step 3C: New Project Mode

1. **Ask for project details:**
   - "What language/framework will you use?" (e.g., Next.js, Python/FastAPI, .NET, Go)
   - "Briefly describe the project" (optional, helps pre-fill features)

2. **Install toolkit files:**
   - Download via `project-init.ps1` / `project-init.sh` OR copy from user-level install.
   - Create config file with recommended defaults.

3. **Generate feature-config.md:**
   - Run the `/scaffold-project` workflow in Mode A (generate config).
   - Use the language-appropriate template/dynamic generation.
   - Pre-fill based on user's description.

4. **Generate functionality-config.md:**
   - If `functionalityConfig` is `true`, create a blank functionality template.
   - The user will fill this in as they build the project, or it will be auto-synced.

5. **Configure features** (same as Step 3B.3).

6. **Tell the user their next steps:**
   > Toolkit is ready! Here is what was set up:
   > - `feature-config.md` — Mark the features you want with `[x]`, then run `/scaffold-project` to build them
   > - `functionality-config.md` — Will auto-track your project's user-facing functionality
   > - Prompt logging is active — implementation tasks are logged to `prompt-log.md`
   > - Coding and functional fixes are logged separately for future learning
   >
   > To build your project, run `/scaffold-project` in Copilot Chat.

## Step 4: Initialize All Subsystems

After setup, ensure all subsystems are properly initialized:

1. **Config file exists** at `.github/project-feature-analyser-prompt-saving.ai-config.json`
2. **Prompt logger instruction** exists at `.github/instructions/prompt-logger.instructions.md`
3. **Auto-docs instruction** exists at `.github/instructions/auto-docs.instructions.md` (if autoReadme or autoProjectDetails is enabled)
4. **Templates directory** exists at `templates/` with the feature config template
5. **Gitignore** has entries for:
   - `.github/project-feature-analyser-prompt-saving.ai-config.json`
   - `prompt-log.md`
   - `coding-fixes-log.md`
   - `functional-fixes-log.md`
   - `feature-config.md`
   - `functionality-config.md`

## Step 5: Version Check & Upgrade

When running on a project that already has the toolkit:

1. Read the current config's `version` field.
2. The latest version is `2.0.0`.
3. If the current version is older (or missing — treat as `1.0.0`):
   - Inform the user: "Your toolkit is version X. Version 2.0.0 is available with these new features: [list new features]"
   - Offer to upgrade: merge new config keys into existing config (preserve user settings), update instruction and prompt files.
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

- ALWAYS run install scripts from the appropriate directory
- Do NOT manually copy files unless install scripts are unavailable
- When upgrading, NEVER overwrite user config values — merge new keys with defaults
- If the install script fails, diagnose the error and suggest fixes
- Auto-detect new vs existing project, but let the user override
- Present all configurable features clearly and let the user choose