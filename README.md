# 🛠️ Copilot Toolkit

**Reusable project blueprints, prompt logging, and feature detection for GitHub Copilot in VS Code.**

Stop repeating prompts. Define your project features once, scaffold them with a single slash command, and automatically log every implementation step.

---

## Quick Start

### Option A: Project-Level Install (one command)

Installs into the current project's `.github/` folder. Works immediately — no rearranging files.

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

**Exclude specific components:**
```bash
./install.ps1 -Exclude promptLogger    # Windows
./install.sh --exclude promptLogger    # Mac/Linux
```

> After install, restart VS Code or reload the window (`Ctrl+Shift+P` → `Developer: Reload Window`).

---

## What's Included

| Component | Slash Command | Description |
|---|---|---|
| **Project Scaffolder** | `/scaffold-project` | Generates a feature checklist → you mark yes/no → re-run to build everything |
| **Project Analyzer** | `/analyze-project` | Scans existing code, detects tech stack + implemented features, generates pre-filled checklist |
| **Prompt Logger** | *(always-on)* | Auto-logs every implementation prompt to `prompt-log.md` in the project root |
| **Setup Toolkit** | `/setup-toolkit` | Installs the toolkit from the cloned repo (VS Code-based install) |

---

## How It Works

### 1. Scaffold a New Project

```
1. Open empty folder in VS Code
2. Type /scaffold-project in Copilot Chat
3. → Generates feature-config.md with 17 categories of checkboxes
4. Edit the file: check [x] features you want
5. Type /scaffold-project again
6. → Copilot implements every checked feature
```

### 2. Analyze an Existing Project

```
1. Open existing project in VS Code
2. Type /analyze-project in Copilot Chat
3. → Scans package.json, folder structure, imports, configs
4. → Generates feature-config.md with detected features marked [x]
5. Review and correct any misdetections
6. Optionally run /scaffold-project to build remaining unchecked features
```

### 3. Recreate a Project

```
1. Copy feature-config.md from Project A to Project B
2. Adjust tech stack section if needed
3. Run /scaffold-project in Project B
4. → Builds the same feature set in a fresh project
```

---

## Configuration

Edit `.github/project-feature-analyser-prompt-saving.ai-config.json` (project-level) or the config in your VS Code user prompts folder (user-level):

```json
{
  "promptLogger": true,
  "autoSyncFeatures": false,
  "logSkipPatterns": ["Q&A", "explanation", "what is", "how does", "why"],
  "maxLogEntries": 500
}
```

| Setting | Default | Description |
|---|---|---|
| `promptLogger` | `true` | Master switch for prompt logging. Set `false` to disable completely. |
| `autoSyncFeatures` | `false` | When `true`, the logger also auto-updates `feature-config.md` after each implementation task (marks matching features `[x]`). |
| `logSkipPatterns` | `[...]` | Prompts matching these patterns are not logged. |
| `maxLogEntries` | `500` | Maximum rows in `prompt-log.md`. Oldest entries are removed when limit is reached. |

---

## Feature Categories

The feature config template includes **17 categories** with detailed subcategories:

<details>
<summary><strong>Click to expand all categories</strong></summary>

1. **Project Setup** — framework init, TypeScript, ESLint, Prettier, Git hooks, folder structure, env vars
2. **Authentication & Authorization** — login/signup, OAuth, JWT/sessions, RBAC, password reset, email verification
3. **Navigation & Layout** — navbar, footer, sidebar, breadcrumbs, responsive layout, mobile menu
4. **Core Pages** — home, about, contact, 404/500, dashboard, profile, settings, legal pages
5. **Data Management** — CRUD, forms + validation, file upload, data tables, pagination, search, filtering, export
6. **API & Networking** — API client, interceptors, error handling, loading states, caching, auth headers
7. **State Management** — global state, Context API, persistent state, URL state, real-time sync
8. **Styling & Theming** — CSS framework, dark/light mode, design tokens, breakpoints, animations, icons
9. **Database** — connection, ORM config, migrations, seed data, connection pooling, indexes
10. **Testing** — unit, component, integration, E2E, mocking, coverage, CI pipeline
11. **DevOps & Deployment** — Docker, docker-compose, CI/CD, env config, health checks, logging
12. **Performance** — lazy loading, code splitting, image/font optimization, caching, bundle analysis
13. **SEO & Analytics** — meta tags, sitemap, robots.txt, analytics, structured data, social cards
14. **Notifications** — toast, email, push notifications, notification center, preferences
15. **Security** — XSS, CSRF, rate limiting, CSP, CORS, security headers, dependency scanning
16. **Internationalization** — multi-language, language switcher, RTL, date/number formatting
17. **Third-Party Integrations** — payments, maps, social, CMS, file storage, error tracking, chat

