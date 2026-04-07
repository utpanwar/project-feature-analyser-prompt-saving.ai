---
description: "Analyze an existing project to detect implemented features, tech stack, and dependencies. Generates or updates feature-config.md and functionality-config.md. Works with any language — JS/TS, Python, .NET, Go, Rust, Java, and more."
agent: "agent"
tools: [read, search, edit]
argument-hint: "Optional: specify areas to focus on (e.g., 'focus on auth and database') or 'functionality-only' to only generate functionality-config.md"
---

# Analyze Existing Project

You are a project analyzer. Your job is to scan an existing codebase, detect what features and tech stack are already implemented, and generate (or update) a `feature-config.md` and optionally a `functionality-config.md` with your findings.

## Step 1: Detect the Ecosystem

Before doing anything else, determine what kind of project this is by scanning for project manifests:

| Manifest File | Ecosystem |
|---|---|
| `package.json` | JavaScript/TypeScript (Node.js ecosystem) |
| `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `setup.cfg` | Python |
| `*.csproj`, `*.sln`, `*.fsproj` | .NET (C#/F#) |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle`, `build.gradle.kts` | Java/Kotlin (JVM) |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `mix.exs` | Elixir |
| `Package.swift` | Swift |
| `pubspec.yaml` | Dart/Flutter |

If multiple manifests exist (e.g., monorepo), identify the primary language and note the polyglot nature.

## Step 2: Determine Mode

Check if `feature-config.md` already exists in the project root.

- **Create mode** (file does NOT exist): Generate a fresh config with detected features marked `[x]`
- **Merge mode** (file EXISTS): Preserve all existing `[x]` marks, only add newly detected ones. NEVER uncheck existing features.

## Step 3: Detect Tech Stack (Language-Agnostic)

Based on the detected ecosystem, scan the appropriate files:

