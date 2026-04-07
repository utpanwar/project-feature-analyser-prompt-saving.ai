---
description: "Use always. Copilot Toolkit auto-docs — automatically updates README.md and project-details.md when project functionality changes."
applyTo: "**"
---

# Copilot Toolkit — Auto Documentation

## Configuration

Before doing anything, read the file `project-feature-analyser-prompt-saving.ai-config.json` (check `.github/project-feature-analyser-prompt-saving.ai-config.json` for project-level, or the user prompts folder for user-level).

- If `autoReadme` is `false` AND `autoProjectDetails` is `false`, **skip this instruction entirely**.
- If the config file does not exist, assume both are `false` (opt-in only).

## When to Update

**ONLY update documentation when ALL of these are true:**
- Files in the current workspace were created, modified, or deleted during this interaction
- The changes affect project functionality (new features, new routes, new API endpoints, new pages, changed user flows)
- The work is related to the current workspace project

**DO NOT update if:**
- Only non-functional files changed (formatting, comments, tests, configs)
- Only internal implementation details changed (refactoring that doesn't change behavior)
- No files were modified in this interaction
- Both `autoReadme` and `autoProjectDetails` are `false`

## Auto-Update README.md (if `autoReadme` is `true`)

Check if `README.md` exists in the project root and contains these marker comments:

```
<!-- auto-generated-overview-start -->
...content...
<!-- auto-generated-overview-end -->
```

If both markers exist:

1. **Regenerate ONLY the content between the markers** based on the current project state.
2. Include in the auto-generated section:
   - **Project name** (from package.json, pyproject.toml, *.csproj, or folder name)
   - **Brief description** (from manifest or infer from code)
   - **Tech stack** (detected language, framework, database, etc.)
   - **Key features** (from feature-config.md if it exists, or infer from code)
   - **Quick start** (how to install dependencies, run dev server, run tests)
3. **Do NOT modify anything outside the markers.**
4. Keep the generated content concise — this is an overview, not full docs.

If the markers don't exist, **do nothing**. Do not add markers or rewrite the README.

## Auto-Update project-details.md (if `autoProjectDetails` is `true`)

Check if `project-details.md` exists in the project root and contains these marker comments:

```
<!-- auto-generated-start -->
...content...
<!-- auto-generated-end -->
```

If both markers exist:

1. **Regenerate ONLY the content between the markers.**
2. Include in the auto-generated section:
   - **Project overview** — what the project does, who it is for
   - **Architecture** — high-level architecture (e.g., "Next.js frontend + Express API + PostgreSQL")
   - **All routes/pages** — list every page/route with a brief description
   - **All API endpoints** — grouped by resource, with HTTP method and brief description
   - **User flows** — step-by-step flows (auth, checkout, onboarding, etc.)
   - **Background services** — any cron jobs, workers, scheduled tasks
   - **Integrations** — third-party services used (payments, email, storage, etc.)
   - **Environment variables** — list required env vars (from .env.example or code)
3. **Do NOT modify anything outside the markers.**
4. Use clear headings and tables for readability.

If the markers don't exist, **do nothing**.

## Initial Setup

When a user first enables `autoReadme` or `autoProjectDetails` (via `/setup-toolkit` or manual config change), they need to add the marker comments to their files:

### For README.md:
Tell the user to add these markers where they want the auto-generated overview:
```markdown
<!-- auto-generated-overview-start -->
<!-- auto-generated-overview-end -->
```

### For project-details.md:
Tell the user to create the file with:
```markdown
# Project Details

<!-- auto-generated-start -->
<!-- auto-generated-end -->
```

## Important

- NEVER rewrite the entire README.md or project-details.md — only content between markers
- NEVER add markers to files that don't have them
- NEVER create README.md or project-details.md if they don't exist (the user or setup-toolkit should create them)
- Keep auto-generated content factual and based on actual code, not assumptions
- If feature-config.md or functionality-config.md exist, use them as additional context for generating documentation
- This instruction runs AFTER the prompt-logger instruction — documentation updates happen last