</details>

---

## Slash Commands Reference

| Command | Mode | What It Does |
|---|---|---|
| `/scaffold-project` | Agent | First run: generates `feature-config.md`. Subsequent runs: builds checked features. |
| `/analyze-project` | Agent | Scans existing project. Creates or merges `feature-config.md` with detected features. |
| `/setup-toolkit` | Agent | Runs the install script to set up toolkit on current machine. |

---

## Prompt Log Format

When `promptLogger` is enabled, every implementation task is logged to `prompt-log.md`:

```markdown
| Date | Prompt Summary | Actions Taken | Files Modified |
|------|---------------|---------------|----------------|
| 2026-04-07 14:30 | Add Google OAuth login | Created auth provider, login page, callback route | src/auth/google.ts, pages/login.tsx, pages/api/auth/callback.ts |
| 2026-04-07 15:15 | Create data table with pagination | Built reusable DataTable component with server-side pagination | components/DataTable.tsx, hooks/usePagination.ts |
```

**What gets logged:**
- Implementation tasks that create, modify, or delete files
- Refactoring, bug fixes, feature additions

**What gets skipped:**
- General Q&A, explanations, "what is X?" questions
- Conversations unrelated to the current project
- Copilot/VS Code configuration questions

---

## Uninstall

**Project-level:** Delete the `.github/instructions/`, `.github/prompts/` folders and `templates/` folder from your project.

**User-level:**
- Windows: Delete `%APPDATA%\Code\User\prompts\`
- Mac: Delete `~/Library/Application Support/Code/User/prompts/`
- Linux: Delete `~/.config/Code/User/prompts/`

---

## FAQ

### Does this increase my Copilot bill?

**No.** Copilot plans (Individual, Business, Enterprise) are flat-rate monthly subscriptions. Instructions and prompts don't change the cost. The only overhead is ~200-400 tokens of context for the always-on prompt logger — negligible vs. the 128K+ context window. Set `promptLogger: false` for truly zero overhead.

### Does it work offline?

After installation, **yes**. All files are local. The only online step is the initial download (curl one-liner or git clone).

### Can I add custom feature categories?

Yes. Edit `templates/feature-config-template.md` (or the copy in your user prompts folder) to add, remove, or modify categories. The scaffold and analyze prompts will automatically work with your custom categories.

### Do I need to commit the toolkit files?

- **Config** (`project-feature-analyser-prompt-saving.ai-config.json`): No — personal preferences, added to `.gitignore` automatically.
- **Prompts & instructions**: Optional. Committing them means team members also get the slash commands.
- **`prompt-log.md`** and **`feature-config.md`**: Up to you. They're in `.gitignore` by default.

### What if `/scaffold-project` doesn't appear in chat?

1. Reload VS Code (`Ctrl+Shift+P` → `Developer: Reload Window`)
2. Check that `.github/prompts/scaffold-project.prompt.md` exists in your project or user prompts folder
3. Type `/` in chat and search for "scaffold"

---

## Portability

### Moving to a New Machine

```bash
git clone https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai.git
cd project-feature-analyser-prompt-saving.ai
./install.ps1   # or ./install.sh
```

### VS Code Profile (Alternative)

1. Install toolkit on one machine
2. `File → Preferences → Profiles → Export Profile`
3. Save the profile
4. On new machine: `File → Preferences → Profiles → Import Profile`

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
