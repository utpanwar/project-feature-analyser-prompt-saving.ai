# Copilot Toolkit

**Reusable project blueprints, prompt logging, fix-based learning, and feature detection for GitHub Copilot in VS Code.**

Stop repeating prompts. Define your project features once, scaffold them with a single slash command, and automatically log every implementation step. When bugs are fixed, the toolkit captures training-oriented lessons so the same mistakes aren't repeated.

**Works with any language** — JavaScript/TypeScript, Python, .NET, Go, Rust, Java, and more.

---

## Quick Start

### Option A: Project-Level Install (one command)

Installs into the current project's `.github/` folder. Works immediately.

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.ps1 | iex
```

**Mac / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.sh | bash
```

### Option B: User-Level Install (all workspaces)

Installs to VS Code user folder. Slash commands available in every project.

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai

# Windows
./install.ps1

# Mac/Linux
./install.sh
```

**Interactive mode** (choose which components to install):
```bash
./install.ps1 -Interactive    # Windows
./install.sh --interactive    # Mac/Linux
```

> After install, restart VS Code or reload the window (`Ctrl+Shift+P` -> `Developer: Reload Window`).

---

## What's Included

| Component | Slash Command | Description |
|---|---|---|
| **Project Scaffolder** | `/scaffold-project` | Generates a language-appropriate feature checklist -> you mark yes/no -> re-run to build everything |
| **Project Analyzer** | `/analyze-project` | Scans existing code, detects tech stack + features + functionality, generates pre-filled checklists |
| **Prompt Logger** | *(always-on)* | Auto-logs implementation tasks to `prompt-log.md`; routes bug fixes to dedicated fix log files |
| **Coding Fixes Log** | *(always-on)* | Logs coding bug fixes to `coding-fixes-log.md` with training-oriented lessons and tags |
| **Functional Fixes Log** | *(always-on)* | Logs logic/behavior bug fixes to `functional-fixes-log.md` with training-oriented lessons and tags |
| **Auto Documentation** | *(always-on, opt-in)* | Auto-updates `README.md` and `project-details.md` when functionality changes |
| **Functionality Config** | `/analyze-project` | Generates `functionality-config.md` — a matrix of user-facing functionality |
| **Setup Toolkit** | `/setup-toolkit` | Installs, configures, and upgrades the toolkit with new/existing project modes |

---

## How It Works

### 1. Scaffold a New Project

```
1. Open empty folder in VS Code
2. Type /scaffold-project in Copilot Chat
3.   Detects your language OR asks (Python? Next.js? .NET? Go?)
4.   Generates language-appropriate feature-config.md
5. Edit the file: check [x] features you want
6. Type /scaffold-project again
7.   Copilot implements every checked feature
8.   Applies lessons from past fix logs to avoid repeating mistakes
```

### 2. Analyze an Existing Project

```
1. Open existing project in VS Code
2. Type /analyze-project in Copilot Chat
3.   Scans package.json / requirements.txt / *.csproj / go.mod / etc.
4.   Generates feature-config.md with detected features marked [x]
5.   Generates functionality-config.md with detected user-facing functionality
6. Review and correct any misdetections
7. Optionally run /scaffold-project to build remaining unchecked features
```

### 3. Fix-Based Learning

When you fix bugs, the toolkit captures training-oriented lessons:

```
Coding bug fixed? -> coding-fixes-log.md
  | Date | Tags | Issue | Root Cause | Lesson Learned | Files |
  Example: "Always save PowerShell scripts with UTF-8 BOM for PS 5.1 compatibility"

Logic bug fixed? -> functional-fixes-log.md
  | Date | Tags | Issue | Root Cause | Lesson Learned | Files |
  Example: "When using useEffect with async data, always include cleanup to prevent state updates on unmounted components"

Next time /scaffold-project runs, it reads these lessons and applies them.
```

### 4. Setup & Upgrade

```
/setup-toolkit
  -> Auto-detects: new project or existing?
  -> New: scaffolds feature config, configures all toggles
  -> Existing: analyzes project, detects version, offers upgrade
  -> Shows all configurable features with current status
