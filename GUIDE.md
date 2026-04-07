# Copilot Toolkit — Detailed Guide

A step-by-step guide covering every workflow, configuration option, and troubleshooting tip for the Copilot Toolkit.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Workflow 1: New Project from Scratch](#workflow-1-new-project-from-scratch)
- [Workflow 2: Existing Project Analysis](#workflow-2-existing-project-analysis)
- [Workflow 3: Recreating a Project](#workflow-3-recreating-a-project)
- [Prompt Log](#prompt-log)
- [Configuration Deep Dive](#configuration-deep-dive)
- [Customizing the Feature Template](#customizing-the-feature-template)
- [Moving to a New Machine](#moving-to-a-new-machine)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

- [VS Code](https://code.visualstudio.com/) (1.99 or later recommended)
- [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) with an active subscription
- Git (for cloning the toolkit repo)

### Installation

Choose one of two modes:

#### Project-Level (single project)

Run this in your project's root directory:

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.ps1 | iex
```

**Mac / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.sh | bash
```

This downloads the toolkit files directly into your project's `.github/` folder. VS Code picks them up immediately.

**What gets created:**
```
your-project/
├── .github/
│   ├── instructions/
│   │   └── prompt-logger.instructions.md
│   ├── prompts/
│   │   ├── scaffold-project.prompt.md
│   │   ├── analyze-project.prompt.md
│   │   └── setup-toolkit.prompt.md
│   └── project-feature-analyser-prompt-saving.ai-config.json
└── templates/
    └── feature-config-template.md
```

#### User-Level (all projects)

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai
./install.ps1        # Windows
./install.sh         # Mac/Linux
```

Files are copied to `<VS Code User Folder>/prompts/`. They become available as slash commands in every workspace.

### Verify Installation

1. Open VS Code (reload if already open: `Ctrl+Shift+P` → `Developer: Reload Window`)
2. Open Copilot Chat (`Ctrl+Shift+I` or click the chat icon)
3. Type `/` — you should see:
   - `/scaffold-project`
   - `/analyze-project`
   - `/setup-toolkit`

---

## Workflow 1: New Project from Scratch

This workflow lets you define what features you want, then have Copilot build them all.

### Step 1: Create an Empty Project

```bash
mkdir my-new-app
cd my-new-app
git init
```

### Step 2: Install Toolkit (if not user-level)

```powershell
# Windows
irm https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.ps1 | iex
```

### Step 3: Generate Feature Checklist

Open VS Code and type in Copilot Chat:

```
/scaffold-project Next.js app with Tailwind CSS
```

This creates `feature-config.md` in your project root with:
- Tech stack pre-filled (Next.js, Tailwind CSS)
- All 17 feature categories with `[ ]` checkboxes

### Step 4: Configure Features

Open `feature-config.md` and mark the features you want:

```markdown
## Tech Stack
- **Framework**: [x] Next.js | [ ] React + Vite | ...
- **Language**: [x] TypeScript | [ ] JavaScript
- **CSS / Styling**: [x] Tailwind CSS | [ ] CSS Modules | ...

## Features

### 1. Project Setup
- [x] Initialize project with selected framework
- [x] TypeScript configuration (tsconfig, path aliases)
- [x] ESLint setup with recommended rules
- [x] Prettier code formatting
- [x] Git setup (.gitignore, .gitattributes)
- [ ] Git hooks (Husky + lint-staged)           ← leave unchecked if not needed
- [x] Folder structure convention
- [x] Environment variables setup

### 2. Authentication & Authorization
- [x] Login page
- [x] Signup / Registration page
- [x] OAuth provider — Google
- [ ] OAuth provider — GitHub                   ← skip this one
- [x] JWT-based authentication
- [ ] Session-based authentication
- [x] Role-based access control (RBAC)
- [ ] Password reset flow
- [ ] Email verification
- [x] Protected routes / middleware
- [x] Auth context / provider
```

### Step 5: Build Everything

Run in Copilot Chat:

```
/scaffold-project
```

Copilot reads `feature-config.md`, sees every `[x]` item, and implements them one by one:
- Creates folder structure
- Installs dependencies
- Generates boilerplate code
- Sets up configurations

### Step 6: Review & Iterate

After scaffolding:
1. Review the generated code
2. To add more features later, check additional boxes in `feature-config.md`
3. Run `/scaffold-project` again — it only builds newly checked features

---

## Workflow 2: Existing Project Analysis

This workflow scans a project you've already built and documents what features are implemented.

### Step 1: Open Your Project

Open the existing project in VS Code.

### Step 2: Run Analysis

Type in Copilot Chat:

```
/analyze-project
```

### Step 3: What Happens

Copilot scans:
- `package.json` — framework, dependencies, scripts
- `tsconfig.json` — TypeScript configuration
- Folder structure — `pages/`, `components/`, `api/`, `prisma/`, etc.
- Config files — `tailwind.config.*`, `.eslintrc.*`, `Dockerfile`, etc.
- Code patterns — auth imports, DB connections, testing frameworks, i18n

### Step 4: Review Generated Config

A `feature-config.md` is created with:

```markdown
## Tech Stack (Detected)
- **Framework**: Next.js 14.2.0
- **Language**: TypeScript
- **Package Manager**: npm
- **Styling**: Styled Components
- **Database**: Not detected
- **ORM**: Not detected
- **Testing**: Not detected
- **State Management**: React Context

## Features

### 1. Project Setup
- [x] Initialize project with selected framework
- [x] TypeScript configuration (tsconfig, path aliases)
- [x] ESLint setup with recommended rules
- [ ] Prettier code formatting
- [x] Git setup (.gitignore, .gitattributes)
...

## Analysis Summary
| Category | Detected | Total | Coverage |
|----------|----------|-------|----------|
| Project Setup | 4 | 9 | 44% |
| Authentication | 0 | 12 | 0% |
| Navigation | 5 | 8 | 63% |
...
```

### Step 5: Fill Gaps (Optional)

See unchecked `[ ]` features you want? Check them and run `/scaffold-project` to add them to your existing project.

### Merge Mode

If `feature-config.md` already exists and you run `/analyze-project` again:
- All existing `[x]` marks are **preserved**
- Newly detected features are marked `[x]`
- Nothing gets unchecked
- Safe to run repeatedly

---

## Workflow 3: Recreating a Project

Use feature-config from one project to build a similar one.

### Step 1: Export from Source Project

Copy `feature-config.md` from Project A.

### Step 2: Paste into New Project

Place it in the root of Project B (an empty or new project).

### Step 3: Adjust if Needed

- Change tech stack (e.g., switch from React to Vue)
- Uncheck features you don't need
- Check additional ones

### Step 4: Build

```
/scaffold-project
```

Copilot implements all checked features using the new tech stack.

This is particularly useful for:
- Creating similar projects for different clients
- Rebuilding a project with a different framework
- Standardizing feature sets across projects

---

## Prompt Log

### How It Works

The prompt logger is an always-on instruction that runs after every Copilot interaction in agent mode. It:

1. Checks if `project-feature-analyser-prompt-saving.ai-config.json` has `promptLogger: true`
2. Determines if files were modified during the interaction
3. If yes → appends a row to `prompt-log.md` at the project root

### Reading the Log

The log is a markdown table:

```markdown
| Date | Prompt Summary | Actions Taken | Files Modified |
|------|---------------|---------------|----------------|
| 2026-04-07 14:30 | Add Google OAuth login | Created auth provider and login page | src/auth/google.ts, pages/login.tsx |
| 2026-04-07 15:15 | Create DataTable component | Built reusable component with pagination | components/DataTable.tsx, hooks/usePagination.ts |
| 2026-04-07 16:00 | Fix navbar responsive bug | Updated media queries in header | components/Header.tsx |
```

### Summarizing the Log

Ask Copilot in chat:

```
Summarize the work done in prompt-log.md for the last week
```

or

```
What features were implemented according to prompt-log.md?
```

### What Gets Logged vs Skipped

| Logged ✅ | Skipped ❌ |
|---|---|
| Creating new components | "What is React Context?" |
| Fixing bugs | "Explain this error" |
| Refactoring code | "How does JWT work?" |
| Adding features | VS Code configuration questions |
| Modifying configs | Conversations about Copilot itself |

### Turning Off Logging

Edit `.github/project-feature-analyser-prompt-saving.ai-config.json`:

```json
{
  "promptLogger": false
}
```

Or exclude it during installation:

```bash
./install.ps1 -Exclude promptLogger    # Windows
./install.sh --exclude promptLogger    # Mac/Linux
```

---

## Configuration Deep Dive

### Config File Location

| Install Mode | Path |
|---|---|
| Project-level | `.github/project-feature-analyser-prompt-saving.ai-config.json` |
| User-level | `<VS Code User Folder>/prompts/project-feature-analyser-prompt-saving.ai-config.json` |

### Settings Reference

#### `promptLogger` (boolean, default: `true`)

Master switch for the prompt logging feature.

```json
"promptLogger": true   // logs every implementation task
"promptLogger": false  // disables logging completely, zero overhead
```

#### `autoSyncFeatures` (boolean, default: `false`)

When enabled, the prompt logger also auto-updates `feature-config.md` after each implementation task.

```json
"autoSyncFeatures": false  // default: run /analyze-project manually to sync
"autoSyncFeatures": true   // auto-marks features [x] after each task (~200 extra context tokens)
```

**How it works when `true`:**
1. After logging a prompt, the logger checks if `feature-config.md` exists
2. It maps the implementation to a feature category
3. If a matching `[ ]` feature exists, it changes it to `[x]`
4. Never unchecks existing `[x]` marks

#### `logSkipPatterns` (string array, default: common Q&A patterns)

Prompts matching these patterns (case-insensitive) are not logged.

```json
"logSkipPatterns": ["Q&A", "explanation", "what is", "how does", "why"]
```

Add patterns to skip domain-specific non-implementation queries:

```json
"logSkipPatterns": ["Q&A", "explanation", "what is", "how does", "why", "compare", "best practice"]
```

#### `maxLogEntries` (number, default: `500`)

Maximum rows in `prompt-log.md`. When the limit is reached, the oldest entry is removed before adding a new one.

```json
"maxLogEntries": 500   // default
"maxLogEntries": 1000  // keep more history
"maxLogEntries": 50    // minimal log
```

---

## Customizing the Feature Template

### Adding a Custom Category

Edit `templates/feature-config-template.md` and add a new section:

```markdown
### 18. Custom Category Name

- [ ] Subcategory item 1
- [ ] Subcategory item 2
- [ ] Subcategory item 3
```

The scaffold and analyze prompts automatically work with any categories they find in the template.

### Removing Categories

Delete the section from the template. Or leave it — unchecked items are simply ignored by the scaffolder.

### Adding Subcategories

Add new `- [ ]` items under any existing category:

```markdown
### 2. Authentication & Authorization
- [ ] Login page
- [ ] Signup / Registration page
- [ ] OAuth provider — Google
- [ ] OAuth provider — GitHub
- [ ] OAuth provider — Apple        ← new subcategory
- [ ] Biometric authentication      ← new subcategory
```

### Per-Stack Templates

If you work with different tech stacks frequently, create multiple templates:

```
templates/
├── feature-config-template.md         # generic (default)
├── feature-config-nextjs.md           # Next.js specific
├── feature-config-express-api.md      # Express API specific
└── feature-config-fullstack.md        # Full-stack specific
```

Then when running scaffold, specify which template:

```
/scaffold-project use the nextjs template
```

---

## Moving to a New Machine

### Option 1: Clone + Install (Recommended)

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai
./install.ps1   # Windows
./install.sh    # Mac/Linux
```

### Option 2: VS Code Profile

1. On the source machine (where toolkit is installed):
   - `File → Preferences → Profiles → Export Profile`
   - Include "User Prompts" in the export
   - Save the `.code-profile` file

2. On the new machine:
   - `File → Preferences → Profiles → Import Profile`
   - Select the saved `.code-profile` file
   - All prompts and instructions are imported

### Option 3: Settings Sync

If you use VS Code Settings Sync, prompt files in the user folder may sync automatically (depends on your sync settings). Check `Settings Sync: Configure` to ensure prompts are included.

---

## Troubleshooting

### Slash commands don't appear

1. **Reload VS Code**: `Ctrl+Shift+P` → `Developer: Reload Window`
2. **Check file location**: Ensure `.github/prompts/*.prompt.md` files exist in your project root OR in the VS Code user prompts folder
3. **Check frontmatter**: Open the `.prompt.md` file and verify the YAML between `---` markers has no syntax errors (no tabs, colons in values must be quoted)
4. **Copilot version**: Ensure GitHub Copilot Chat extension is up to date

### Prompt logger not working

1. **Check config**: Open `.github/project-feature-analyser-prompt-saving.ai-config.json` — is `promptLogger` set to `true`?
2. **Agent mode required**: Prompt logging only works in agent mode (the mode where Copilot can edit files). Ask/Edit modes can't write `prompt-log.md`.
3. **File permissions**: Ensure VS Code has write access to the project root
4. **Check if skipped**: The logger intentionally skips Q&A conversations. Only file-modifying tasks are logged.

### analyze-project misses features

The analyzer detects features through code patterns (imports, file names, dependencies). It may miss:
- Custom implementations that don't use standard libraries
- Features buried in non-standard folder structures
- Private/internal packages not in `package.json`

**Fix**: Manually mark those features `[x]` in `feature-config.md`. The merge mode preserves your manual marks on subsequent runs.

### scaffold-project creates files that conflict with existing ones

The scaffolder checks for existing files before creating. If conflicts occur:
1. The scaffolder should skip existing files (by design)
2. If it doesn't, it may be because the file paths differ slightly
3. Review the generated code and resolve conflicts manually

### Config changes don't take effect

- **Project-level**: Changes apply immediately (instruction reads config each time)
- **User-level**: Reload VS Code after changing the config in the user prompts folder

### Permission errors on install scripts

**Mac/Linux:**
```bash
chmod +x install.sh project-init.sh
```

**Windows:** If PowerShell blocks the script:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./install.ps1
```

---

## Architecture Overview

```
                    ┌─────────────────────────────┐
                    │     project-feature-analyser-prompt-saving.ai repo     │
                    │         (GitHub)              │
                    └──────────┬──────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                     │
          ▼                    ▼                     ▼
   ┌──────────────┐  ┌─────────────────┐  ┌──────────────────┐
   │ project-init │  │  install.ps1/sh │  │  VS Code Profile │
   │  .ps1 / .sh  │  │  (user-level)   │  │    (optional)    │
   └──────┬───────┘  └────────┬────────┘  └────────┬─────────┘
          │                   │                     │
          ▼                   ▼                     ▼
   ┌──────────────┐  ┌─────────────────┐  ┌──────────────────┐
   │  Project's   │  │  VS Code User   │  │  VS Code User    │
   │  .github/    │  │  prompts/       │  │  prompts/        │
   │  folder      │  │  folder         │  │  (via profile)   │
   └──────┬───────┘  └────────┬────────┘  └────────┬─────────┘
          │                   │                     │
          └───────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   VS Code Copilot   │
                    │   loads prompts &   │
                    │   instructions      │
                    └─────────────────────┘
```

---

*For quick reference, see [README.md](README.md).*
