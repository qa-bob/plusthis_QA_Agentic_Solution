# `.github/` vs `.claude/`

These two directories are easy to conflate but serve different systems:

| Directory | Consumed by | Holds |
|-----------|------------|-------|
| `.claude/` | Claude Code | `agents/` (subagents), `commands/` (legacy skills), `skills/` (skills, once migrated — see [SKILLS.md](../SKILLS.md)), `hooks/` (scripts), `settings.json` (permissions + hook wiring) |
| `.github/` | GitHub itself | CI workflows, PR/issue templates, CODEOWNERS |

Claude Code does **not** read agents, skills, or hooks from `.github/` — only from `.claude/` (project scope) or `~/.claude/` (personal scope). `.github/` is GitHub's own convention for repo automation and templates, independent of Claude Code.

## What's in this folder

| Path | Purpose |
|------|---------|
| [`workflows/playwright.yml`](./workflows/playwright.yml) | Runs `npm ci`, installs browsers, and executes the full suite on PRs and pushes to `main`; uploads the HTML report as an artifact |
| [`PULL_REQUEST_TEMPLATE.md`](./PULL_REQUEST_TEMPLATE.md) | Checklist mirroring the rules in [`CLAUDE.md`](../CLAUDE.md) (tagging, no form submission, typecheck clean) |
| [`ISSUE_TEMPLATE/bug_report.md`](./ISSUE_TEMPLATE/bug_report.md) | Template for reporting a site bug found while writing or running tests |

## Related docs

- [`CLAUDE.md`](../CLAUDE.md) — instructions Claude Code loads every session
- [`AGENTS.md`](../AGENTS.md) — catalog of `.claude/agents/`
- [`SKILLS.md`](../SKILLS.md) — catalog of `.claude/commands/` and `.claude/skills/`
