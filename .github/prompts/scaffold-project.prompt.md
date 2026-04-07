---
description: "Scaffold a new project from a feature-config.md checklist. Generates the config template on first run, implements checked features on subsequent runs."
agent: "agent"
tools: [read, edit, search, execute]
argument-hint: "Optional: specify tech stack or describe the project"
---

# Scaffold Project from Feature Config

You are a project scaffolder. Your job is to either generate a feature configuration checklist or implement the features marked in an existing one.

## Step 1: Determine Mode

Check if `feature-config.md` exists in the project root.

### Mode A: Generate Config (file does NOT exist)

1. Look for the feature config template at these locations (in order):
   - `./templates/feature-config-template.md` (project-level toolkit)
   - `./.github/templates/feature-config-template.md`
   - If not found, use the built-in template below

2. Copy the template content to `feature-config.md` in the project root

3. If the user provided a tech stack or project description in their prompt, pre-fill the **Tech Stack** section at the top of the config accordingly (e.g., if they said "Next.js with Tailwind", check those options)

4. **STOP HERE.** Tell the user:
   > ✅ Created `feature-config.md` in your project root.
   >
   > **Next steps:**
   > 1. Open `feature-config.md`
   > 2. Mark features you want with `[x]` (leave unwanted ones as `[ ]`)
   > 3. Fill in the Tech Stack section at the top
   > 4. Run `/scaffold-project` again to build everything

### Mode B: Implement Features (file EXISTS)

1. Read `feature-config.md` from the project root
2. Parse the Tech Stack section to understand framework, language, CSS, database choices
3. Collect all subcategories marked with `[x]`
4. Group them by category for organized implementation
5. Implement each checked feature step by step:
   - Follow the tech stack choices (e.g., if Next.js is selected, use Next.js patterns)
   - Create proper folder structure based on the framework
   - Install required dependencies via the chosen package manager
   - Create files with production-quality boilerplate
   - Follow coding standards from any `.instructions.md` files in the project
6. After implementing all features, give a summary of:
   - Files created
   - Dependencies added
   - Any manual steps needed (e.g., "Add your database connection string to `.env`")

## Built-in Template (Fallback)

If no template file is found, generate `feature-config.md` with these categories and checkboxes:

```
# Feature Configuration

## Tech Stack
- Framework: [ ] Next.js | [ ] React + Vite | [ ] Vue | [ ] Angular | [ ] Express | [ ] Other: ___
- Language: [ ] TypeScript | [ ] JavaScript
- Package Manager: [ ] npm | [ ] yarn | [ ] pnpm
- CSS: [ ] Tailwind | [ ] CSS Modules | [ ] Styled Components | [ ] MUI | [ ] Other: ___
- Database: [ ] PostgreSQL | [ ] MongoDB | [ ] MySQL | [ ] SQLite | [ ] None
- ORM: [ ] Prisma | [ ] Drizzle | [ ] Mongoose | [ ] TypeORM | [ ] None

---

## Features

### 1. Project Setup
- [ ] Initialize project with selected framework
- [ ] TypeScript configuration
- [ ] ESLint + Prettier setup
- [ ] Git setup (.gitignore, husky, lint-staged)
- [ ] Folder structure convention
- [ ] Environment variables (.env setup)

### 2. Authentication & Authorization
- [ ] Login / Signup pages
- [ ] OAuth providers (Google, GitHub, etc.)
- [ ] JWT or session-based authentication
- [ ] Role-based access control (RBAC)
- [ ] Password reset flow
- [ ] Email verification

(... include all 17 categories from the template ...)
```

## Rules

- NEVER delete or overwrite existing project files unless the user explicitly asks
- ALWAYS check for existing files before creating new ones
- If a dependency is already installed, skip it
- Follow the project's existing code style if files already exist
- Create meaningful commit-ready code, not stubs or placeholders
