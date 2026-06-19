#!/usr/bin/env bash
# Render docs/agents/tooling.md from docs/agents/tooling.contract.toml.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONTRACT_PATH="$REPO_ROOT/docs/agents/tooling.contract.toml"
OUTPUT_PATH="$REPO_ROOT/docs/agents/tooling.md"
MODE="${1:-}"

if [[ ! -f "$CONTRACT_PATH" ]]; then
  echo "Error: missing tooling contract at $CONTRACT_PATH" >&2
  exit 1
fi

TOML_PYTHON=()
for candidate in python3.13 python3.12 python3.11 python3; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'; then
    TOML_PYTHON=("$candidate")
    break
  fi
done
if [[ "${#TOML_PYTHON[@]}" -eq 0 ]] && command -v uv >/dev/null 2>&1; then
  TOML_PYTHON=(uv run --python 3.12 python)
fi
if [[ "${#TOML_PYTHON[@]}" -eq 0 ]]; then
  echo "Error: Python 3.11+ or uv is required to parse TOML tooling contracts" >&2
  exit 1
fi

render_markdown() {
  "${TOML_PYTHON[@]}" - "$CONTRACT_PATH" <<'PY'
import sys
import tomllib
from pathlib import Path

contract_path = Path(sys.argv[1])
data = tomllib.loads(contract_path.read_text(encoding="utf-8"))
required = data.get("required", {})
mise_tools = required.get("mise_tools", [])
bins = required.get("bins", [])
actions = data.get("codex_actions", [])

lines = []
lines.append("# Tooling inventory")
lines.append("")
lines.append("Canonical source: `docs/agents/tooling.contract.toml`")
lines.append("")
lines.append("## Table of Contents")
lines.append("- [Scope](#scope)")
lines.append("- [Required mise tools](#required-mise-tools)")
lines.append("- [Required binaries](#required-binaries)")
lines.append("- [Required Codex actions](#required-codex-actions)")
lines.append("")
lines.append("## Scope")
lines.append("This document lists only the tooling items enforced by `scripts/check-environment.sh`.")
lines.append("")
lines.append("## Required mise tools")
for tool in mise_tools:
    lines.append(f"- `{tool}`")
lines.append("")
lines.append("## Required binaries")
for tool in bins:
    lines.append(f"- `{tool}`")
lines.append("")
lines.append("## Required Codex actions")
for action in actions:
    name = action.get("name", "")
    icon = action.get("icon", "")
    lines.append(f"- `{name}` (icon: `{icon}`)")
lines.append("")
sys.stdout.write("\n".join(lines))
PY
}

case "$MODE" in
  --stdout)
    render_markdown
    ;;
  "")
    render_markdown >"$OUTPUT_PATH"
    echo "Rendered $OUTPUT_PATH"
    ;;
  *)
    echo "Usage: $0 [--stdout]" >&2
    exit 2
    ;;
esac
