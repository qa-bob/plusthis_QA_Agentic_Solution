# PlusThis QA Agentic Solution

Automated GUI, functional, and regression test suite for the [PlusThis](http://www.plusthis.com/) marketing website, built with **Playwright + TypeScript** using the **Page Object Model (POM)** pattern and **OOP** principles. The suite is structured for agentic execution by [Claude Code](https://code.claude.com/docs/) — see the docs map at the bottom of this file.

## Purpose

This repo tests **one B2B SaaS website** (defined in [`site.config.json`](./site.config.json)) end-to-end without ever creating an account, logging in, or submitting a real form. Coverage spans:

- **Smoke** — the site is up, loads, and has no console errors
- **Navigation** — nav links, routing, menus, breadcrumbs
- **Forms** — field presence, validation, accessibility (never submitted)
- **Functional** — business features: pricing, accordions, search, video, etc.
- **Visual** — screenshot regression across breakpoints
- **Responsive** — layout correctness at mobile/tablet/desktop

## Tech Stack

- [Playwright](https://playwright.dev/) — browser automation and test runner
- TypeScript (strict mode) — typed page objects, fixtures, and tests
- Page Object Model — one class per page/section, no assertions inside page objects
- GitHub Actions — CI (see [`.github/workflows/playwright.yml`](./.github/workflows/playwright.yml))

## Getting Started

### Prerequisites

- Node.js 20 LTS or newer
- Git

### Setup

```bash
# Install dependencies
npm install

# Install Playwright browsers (one-time, or after a Playwright version bump)
npx playwright install --with-deps

# Copy the env template and fill in values if you need to override the target URL
cp .env.example .env
```

`site.config.json` is the source of truth for which site is under test — you normally don't need `.env` unless you want to point at a staging URL via `SITE_URL`.

### Running tests

```bash
npm test                    # full suite, all projects (desktop/mobile/tablet)
npm run test:smoke          # @smoke only
npm run test:navigation     # @navigation only
npm run test:forms          # @forms only
npm run test:visual         # @visual only
npm run test:responsive     # @responsive only
npm run test:headed         # any of the above with a visible browser
npm run report              # open the last HTML report
npm run baseline            # regenerate visual snapshots (review before committing!)
```

Before every `npm test`, a `pretest` hook checks that the target site is reachable and prints a warning (not a failure) if it isn't — see [`.claude/hooks/pre-test.sh`](./.claude/hooks/pre-test.sh).

### Quality gates

```bash
npm run typecheck           # tsc --noEmit — must be clean before finishing any task
npm run lint                # eslint
```

## Project Structure

```
site.config.json          # site URL, name, and per-site flags (hasContactForm, skipVisual, ...)
playwright.config.ts      # projects: desktop, mobile, tablet
src/
  pages/                  # Page Object Model classes, one per page/section
  fixtures/site.fixture.ts  # custom test fixture exposing page objects + siteConfig
  utils/                  # link-checker, visual-helper
  types/                  # SiteConfig interface + loader
tests/
  smoke/  navigation/  forms/  functional/  visual/  responsive/
.claude/                  # Claude Code config: agents, commands, hooks, settings
.github/                  # GitHub-side config: CI workflow, PR template
```

## Contributing rules

These are enforced by convention and reviewed in PRs (see [CLAUDE.md](./CLAUDE.md) for the full, authoritative list):

- **Never submit a form, create an account, or log in** unless `auth.required: true` in `site.config.json`.
- **No hardcoded URLs** in tests — always resolve through `baseURL` / `siteConfig`.
- **No assertions inside page objects** — page objects expose actions, tests hold `expect()`.
- **No `page.waitForTimeout()`** — use `waitForSelector` or Playwright's auto-waiting.
- **Tag every test** with at least one of `@smoke @navigation @forms @functional @visual @responsive`.
- Run `npm run typecheck` before opening a PR.

## Docs map

| File | Purpose |
|------|---------|
| [`CLAUDE.md`](./CLAUDE.md) | Authoritative instructions Claude Code loads every session: architecture rules, tagging reference, do-not list |
| [`AGENTS.md`](./AGENTS.md) | Catalog of the custom subagents in `.claude/agents/` and how to add new ones |
| [`SKILLS.md`](./SKILLS.md) | Catalog of the custom commands/skills in `.claude/commands/` (and `.claude/skills/` going forward) |
| [`.github/README.md`](./.github/README.md) | What lives in `.github/` vs `.claude/`, and why |
