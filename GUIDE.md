# Copilot Toolkit — Detailed Guide

A step-by-step guide covering every workflow, configuration option, and troubleshooting tip for the Copilot Toolkit v2.0.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Workflow 1: New Project from Scratch](#workflow-1-new-project-from-scratch)
- [Workflow 2: Existing Project Analysis](#workflow-2-existing-project-analysis)
- [Workflow 3: Recreating a Project](#workflow-3-recreating-a-project)
- [Workflow 4: Fix-Based Learning](#workflow-4-fix-based-learning)
- [Workflow 5: Auto Documentation](#workflow-5-auto-documentation)
- [Prompt Log](#prompt-log)
- [Fix Logs](#fix-logs)
- [Functionality Config](#functionality-config)
- [Configuration Deep Dive](#configuration-deep-dive)
- [Language Support](#language-support)
- [Customizing the Feature Template](#customizing-the-feature-template)
- [Upgrading from v1.x](#upgrading-from-v1x)
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
+-- .github/
|   +-- instructions/
|   |   +-- prompt-logger.instructions.md
|   |   +-- auto-docs.instructions.md
|   +-- prompts/
|   |   +-- scaffold-project.prompt.md
|   |   +-- analyze-project.prompt.md
|   |   +-- setup-toolkit.prompt.md
|   +-- project-feature-analyser-prompt-saving.ai-config.json
+-- templates/
    +-- feature-config-template.md
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

1. Open VS Code (reload if already open: `Ctrl+Shift+P` -> `Developer: Reload Window`)
2. Open Copilot Chat (`Ctrl+Shift+I` or click the chat icon)
3. Type `/` — you should see:
   - `/scaffold-project`
   - `/analyze-project`
   - `/setup-toolkit`

---

## Workflow 1: New Project from Scratch

1. Create an empty folder and open it in VS Code.
2. Open Copilot Chat and type: `/scaffold-project`
3. The scaffolder will:
   - Check for existing project manifests (package.json, requirements.txt, etc.)
   - If none found, ask you for your tech stack/language
   - Generate `feature-config.md` with categories appropriate to your ecosystem
4. Open `feature-config.md` and:
   - Fill in the Tech Stack section (select framework, language, database, etc.)
   - Mark features you want with `[x]`
   - Leave features you don't want as `[ ]`
5. Run `/scaffold-project` again.
6. Copilot will implement every checked feature, creating files, installing dependencies, and setting up the project structure — applying lessons from any existing fix logs.

**Tip:** Use `/setup-toolkit` first to configure all feature toggles (logging, auto-docs, etc.) before scaffolding.

---

## Workflow 2: Existing Project Analysis

1. Open your existing project in VS Code.
2. Run `/analyze-project` in Copilot Chat.
3. The analyzer will:
   - Detect your ecosystem (JS/TS, Python, .NET, Go, etc.)
   - Scan dependencies, config files, folder structure
   - Generate `feature-config.md` with detected features marked `[x]`
   - Generate `functionality-config.md` with detected user-facing functionality
4. Review both files — correct any misdetections.
5. Optionally run `/scaffold-project` to implement unchecked features.

**Merge mode:** If `feature-config.md` already exists, the analyzer preserves existing `[x]` marks and only adds newly detected ones. It never unchecks features.

---

## Workflow 3: Recreating a Project

1. Copy `feature-config.md` from Project A to Project B.
2. Optionally copy `functionality-config.md` too.
3. Adjust the Tech Stack section if the new project uses different tools.
4. Run `/scaffold-project` in Project B.
5. Copilot builds the same feature set in the new project.

---

## Workflow 4: Fix-Based Learning

This is one of the most powerful features in v2.0. When you fix bugs, the toolkit captures the lessons so the agent avoids repeating the same mistakes in future tasks.

### How it works:

1. **You fix a bug** (syntax error, encoding issue, logic error, etc.)
2. **The prompt logger classifies it**:
   - Coding bug (syntax, runtime, types, dependencies) -> `coding-fixes-log.md`
   - Functional bug (logic, behavior, edge cases, UX) -> `functional-fixes-log.md`
3. **A training-oriented entry is logged**:
   - Tags: technology + category (e.g., `powershell`, `encoding`)
   - Lesson Learned: written as a preventive rule ("Always...", "Never...", "When X, ensure Y...")
4. **Next time you scaffold or implement**, the scaffolder reads these logs and applies the lessons.

### Example coding fix entry:

| Date | Tags | Issue | Root Cause | Lesson Learned | Files |
|------|------|-------|-----------|----------------|-------|
| 2026-04-07 10:30 | `powershell`, `encoding` | PS scripts fail with syntax error on Windows | UTF-8 box-drawing chars contain byte 0x94 which maps to smart quote in Windows-1252 | Always save PowerShell scripts with UTF-8 BOM when they contain non-ASCII characters. PowerShell 5.1 reads BOM-less files as ANSI. | install.ps1, project-init.ps1 |

### Example functional fix entry:

| Date | Tags | Issue | Root Cause | Lesson Learned | Files |
|------|------|-------|-----------|----------------|-------|
| 2026-04-08 14:20 | `react`, `state` | Dashboard shows stale data after navigation | useEffect cleanup missing, async fetch updates unmounted component state | When using useEffect with async data fetching, always return a cleanup function that sets an `isMounted` flag to false, and check it before calling setState. | Dashboard.tsx, hooks/useData.ts |

---

## Workflow 5: Auto Documentation

When enabled, the toolkit automatically keeps your README.md and project-details.md up to date.

### Setup:

1. Enable in config:
   ```json
   {
     "autoReadme": true,
     "autoProjectDetails": true
   }
   ```

2. Add markers to README.md:
   ```markdown
   # My Project

   <!-- auto-generated-overview-start -->
   <!-- auto-generated-overview-end -->

   ## Custom Section (won't be touched)
   ...
   ```

3. Create project-details.md:
   ```markdown
   # Project Details

   <!-- auto-generated-start -->
   <!-- auto-generated-end -->

   ## Custom Notes
   ...
   ```

4. The toolkit will regenerate content between the markers after every functionality-level change. Everything outside markers is preserved.

---

## Prompt Log

When `promptLogger` is enabled, every **implementation task** (not bug fixes) is logged to `prompt-log.md`:

```markdown
| Date | Prompt Summary | Actions Taken | Files Modified |
|------|---------------|---------------|----------------|
| 2026-04-08 14:30 | Add Google OAuth login | Created auth provider, login page, callback route | src/auth/google.ts, pages/login.tsx, pages/api/auth/callback.ts |
```

**What gets logged:** Implementation tasks that create, modify, or delete files.

**What gets routed elsewhere:** Bug fixes -> fix log files.

**What gets skipped:** Q&A, explanations, unrelated conversations.

---

## Fix Logs

### coding-fixes-log.md

Captures coding-level bug fixes: syntax errors, encoding issues, runtime exceptions, type errors, dependency problems, build failures, config errors.

### functional-fixes-log.md

Captures functional bug fixes: logic errors, wrong behavior, missing edge cases, UX issues, data flow bugs, API handling errors, race conditions.

### Format (both files):

```markdown
| Date | Tags | Issue Description | Root Cause | Lesson Learned | Files Affected |
```

- **Tags**: Technology tag (`nextjs`, `python`, `dotnet`) + Category tag (`encoding`, `syntax`, `logic`, `state`)
- **Lesson Learned**: Written as a **preventive rule** — not "what was fixed" but "what to do differently next time"

### Toggles:

- `codingFixesLog: true/false` — enable/disable coding fix logging
- `functionalFixesLog: true/false` — enable/disable functional fix logging
- `maxFixLogEntries: 500` — max entries per file (oldest removed when exceeded)

---

## Functionality Config

`functionality-config.md` tracks **user-facing functionality** — what the project does from a user's perspective:

- **User Flows**: Registration, login, checkout, onboarding...
- **Pages/Views**: Home, dashboard, settings, admin...
- **API Endpoints**: CRUD operations per resource
- **Background Services**: Cron jobs, workers, email notifications
- **Admin Features**: User management, content moderation, analytics
- **Integrations**: External services (payments, email, storage)

This is different from `feature-config.md` which tracks **technical features** (how the project is built).

Generated by `/analyze-project`. Toggle with `functionalityConfig: true/false`.

---

## Configuration Deep Dive

### All Settings

| Setting | Type | Default | Description |
|---|---|---|---|
| `version` | string | `"2.0.0"` | Toolkit version for upgrade detection |
| `promptLogger` | bool | `true` | Log implementation tasks to prompt-log.md |
| `codingFixesLog` | bool | `true` | Log coding fixes to coding-fixes-log.md |
| `functionalFixesLog` | bool | `true` | Log functional fixes to functional-fixes-log.md |
| `autoSyncFeatures` | bool | `false` | Auto-mark features in feature-config.md and functionality-config.md as you implement them |
| `functionalityConfig` | bool | `true` | Generate functionality-config.md during analysis |
| `autoReadme` | bool | `false` | Auto-update README.md between markers |
| `autoProjectDetails` | bool | `false` | Auto-update project-details.md between markers |
| `logSkipPatterns` | array | `["Q&A", ...]` | Skip logging for matching prompts |
| `maxLogEntries` | number | `500` | Max rows in prompt-log.md |
| `maxFixLogEntries` | number | `500` | Max rows in each fix log file |

### Recommended Configurations

**Solo developer (full features):**
```json
{
  "promptLogger": true,
  "codingFixesLog": true,
  "functionalFixesLog": true,
  "autoSyncFeatures": true,
  "functionalityConfig": true,
  "autoReadme": true,
  "autoProjectDetails": true
}
```

**Team project (minimal overhead):**
```json
{
  "promptLogger": true,
  "codingFixesLog": true,
  "functionalFixesLog": true,
  "autoSyncFeatures": false,
  "functionalityConfig": false,
  "autoReadme": false,
  "autoProjectDetails": false
}
```

**Logging only (no auto-sync or docs):**
```json
{
  "promptLogger": true,
  "codingFixesLog": true,
  "functionalFixesLog": true,
  "autoSyncFeatures": false,
  "functionalityConfig": false,
  "autoReadme": false,
  "autoProjectDetails": false
}
```

---

## Language Support

The toolkit auto-detects your project's ecosystem:

### JavaScript/TypeScript
- Detected via: `package.json`, `tsconfig.json`
- Frameworks: Next.js, React, Vue, Angular, Express, Fastify, etc.
- Uses the standard 17-category feature template

### Python
- Detected via: `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py`
- Frameworks: Django, Flask, FastAPI, Tornado, etc.
- Categories: Virtual env, Web framework, SQLAlchemy/Django ORM, Celery, pytest, etc.

### .NET (C#/F#)
- Detected via: `*.csproj`, `*.sln`
- Frameworks: ASP.NET Core, Blazor, Minimal APIs
- Categories: Entity Framework, Identity, MediatR, xUnit, Serilog, etc.

### Go
- Detected via: `go.mod`
- Frameworks: Gin, Echo, Fiber, Chi
- Categories: GORM, goroutines, testify, zerolog, Viper, etc.

### Other Languages
- Rust (`Cargo.toml`), Java (`pom.xml`, `build.gradle`), Ruby (`Gemfile`), PHP (`composer.json`), Elixir (`mix.exs`), etc.
- The analyzer dynamically builds categories based on detected patterns.

---

## Customizing the Feature Template

The default template (`templates/feature-config-template.md`) is designed for JS/TS web projects. You can customize it:

1. Edit the template file to add/remove/modify categories
2. The scaffolder and analyzer will use your custom template
3. For non-JS/TS projects, the toolkit generates dynamic categories — no template needed

**Note:** The template is only a starting point. For Python, .NET, Go, etc., the toolkit generates language-appropriate categories automatically.

---

## Upgrading from v1.x

If you have an existing v1.x installation:

1. Run `/setup-toolkit` in any project
2. It will detect the old version (or missing version field)
3. It will offer to upgrade, merging new config keys while preserving your settings
4. Alternatively, re-run the install script — it overwrites prompt files but handles config merging

### What's new in v2.0:
- Separate fix log files with training-oriented format
- Tag system feeding lessons back into scaffolding
- Language-agnostic project analysis (Python, .NET, Go, etc.)
- Dynamic feature matrix generation
- Functionality documentation matrix
- Auto-generated README and project documentation
- Enhanced setup with new/existing project modes
- Version tracking and upgrade detection

---

## Moving to a New Machine

### Option 1: Clone and Install

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai
./install.ps1   # or ./install.sh
```

### Option 2: VS Code Profile

1. Install toolkit on one machine
2. `File -> Preferences -> Profiles -> Export Profile`
3. On new machine: `File -> Preferences -> Profiles -> Import Profile`

### Option 3: Settings Sync

VS Code Settings Sync includes the user prompts folder. Enable it on both machines and the toolkit syncs automatically.

---

## Troubleshooting

### Slash commands don't appear

1. Reload VS Code: `Ctrl+Shift+P` -> `Developer: Reload Window`
2. Check files exist:
   - Project-level: `.github/prompts/scaffold-project.prompt.md`
   - User-level: `%APPDATA%/Code/User/prompts/prompts/scaffold-project.prompt.md`
3. Type `/` in chat and search

### Install script fails with syntax error (Windows)

PowerShell 5.1 reads UTF-8 files without BOM as ANSI. If you see errors about missing `}` or unexpected tokens near box-drawing characters, the file encoding is wrong.

**Fix:** Ensure all `.ps1` files are saved with UTF-8 BOM encoding.

### Fix logs aren't being created

1. Check config: `codingFixesLog` and `functionalFixesLog` must be `true`
2. Fix logs are only created when you fix a bug — not for new implementations
3. The first entry creates the file automatically

### Auto-docs aren't updating

1. Check config: `autoReadme` and/or `autoProjectDetails` must be `true`
2. Files must contain the marker comments (`<!-- auto-generated-... -->`)
3. Only functionality-level changes trigger updates (not formatting/tests)

### Version check says "up to date" but features are missing

Re-run the install script to overwrite prompt files with the latest versions. The version check only looks at the config file's `version` field.

For more help, open an issue: https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai/issues