### JavaScript/TypeScript Projects
| What to Detect | Where to Look |
|---|---|
| Framework | `package.json` (next, react, vue, angular, express, fastify), config files (next.config.*, vite.config.*, angular.json) |
| Language | `tsconfig.json` existence, file extensions (.ts/.tsx vs .js/.jsx) |
| Package Manager | `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun) |
| CSS/Styling | `tailwind.config.*`, styled-components/emotion in deps, `*.module.css` files, MUI/Chakra in deps |
| Database | `prisma/schema.prisma`, mongoose in deps, pg/mysql2 in deps, `.env` DB connection strings |
| ORM | prisma, drizzle, typeorm, mongoose, sequelize in deps |
| Testing | jest/vitest/mocha in deps, playwright/cypress in deps, `__tests__`/`*.test.*`/`*.spec.*` folders |
| State Mgmt | redux/zustand/mobx/recoil in deps, React Context usage |
| Auth | next-auth/passport/jsonwebtoken/bcrypt in deps, auth-related folders/files |

### Python Projects
| What to Detect | Where to Look |
|---|---|
| Framework | `requirements.txt` or `pyproject.toml` (django, flask, fastapi, tornado, aiohttp, starlette) |
| Package Manager | `Pipfile` (pipenv), `pyproject.toml` with `[tool.poetry]` (poetry), `uv.lock` (uv), `requirements.txt` (pip) |
| Type Checking | `mypy.ini`, `pyrightconfig.json`, `pyproject.toml` [tool.mypy], type stubs |
| Linting | `ruff.toml`, `.flake8`, `pyproject.toml` [tool.ruff], `.pylintrc` |
| Formatting | `pyproject.toml` [tool.black], [tool.isort] |
| Database | SQLAlchemy, Django ORM, Tortoise ORM, Peewee in deps; `alembic/` folder, `migrations/` |
| Testing | pytest in deps, `tests/` folder, `conftest.py`, `.coveragerc` |
| Task Queue | celery, rq, dramatiq in deps; `celery.py`, `tasks.py` files |
| Auth | django.contrib.auth, Flask-Login, FastAPI security, python-jose, PyJWT in deps |
| API Docs | Swagger/OpenAPI config, `docs/` folder, Sphinx conf |

### .NET Projects
| What to Detect | Where to Look |
|---|---|
| Framework | `*.csproj` TargetFramework (net6.0, net7.0, net8.0), project type (web, console, library) |
| Web Framework | ASP.NET Core, Blazor, MVC, Razor Pages, Minimal APIs — check `Program.cs`, `Startup.cs` |
| Database | Entity Framework Core in deps, `DbContext` files, `Migrations/` folder, connection strings in `appsettings.json` |
| Auth | Microsoft.AspNetCore.Identity, JWT Bearer config, `[Authorize]` attributes |
| Testing | xUnit, NUnit, MSTest projects, `*.Tests.csproj` |
| DI | Service registrations in `Program.cs`, `Startup.cs` |
| API | Controllers, `[ApiController]`, Swagger/Swashbuckle in deps, minimal API `MapGet`/`MapPost` |
| Logging | Serilog, NLog, Application Insights in deps |
| CQRS | MediatR in deps, Command/Query folders |

### Go Projects
| What to Detect | Where to Look |
|---|---|
| Framework | `go.mod` dependencies (gin, echo, fiber, chi), `main.go` imports |
| Database | GORM, sqlx, database/sql usage, migration files |
| Testing | `*_test.go` files, testify in deps |
| API | Handler/Controller patterns, protobuf files (.proto), gRPC setup |
| Config | Viper, envconfig imports |
| Logging | zerolog, zap, slog imports |

### For Other Languages
Apply the same detection strategy: read the manifest, check dependencies, scan for config files, look for framework-specific patterns, and detect implemented features by evidence.

## Step 4: Detect Implemented Features

Based on the detected ecosystem, dynamically build a feature checklist and scan for evidence of each feature. For each feature:
- Mark `[x]` only if concrete evidence exists (file present, dependency installed, code pattern found)
- Leave `[ ]` if uncertain
- Use the appropriate categories for the ecosystem (see Dynamic Category Generation in scaffold-project.prompt.md)

### For JS/TS Projects — use the standard 17 categories:
Project Setup, Authentication & Authorization, Navigation & Layout, Core Pages, Data Management, API & Networking, State Management, Styling & Theming, Database, Testing, DevOps & Deployment, Performance, SEO & Analytics, Notifications, Security, Internationalization, Third-Party Integrations.

### For Python Projects — use Python-specific categories:
Project Setup, Web Framework, Authentication & Authorization, Database & ORM, API Design, Background Tasks, Testing, Caching, Logging & Monitoring, Security, DevOps & Deployment, Documentation, Third-Party Integrations.

### For .NET Projects — use .NET-specific categories:
Project Setup, Web Framework, Authentication & Authorization, Database & ORM, API Design, Dependency Injection, Background Services, Testing, Caching, Logging & Monitoring, Security, DevOps & Deployment, SignalR, Third-Party Integrations.

### For Go Projects — use Go-specific categories:
Project Setup, Web Framework, Authentication & Authorization, Database, API Design, Concurrency, Testing, Logging & Monitoring, Configuration, DevOps & Deployment, Security.

### For other languages:
Dynamically build categories based on the ecosystem's conventions.

## Step 5: Generate or Update feature-config.md

1. **Create mode**: Generate a feature-config.md with ecosystem-appropriate categories. Mark detected features as `[x]`, leave undetected as `[ ]`. Fill in the Tech Stack section with detected values.

2. **Merge mode**: Read existing `feature-config.md`. For each feature:
   - If already `[x]` -> keep as `[x]` (never uncheck)
   - If `[ ]` and now detected -> change to `[x]`
   - If `[ ]` and not detected -> keep as `[ ]`

3. Add or update a `## Tech Stack (Detected)` section at the top with detected values.

## Step 6: Generate or Update functionality-config.md

Check the config for `functionalityConfig`. If `true` (default), also generate a functionality matrix.

### What is functionality-config.md?

