# Skills

This file catalogs the repeatable workflows available to Claude Code in this repo, and explains how to add more.

## Commands vs. skills

[Claude Code skills](https://code.claude.com/docs/en/skills) are the current mechanism for packaging a repeatable workflow behind a `/name` invocation. **Custom commands have been merged into skills**: a file at `.claude/commands/foo.md` and a skill at `.claude/skills/foo/SKILL.md` both create `/foo` and work the same way. This repo currently uses the older `.claude/commands/` layout — those files keep working, but new workflows should be added as `.claude/skills/<name>/SKILL.md` instead, because skills additionally support:

- a directory for supporting files (templates, example output, scripts Claude can execute)
- frontmatter to control who can invoke it (`disable-model-invocation`, `user-invocable`)
- dynamic context injection (`` !`shell command` `` inlined into the prompt before Claude sees it)

## Catalog (current — `.claude/commands/`)

| Command | File | What it does |
|---------|------|---------------|
| `/generate-full-suite` | [`generate-full-suite.md`](./.claude/commands/generate-full-suite.md) | Analyzes the site in `site.config.json` and generates a full POM + test suite across all six tag categories |
| `/analyze-site` | [`analyze-site.md`](./.claude/commands/analyze-site.md) | Inspects a live site and outputs a ready-to-paste `site.config.json`, plus an issues list |
| `/run-smoke` | [`run-smoke.md`](./.claude/commands/run-smoke.md) | Runs `npm run test:smoke` and prints a formatted pass/fail table with fix suggestions |
| `/update-baseline` | [`update-baseline.md`](./.claude/commands/update-baseline.md) | Runs `npm run baseline`, lists updated snapshot files, and reminds you to review before committing |
| `/generate-report` | [`generate-report.md`](./.claude/commands/generate-report.md) | Parses `test-results/results.json` and prints a suite-by-suite summary with failed/flaky test detail |

These pair with the subagents documented in [AGENTS.md](./AGENTS.md): `/analyze-site` delegates to `site-analyzer`, and ad hoc coverage requests delegate to `test-generator`.

## Adding a new skill

Prefer `.claude/skills/<name>/SKILL.md` over `.claude/commands/` for anything new:

```yaml
---
name: my-skill
description: What it does and when Claude (or you) should use it. Put the key trigger phrase first.
disable-model-invocation: true   # only needed for actions with side effects (deploy, commit, etc.)
---

Step-by-step instructions for Claude to follow when this skill runs.
```

Guidelines specific to this repo:

- Skills that only report/read data (smoke run, report generation) can be left model-invocable.
- Skills that mutate the suite's baseline or config (`/update-baseline`, `/generate-full-suite`) should keep `disable-model-invocation: true` so Claude never triggers them on its own.
- Reference `site.config.json` explicitly in the instructions — every skill in this repo should read it first, per [CLAUDE.md](./CLAUDE.md)'s workflow.
- Keep `SKILL.md` under 500 lines; move long reference material (selector cheat sheets, example output) into a sibling file and link to it.

## Migrating an existing command

1. Create `.claude/skills/<name>/`.
2. Move the command's markdown into `.claude/skills/<name>/SKILL.md`, adding `name`/`description` frontmatter.
3. Delete the old `.claude/commands/<name>.md`.
4. Update the catalog table above.
