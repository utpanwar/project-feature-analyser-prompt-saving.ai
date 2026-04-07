---
description: "Analyze an existing project to detect implemented features, tech stack, and dependencies. Generates or updates feature-config.md with detected features marked as implemented."
agent: "agent"
tools: [read, search, edit]
argument-hint: "Optional: specify areas to focus on (e.g., 'focus on auth and database')"
---

# Analyze Existing Project

You are a project analyzer. Your job is to scan an existing codebase, detect what features and tech stack are already implemented, and generate (or update) a `feature-config.md` with your findings.

## Step 1: Determine Mode

Check if `feature-config.md` already exists in the project root.

- **Create mode** (file does NOT exist): Generate a fresh config with detected features marked `[x]`
- **Merge mode** (file EXISTS): Preserve all existing `[x]` marks, only add newly detected ones. NEVER uncheck existing features.

## Step 2: Detect Tech Stack

Scan these files and patterns to determine the tech stack:

| What to Detect | Where to Look |
|---|---|
| Framework | `package.json` (next, react, vue, angular, express), config files (next.config.*, vite.config.*, angular.json) |
| Language | `tsconfig.json` existence, file extensions (.ts/.tsx vs .js/.jsx) |
| Package Manager | `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm) |
| CSS/Styling | `tailwind.config.*`, styled-components/emotion in deps, `*.module.css` files, MUI/Chakra in deps |
| Database | `prisma/schema.prisma`, mongoose in deps, pg/mysql2 in deps, `.env` DB connection strings |
| ORM | prisma, drizzle, typeorm, mongoose, sequelize in deps |
| Testing | jest/vitest/mocha in deps, playwright/cypress in deps, `__tests__`/`*.test.*`/`*.spec.*` folders |
| State Mgmt | redux/zustand/mobx/recoil in deps, React Context usage |
| Auth | next-auth/passport/jsonwebtoken/bcrypt in deps, auth-related folders/files |

## Step 3: Detect Implemented Features

For each feature category, search for evidence:

### Project Setup
- [x] if: project has `package.json` with a framework, proper folder structure
- [x] TypeScript if: `tsconfig.json` exists
- [x] Linting if: `.eslintrc*` or `eslint.config.*` exists, `prettier` in deps
- [x] Git if: `.gitignore` exists, `.husky/` folder exists

### Authentication & Authorization
- Search for: `login`, `signup`, `sign-in`, `auth`, `session`, `jwt`, `passport`, `next-auth`, `bcrypt`
- Check `pages/auth/`, `app/auth/`, `components/auth/`, `src/auth/`
- Check deps: `next-auth`, `passport`, `jsonwebtoken`, `bcrypt`, `@auth/*`

### Navigation & Layout
- Search for: navbar, header, footer, sidebar, breadcrumb, layout components
- Check `components/layout/`, `components/common/`, `app/layout.*`

### Core Pages
- Check for page files: home, about, contact, 404, dashboard, profile, settings
- Check `pages/`, `app/`, `src/pages/`, `src/app/`

### Data Management
- Search for: form components, validation (yup, zod, joi), file upload, data table, pagination
- Check deps: `react-hook-form`, `formik`, `yup`, `zod`, `multer`, `dropzone`

### API & Networking
- Search for: API client, axios, fetch wrapper, error handling, interceptors
- Check `api/`, `services/`, `lib/api`, `utils/api`
- Check deps: `axios`, `swr`, `react-query`, `@tanstack/react-query`

### State Management
- Check deps: `redux`, `@reduxjs/toolkit`, `zustand`, `recoil`, `mobx`, `jotai`
- Search for: `createContext`, `useContext`, `Provider`, state store files

### Styling & Theming
- Check for: dark mode toggle, theme provider, CSS variables, design tokens
- Search for: `ThemeProvider`, `dark-mode`, `theme.ts`, `tokens`

### Database
- Check for: `prisma/`, schema files, migration folders, seed files
- Check deps: `prisma`, `mongoose`, `pg`, `mysql2`, `better-sqlite3`
- Search for: database connection, pool configuration

### Testing
- Check for: `__tests__/`, `*.test.*`, `*.spec.*`, test config files
- Check deps: `jest`, `vitest`, `mocha`, `playwright`, `cypress`, `@testing-library/*`
- Check for: CI test scripts in `package.json`

### DevOps & Deployment
- Check for: `Dockerfile`, `docker-compose.*`, `.github/workflows/`, `.gitlab-ci.yml`
- Check for: `.env.example`, `healthpage.*`, `health` endpoint
- Check `package.json` scripts: `build`, `start`, `deploy`

### Performance
- Search for: lazy loading (`React.lazy`, dynamic imports), image optimization (`next/image`)
- Check for: bundle analyzer config, caching headers, service worker

### SEO & Analytics
- Search for: `<meta`, `og:`, `Head`, `Metadata`, sitemap, robots.txt
- Check deps: `next-seo`, `react-helmet`, analytics packages (GA, mixpanel, segment)

### Notifications
- Search for: toast, snackbar, notification component, push notification
- Check deps: `react-toastify`, `sonner`, `notistack`, `firebase-messaging`

### Security
- Search for: CSRF, helmet, rate-limit, sanitize, CSP, CORS configuration
- Check deps: `helmet`, `csurf`, `express-rate-limit`, `dompurify`, `xss`

### Internationalization (i18n)
- Check deps: `i18next`, `next-intl`, `react-intl`, `next-i18next`
- Search for: locale files, translation JSON, `useTranslation`, `t()`

### Third-Party Integrations
- Check deps: `stripe`, `@stripe/stripe-js`, `razorpay`
- Check deps: `@googlemaps/js-api-loader`, `mapbox-gl`, `leaflet`
- Check for: CMS config (contentful, sanity, strapi)
- Check deps: `@aws-sdk/client-s3`, `cloudinary`

## Step 4: Generate or Update feature-config.md

1. Look for the feature config template at:
   - `./templates/feature-config-template.md`
   - `./.github/templates/feature-config-template.md`
   - Fall back to the built-in template from the scaffold prompt

2. **Create mode**: Copy template, mark detected features as `[x]`, leave undetected as `[ ]`. Fill in the Tech Stack section with detected values.

3. **Merge mode**: Read existing `feature-config.md`. For each feature:
   - If already `[x]` → keep as `[x]` (never uncheck)
   - If `[ ]` and now detected → change to `[x]`
   - If `[ ]` and not detected → keep as `[ ]`

4. Add or update a `## Tech Stack (Detected)` section at the top with:
   ```
   ## Tech Stack (Detected)
   - **Framework**: Next.js 14
   - **Language**: TypeScript
   - **Package Manager**: npm
   - **Styling**: Styled Components
   - **Database**: Not detected
   - **ORM**: Not detected
   - **Testing**: Jest
   - **State Management**: React Context
   ```

## Step 5: Output Summary

Print a summary table:

```
## Analysis Summary

| Category | Detected | Total | Coverage |
|----------|----------|-------|----------|
| Project Setup | 4 | 6 | 67% |
| Authentication | 2 | 6 | 33% |
| ... | ... | ... | ... |

### Detected Tech Stack
- Framework: Next.js 14.x
- Language: TypeScript
- ...

### Features Not Detected (may still exist)
- Some features may be implemented but not detected through code patterns.
  Review the generated feature-config.md and manually mark any missing ones.
```

## Rules

- NEVER modify any existing project code — you are read-only for everything except `feature-config.md`
- When uncertain whether a feature is implemented, err on the side of NOT marking it (leave `[ ]`)
- Base detections on concrete evidence (files exist, dependencies installed, code patterns found), not assumptions
- If the user specified areas to focus on, prioritize those but still scan everything
