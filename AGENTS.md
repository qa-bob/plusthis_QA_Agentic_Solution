# Agents

This file catalogs the custom [Claude Code subagents](https://code.claude.com/docs/en/sub-agents) defined in `.claude/agents/`. Claude Code reads `CLAUDE.md`, not `AGENTS.md` — this file is documentation for humans (and for any other AGENTS.md-aware tool), not something Claude loads automatically.

A subagent is a markdown file with YAML frontmatter (`name`, `description`, `tools`, ...) followed by a system prompt. Claude delegates to a subagent automatically when the task matches its `description`, or you can invoke it explicitly ("use the site-analyzer agent...").

## Subagent scope in this repo

Both agents below live in `.claude/agents/` (project scope), so they're shared with the whole team via git and only apply to this repo.

## Catalog

### `site-analyzer`

- **File:** [`.claude/agents/site-analyzer.md`](./.claude/agents/site-analyzer.md)
- **Tools:** `WebFetch`, `WebSearch`, `Read`, `Write`, `Edit`, `Grep`, `Glob`
- **Purpose:** Crawls the live site and produces a fully-populated `site.config.json` (nav items, contact form presence, auth requirements, viewports).
- **Use when:** onboarding a new site, verifying `site.config.json` is still accurate after a redesign, or running `/analyze-site`.

### `test-generator`

- **File:** [`.claude/agents/test-generator.md`](./.claude/agents/test-generator.md)
- **Tools:** `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `WebFetch`
- **Purpose:** Reads `site.config.json` and generates site-specific Playwright spec files (in `tests/custom/`) for functionality the generic suites don't cover — pricing calculators, live chat, unusual nav structures, regression tests for a known bug.
- **Use when:** the site has unique business logic, a client asks for coverage on a specific page, or you need to regression-test a bug that was just fixed.

## Adding a new subagent

1. Create `.claude/agents/<name>.md`.
2. Start with frontmatter — only `name` and `description` are required:
   ```yaml
   ---
   name: my-agent
   description: One sentence on what it does and when Claude should delegate to it.
   tools: Read, Grep, Glob
   model: inherit
   ---
   ```
3. Write the system prompt as the markdown body — this is all the subagent sees, not the rest of this repo's `CLAUDE.md` context, so make it self-contained.
4. Keep tool access minimal: read-only research agents should list `Read, Grep, Glob, WebFetch` (no `Write`/`Edit`/`Bash`) so they can't accidentally modify the suite.
5. Add an entry to the catalog above.
6. Test it by asking Claude to use it by name, or by running any slash command that references it (e.g. `/analyze-site` delegates to `site-analyzer`).

## Rules for agents working in this repo

Every subagent (and the main Claude Code session) must follow the rules in [CLAUDE.md](./CLAUDE.md) — most importantly: never submit forms, never create accounts, no assertions inside page objects, no hardcoded URLs, no `page.waitForTimeout()`. See [CLAUDE.md](./CLAUDE.md) for the complete, authoritative list.
