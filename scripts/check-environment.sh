#!/usr/bin/env bash
# Local environment validation for this Jekyll repository.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MISE_PATH="$REPO_ROOT/.mise.toml"
CODEX_ENVIRONMENT_PATH="$REPO_ROOT/.codex/environments/environment.toml"
TOOLING_CONTRACT_PATH="$REPO_ROOT/docs/agents/tooling.contract.toml"
TOOLING_DOC_PATH="${TOOLING_DOC_PATH:-$REPO_ROOT/docs/agents/tooling.md}"
RENDER_TOOLING_DOC_SCRIPT="$REPO_ROOT/scripts/render-tooling-doc.sh"

cd "$REPO_ROOT"

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

required_files=(
  "$MISE_PATH"
  "$CODEX_ENVIRONMENT_PATH"
  "$TOOLING_CONTRACT_PATH"
  "$TOOLING_DOC_PATH"
  "$REPO_ROOT/scripts/codex-preflight.sh"
  "$RENDER_TOOLING_DOC_SCRIPT"
)
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: missing required file at $file"
    exit 1
  fi
done

# shellcheck source=/dev/null
source "$REPO_ROOT/scripts/codex-preflight.sh"

mapfile -t REQUIRED_MISE_TOOLS < <(
  "${TOML_PYTHON[@]}" - "$TOOLING_CONTRACT_PATH" <<'PY'
import sys
import tomllib
from pathlib import Path

path = Path(sys.argv[1])
data = tomllib.loads(path.read_text(encoding="utf-8"))
for tool in data.get("required", {}).get("mise_tools", []):
    print(tool)
PY
)

mapfile -t REQUIRED_BINS < <(
  "${TOML_PYTHON[@]}" - "$TOOLING_CONTRACT_PATH" <<'PY'
import sys
import tomllib
from pathlib import Path

path = Path(sys.argv[1])
data = tomllib.loads(path.read_text(encoding="utf-8"))
for tool in data.get("required", {}).get("bins", []):
    print(tool)
PY
)

mapfile -t REQUIRED_CODEX_ACTIONS < <(
  "${TOML_PYTHON[@]}" - "$TOOLING_CONTRACT_PATH" <<'PY'
import sys
import tomllib
from pathlib import Path

path = Path(sys.argv[1])
data = tomllib.loads(path.read_text(encoding="utf-8"))
for action in data.get("codex_actions", []):
    print(f"{action.get('name', '')}|{action.get('icon', '')}")
PY
)

if [[ "${#REQUIRED_BINS[@]}" -eq 0 ]]; then
  echo "Error: no required binaries were found in $TOOLING_CONTRACT_PATH"
  exit 1
fi

bins_csv="$(IFS=,; echo "${REQUIRED_BINS[*]}")"

preflight_repo \
  "" \
  "$bins_csv" \
  "AGENTS.md,docs,scripts,.mise.toml,.codex/environments/environment.toml,docs/agents/tooling.contract.toml,docs/agents/tooling.md,Gemfile,Gemfile.lock"

for tool in "${REQUIRED_MISE_TOOLS[@]}"; do
  tool_pattern="$(printf '%s' "$tool" | sed 's/[][(){}.^$*+?|\\]/\\&/g')"
  if ! rg -q "^[[:space:]]*(\"${tool_pattern}\"|${tool_pattern})[[:space:]]*=" "$MISE_PATH"; then
    echo "Error: required tool '$tool' is not pinned in $MISE_PATH [tools]"
    echo "Fix: add '$tool = \"<version>\"' under [tools]."
    exit 1
  fi
done

for bin in "${REQUIRED_BINS[@]}"; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Error: required binary '$bin' is not installed or not on PATH"
    exit 1
  fi
done

for action in "${REQUIRED_CODEX_ACTIONS[@]}"; do
  name="${action%%|*}"
  icon="${action##*|}"
  if ! awk -v name="$name" -v icon="$icon" '
    prev == "name = \"" name "\"" && $0 == "icon = \"" icon "\"" { found = 1 }
    { prev = $0 }
    END { exit found ? 0 : 1 }
  ' "$CODEX_ENVIRONMENT_PATH"; then
    echo "Error: Codex action '$name' is missing or mapped to the wrong icon in $CODEX_ENVIRONMENT_PATH"
    exit 1
  fi
done

if ! diff -u "$TOOLING_DOC_PATH" <("$RENDER_TOOLING_DOC_SCRIPT" --stdout) >/dev/null; then
  echo "Error: $TOOLING_DOC_PATH is out of sync with $TOOLING_CONTRACT_PATH"
  echo "Fix: run bash scripts/render-tooling-doc.sh"
  exit 1
fi

# Ensure the repository-pinned runtime is active for Ruby/Bundler commands.
mise trust --yes "$MISE_PATH" >/dev/null
eval "$(mise activate bash)"

echo "== runtime checks =="
ruby --version
bundle --version

echo "== bundler install =="
bundle install

echo "== jekyll build =="
bundle exec jekyll build

echo "Environment check passed!"