```

---

## Configuration

Edit `.github/project-feature-analyser-prompt-saving.ai-config.json` (project-level) or the config in your VS Code user prompts folder (user-level):

```json
{
  "version": "2.0.0",
  "promptLogger": true,
  "codingFixesLog": true,
  "functionalFixesLog": true,
  "autoSyncFeatures": false,
  "functionalityConfig": true,
  "autoReadme": false,
  "autoProjectDetails": false,
  "logSkipPatterns": ["Q&A", "explanation", "what is", "how does", "why"],
  "maxLogEntries": 500,
  "maxFixLogEntries": 500
}
```

| Setting | Default | Description |
|---|---|---|
| `version` | `"2.0.0"` | Toolkit version. Used for upgrade detection. |
| `promptLogger` | `true` | Master switch for implementation prompt logging to `prompt-log.md`. |
| `codingFixesLog` | `true` | Log coding bug fixes to `coding-fixes-log.md` with training lessons. |
| `functionalFixesLog` | `true` | Log functional bug fixes to `functional-fixes-log.md` with training lessons. |
| `autoSyncFeatures` | `false` | Auto-update `feature-config.md` and `functionality-config.md` after tasks. |
| `functionalityConfig` | `true` | Generate `functionality-config.md` during project analysis. |
| `autoReadme` | `false` | Auto-update README.md between `<!-- auto-generated -->` markers. |
| `autoProjectDetails` | `false` | Auto-update project-details.md between `<!-- auto-generated -->` markers. |
| `logSkipPatterns` | `[...]` | Prompts matching these patterns are not logged. |
| `maxLogEntries` | `500` | Max rows in `prompt-log.md`. Oldest entries removed when exceeded. |
| `maxFixLogEntries` | `500` | Max rows in each fix log file. |

---

## Language Support

The toolkit auto-detects your project's ecosystem and generates appropriate feature matrices:

| Ecosystem | Detection | Example Categories |
|---|---|---|
| **JavaScript/TypeScript** | `package.json`, `tsconfig.json` | 17 standard categories (auth, routing, state mgmt, etc.) |
| **Python** | `requirements.txt`, `pyproject.toml` | Virtual env, Django/Flask/FastAPI, SQLAlchemy, Celery, pytest, etc. |
| **.NET** | `*.csproj`, `*.sln` | ASP.NET, Entity Framework, Identity, MediatR, xUnit, etc. |
| **Go** | `go.mod` | Gin/Echo/Chi, GORM, goroutines, testify, zerolog, etc. |
| **Rust** | `Cargo.toml` | Dynamic categories based on detected crates |
| **Java/Kotlin** | `pom.xml`, `build.gradle` | Spring Boot, JPA, JUnit, etc. |
| **Ruby** | `Gemfile` | Rails, RSpec, ActiveRecord, etc. |
| **PHP** | `composer.json` | Laravel, PHPUnit, Eloquent, etc. |

For unlisted languages, the analyzer builds a dynamic feature matrix based on detected patterns.

---

## Files Generated Per Project

| File | Purpose | Auto-generated? |
|---|---|---|
| `feature-config.md` | Technical feature matrix (what to build) | By `/scaffold-project` or `/analyze-project` |
| `functionality-config.md` | User-facing functionality matrix (what the app does) | By `/analyze-project` |
| `prompt-log.md` | Implementation task log | Automatically after each task |
| `coding-fixes-log.md` | Coding bug fix log with training lessons | Automatically after coding fixes |
| `functional-fixes-log.md` | Functional bug fix log with training lessons | Automatically after logic fixes |
| `README.md` | Project overview (auto-updated sections) | If `autoReadme` is `true` |
| `project-details.md` | Comprehensive project documentation | If `autoProjectDetails` is `true` |

---

## Fix Log Format

Both fix log files use the same training-oriented format:

```markdown
| Date | Tags | Issue Description | Root Cause | Lesson Learned | Files Affected |
|------|------|-------------------|------------|----------------|----------------|
| 2026-04-07 10:30 | `powershell`, `encoding` | PS scripts fail with syntax error | UTF-8 box-drawing chars contain byte 0x94 which maps to smart quote in Windows-1252 | Always save PowerShell scripts with UTF-8 BOM when they contain non-ASCII characters. PS 5.1 reads BOM-less files as ANSI. | install.ps1, project-init.ps1 |
```

**Tags** are dual: one technology tag + one category tag. The scaffolder reads these before implementing features to avoid repeating past mistakes.

---

## Auto Documentation

When `autoReadme` or `autoProjectDetails` is `true`, the toolkit auto-updates docs after functionality-level changes.

**Setup:** Add marker comments to your files:

```markdown
<!-- In README.md -->
<!-- auto-generated-overview-start -->
<!-- auto-generated-overview-end -->

<!-- In project-details.md -->
<!-- auto-generated-start -->
<!-- auto-generated-end -->
```

Only content between markers is regenerated. Everything else is preserved.

---

## Uninstall

**Project-level:** Delete the `.github/instructions/`, `.github/prompts/` folders and `templates/` folder from your project.

**User-level:**
- Windows: Delete `%APPDATA%\Code\User\prompts\`
- Mac: Delete `~/Library/Application Support/Code/User/prompts/`
- Linux: Delete `~/.config/Code/User/prompts/`

---

## FAQ

### Does this work with any programming language?

**Yes.** The toolkit auto-detects your project's ecosystem (Python, .NET, Go, Rust, Java, etc.) and generates language-appropriate feature matrices. The default template is for JS/TS, but `/scaffold-project` and `/analyze-project` dynamically adapt to any language.

### What are fix logs and why should I care?

Fix logs capture bug fixes as **training-oriented lessons** — not just "what was fixed" but "what should the agent do differently next time." When you run `/scaffold-project`, it reads these lessons and applies them, avoiding the same mistakes. Think of it as the agent learning from its errors.

### Does this increase my Copilot bill?

**No.** Copilot plans are flat-rate monthly subscriptions. Instructions and prompts don't change the cost.

### Can I add custom feature categories?

Yes. Edit `templates/feature-config-template.md` for JS/TS projects. For other languages, the toolkit generates dynamic categories automatically.

### Do I need to commit the toolkit files?

- **Config** (`.ai-config.json`): No — personal preferences, in `.gitignore` automatically.
- **Prompts & instructions**: Optional. Committing them means team members also get the slash commands.
- **Log files** (`prompt-log.md`, fix logs): Up to you. They're in `.gitignore` by default.

---

## Portability

### Moving to a New Machine

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai
./install.ps1   # or ./install.sh
```

### Upgrading

Run `/setup-toolkit` in any project — it detects the current version and offers to upgrade if a newer version is available.

---

## License

MIT

---

## Contributing

1. Fork the repo
2. Add/modify files in `.github/` and `templates/`
3. Test by running the install script locally
4. Submit a PR

For detailed walkthroughs and examples, see [GUIDE.md](GUIDE.md).