While `feature-config.md` tracks **technical features** (how the project is built), `functionality-config.md` tracks **user-facing functionality** (what the project does). This is the difference between "has JWT auth" (technical) and "user can log in, reset password, and manage their profile" (functional).

### How to Detect Functionality

#### A. Project Overview Detection

Before listing features, determine the project's identity:

1. **What it is**: Infer from routes, content, and primary dependencies. A project with blog posts, MDX files, and no auth is a "blog/content site." A project with products, cart, and Stripe is an "e-commerce store."
2. **Target audience**: Infer from content topics, language, and UX. Technical blog posts → developers. Product pages → shoppers.
3. **Content model**: Look for how data is stored — local files (MDX, JSON), database (Prisma, Django ORM), CMS integration (Contentful, Sanity), or API-driven.
4. **Architecture**: Summarize the stack — static site, SSR app, SPA + API, monolith, microservices, etc.
5. **Key value proposition**: What's the ONE thing this app is built to deliver?

#### B. User Journey Detection

After scanning routes and features, construct 2-4 narratives describing how different types of users move through the app:

- **Identify user personas**: casual visitor, registered user, admin, subscriber, buyer, etc.
- **Trace their path**: entry point → key actions → outcome
- **Note decision points**: where users choose between paths (e.g., search vs. browse, login vs. guest checkout)

#### C. Feature & Route Detection

Scan these to identify user-facing capabilities:

1. **Routes/Pages/Endpoints**: Scan route definitions, page files, controller actions, URL patterns
   - For Next.js: `app/*/page.*`, `pages/*.tsx`
   - For Django: `urls.py`, views
   - For .NET: Controllers, `MapGet`/`MapPost` in Program.cs
   - For Express/FastAPI: route definitions
   - For Go: handler registrations

2. **User Flows**: Identify multi-step processes
   - Registration -> Email verification -> Login
   - Browse -> Add to cart -> Checkout -> Payment
   - Create -> Edit -> Publish -> Share

3. **CRUD Operations**: Identify resources and their operations
   - Users (create, read, update, delete)
   - Products, Posts, Comments, etc.

4. **Background/Automated Functionality**
   - Scheduled jobs, cron tasks
   - Email notifications, webhooks
   - Data sync, imports/exports

5. **Admin/Management Features**
   - Admin panels, dashboards
   - User management, role assignment
   - Content moderation, analytics viewing

### functionality-config.md Format

The generated file must be **descriptive, not just a flat checklist**. Every section needs context so a reader can understand what the project does without looking at the code.

```markdown
# Functionality Configuration

> Auto-generated by Copilot Toolkit. Tracks user-facing functionality and project capabilities.
> Mark items with `[x]` as they are implemented. Use `/analyze-project` to auto-detect.

## Project Overview

> **What this project is:** [1-2 sentence description of the product/site/app and its purpose]
> **Target audience:** [Who uses it — e.g., developers, shoppers, internal team]
> **Content model:** [How content is managed — e.g., local MDX files, CMS, database, API]
> **Architecture:** [High-level stack summary — e.g., "Next.js static site with Tailwind CSS, no backend"]
> **Key value proposition:** [The primary thing it offers users]

## User Journeys

> Describe 2-4 primary user journeys as short narratives showing how a real user moves through the application.

### [Journey Name] (e.g., Casual Reader, New Shopper, Admin User)
[Homepage/Entry point] → [key action] → [next step] → [outcome].
[Add a second sentence if the flow has branches or important details.]

### [Another Journey Name]
...

## User Flows

### [Flow Category] (e.g., Content Discovery, Authentication, Shopping)
> [1-2 sentence description of what this flow covers and why it exists in the app.]

- [ ] [Feature name] — [Brief description of what the user can do and where (route/page)]
- [ ] ...

### [Another Flow Category]
> [1-2 sentence description.]

- [ ] ...

## Pages / Views

### Public Pages
> [1 sentence describing the public-facing surface of the app.]

- [ ] [Page name] ([route]) — [What the user sees/does on this page]
- [ ] ...

### Authenticated Pages
> [1 sentence describing what authenticated users can access.]

- [ ] [Page name] ([route]) — [What the user sees/does on this page]
- [ ] ...

## API Endpoints

### [Resource / Feature Name] (e.g., OG Image Generation, Users API)
> [1 sentence describing what this group of endpoints does.]

- [ ] [METHOD] [path] — [What it returns/does, including key params or runtime info]
- [ ] ...

## Background Services
> [1 sentence: does the project have background/automated tasks? If none exist, state "None currently implemented."]

- [ ] ...

## Admin Features
> [1 sentence: does the project have admin/management capabilities? If none exist, state "None currently implemented."]

- [ ] ...

## Integrations
> [1 sentence: what third-party services does the project connect to? If none, state "None currently connected."]

- [ ] [Integration name] — [What it's used for and current status (connected / UI-only / planned)]
- [ ] ...

---

## Notes

> Provide meaningful context about the project's content model, architecture decisions, and current state. Do NOT just list file names — explain what they mean.

### Content / Data Summary
[Describe what content exists, how it's structured, and how it's managed. Include a table if there are distinct content items.]

### Architecture Notes
[Explain key architecture decisions: static vs dynamic, where data lives, what's generated at build time vs runtime, etc.]

### Not Yet Implemented
[For each major unchecked section, briefly explain WHY it's unchecked — e.g., "No auth layer exists because content is managed via Git" or "Newsletter form exists but no backend provider is connected yet."]
```

