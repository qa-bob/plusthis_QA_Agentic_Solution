#!/usr/bin/env bash
# .claude/hooks/pre-test.sh
#
# Pre-test hook: verify the target site is reachable before Playwright runs.
# Exits with 0 in all cases (unreachable = warning, not error) so CI pipelines
# still collect test results even from flaky or temporarily down sites.
#
# Dual mode:
#   1. Claude Code PreToolUse hook (registered in .claude/settings.json) —
#      receives hook JSON on stdin. Only runs the reachability check when
#      tool_input.command looks like it invokes the test suite; otherwise
#      exits immediately so unrelated Bash calls aren't slowed down.
#   2. Plain CI / npm invocation (e.g. the "pretest" script, or run by hand) —
#      no JSON on stdin, so it always runs the reachability check.
#
# Usage: bash .claude/hooks/pre-test.sh

set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
CONFIG_FILE="site.config.json"

# ── Decide whether to run, based on how we were invoked ─────────────────────

HOOK_INPUT=""
if [[ ! -t 0 ]]; then
  HOOK_INPUT=$(cat || true)
fi

if [[ -n "$HOOK_INPUT" ]]; then
  # Invoked as a Claude Code hook — only act on test-running Bash commands.
  if command -v python3 &>/dev/null; then
    COMMAND=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('tool_input',{}).get('command',''))" "$HOOK_INPUT" 2>/dev/null || echo "")
  else
    COMMAND=$(printf '%s' "$HOOK_INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')
  fi

  if ! printf '%s' "$COMMAND" | grep -qE 'playwright test|npm (run )?test|npm run baseline'; then
    exit 0
  fi
fi

# ── Read site config ─────────────────────────────────────────────────────────

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[$TIMESTAMP] [pre-test] WARNING: $CONFIG_FILE not found. Skipping reachability check."
  exit 0
fi

# Parse URL and name using python3 (available on most CI agents)
# Falls back to grep if python3 is unavailable
if command -v python3 &>/dev/null; then
  SITE_URL=$(python3 -c "import json,sys; c=json.load(open('$CONFIG_FILE')); print(c.get('url',''))" 2>/dev/null || echo "")
  SITE_NAME=$(python3 -c "import json,sys; c=json.load(open('$CONFIG_FILE')); print(c.get('name','Unknown'))" 2>/dev/null || echo "Unknown")
else
  SITE_URL=$(grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | head -1 | sed 's/.*: *"//;s/"//')
  SITE_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | head -1 | sed 's/.*: *"//;s/"//')
fi

# Allow SITE_URL env var to override config file
SITE_URL="${SITE_URL_OVERRIDE:-${SITE_URL}}"

if [[ -z "$SITE_URL" ]]; then
  echo "[$TIMESTAMP] [pre-test] WARNING: Could not determine site URL. Skipping reachability check."
  exit 0
fi

echo "[$TIMESTAMP] [pre-test] Checking reachability: $SITE_NAME → $SITE_URL"

# ── Reachability check ───────────────────────────────────────────────────────

HTTP_STATUS=$(curl \
  --silent \
  --output /dev/null \
  --write-out "%{http_code}" \
  --head \
  --max-time 10 \
  --location \
  "$SITE_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_STATUS" == "000" ]]; then
  echo "[$TIMESTAMP] [pre-test] WARNING: Could not connect to $SITE_URL (curl error / network timeout)."
  echo "[$TIMESTAMP] [pre-test] Tests will run but may fail due to site unavailability."
elif [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 400 ]]; then
  echo "[$TIMESTAMP] [pre-test] OK: $SITE_NAME is reachable (HTTP $HTTP_STATUS)."
elif [[ "$HTTP_STATUS" -ge 500 ]]; then
  echo "[$TIMESTAMP] [pre-test] WARNING: $SITE_NAME returned HTTP $HTTP_STATUS (server error)."
  echo "[$TIMESTAMP] [pre-test] Tests may fail. Proceeding anyway."
else
  echo "[$TIMESTAMP] [pre-test] WARNING: $SITE_NAME returned HTTP $HTTP_STATUS."
fi

# Always exit 0 — do not block test execution
exit 0
