#!/usr/bin/env bash
# Single source of truth for the agentic-mind-palace state file path.
# Every skill (setup writer + all readers) calls THIS and nothing else,
# so the writer and readers can never resolve to different locations.
#
# Resolution order (first hit wins):
#   1. $AGENTIC_MIND_PALACE_STATE  — explicit override (testing / per-project pinning)
#   2. an existing .state/databases.json found by walking up from $PWD
#      — honors a project-local state you already have; nothing to migrate
#   3. a stable, version-independent user-level path
#      — NOT under $CLAUDE_PLUGIN_ROOT: that path moves when the plugin
#        version bumps, which would orphan your state on every upgrade
set -euo pipefail

if [ -n "${AGENTIC_MIND_PALACE_STATE:-}" ]; then
  printf '%s/databases.json\n' "${AGENTIC_MIND_PALACE_STATE%/}"
  exit 0
fi

d="$PWD"
while [ "$d" != "/" ]; do
  if [ -f "$d/.state/databases.json" ]; then
    printf '%s/.state/databases.json\n' "$d"
    exit 0
  fi
  d="$(dirname "$d")"
done

printf '%s/agentic-mind-palace/databases.json\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