### Writing Style Rules for functionality-config.md

1. **Project Overview is mandatory** — always generate it. Infer the purpose from routes, content, and dependencies.
2. **User Journeys are mandatory** — always generate at least 2. Describe how a real person uses the app, not technical flows.
3. **Every section heading (`###`) must have a `>` description line** underneath explaining what the section covers.
4. **Every checklist item must have a description after the `—`** explaining what the user can do, not just naming the feature.
5. **API endpoints must include key params, runtime info, or response format** — not just the HTTP method and path.
6. **The Notes section must explain architecture, content model, and what's NOT implemented and why** — not just list files.
7. **Use "None currently implemented." for empty sections** instead of leaving them blank with just `- [ ] ...`.

### Create vs Merge Mode

Same rules as feature-config.md:
- **Create mode**: Generate with detected functionality marked `[x]`
- **Merge mode**: Preserve existing `[x]`, add newly detected ones, never uncheck

## Step 7: Output Summary

Print a comprehensive summary:

```
## Analysis Summary

### Detected Ecosystem: [Language] / [Framework]

| Category | Detected | Total | Coverage |
|----------|----------|-------|----------|
| Project Setup | 4 | 6 | 67% |
| Authentication | 2 | 6 | 33% |
| ... | ... | ... | ... |

### Detected Tech Stack
- Language: [detected]
- Framework: [detected]
- Package Manager: [detected]
- ...

### Files Generated/Updated
- feature-config.md: [Created / Updated]
- functionality-config.md: [Created / Updated / Skipped (disabled in config)]

### Features Not Detected (may still exist)
- Some features may be implemented but not detected through code patterns.
  Review the generated files and manually mark any missing ones.
```

## Rules

- NEVER modify any existing project code — you are read-only for everything except `feature-config.md` and `functionality-config.md`
- When uncertain whether a feature is implemented, err on the side of NOT marking it (leave `[ ]`)
- Base detections on concrete evidence (files exist, dependencies installed, code patterns found), not assumptions
- If the user specified areas to focus on, prioritize those but still scan everything
- Generate categories appropriate to the detected ecosystem — do NOT force JS/TS categories onto a Python or .NET project
- The functionality-config.md should describe WHAT the app does from a user perspective, not HOW it is built technically
- The functionality-config.md must be **descriptive**: every section needs a context line, every item needs a description after `—`, and the Notes section must explain architecture and unchecked items
- Always include Project Overview and User Journeys in functionality-config.md — these are mandatory, not optional
- Write User Journeys as narratives from the user's perspective, not as technical flow diagrams