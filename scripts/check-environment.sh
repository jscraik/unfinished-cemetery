#!/usr/bin/env bash
# Minimal local environment validation for this Jekyll repo.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MISE_PATH="$REPO_ROOT/.mise.toml"
CODEX_ENVIRONMENT_PATH="$REPO_ROOT/.codex/environments/environment.toml"

cd "$REPO_ROOT"

if [[ ! -f "$MISE_PATH" ]]; then
  echo "Error: missing mise config at $MISE_PATH"
  exit 1
fi

if [[ ! -f "$CODEX_ENVIRONMENT_PATH" ]]; then
  echo "Error: missing Codex environment file at $CODEX_ENVIRONMENT_PATH"
  exit 1
fi

if [[ ! -f "$REPO_ROOT/scripts/codex-preflight.sh" ]]; then
  echo "Error: scripts/codex-preflight.sh is missing."
  exit 1
fi

# shellcheck source=/dev/null
source "$REPO_ROOT/scripts/codex-preflight.sh"

preflight_repo \
  "" \
  "git,bash,sed,rg,jq,mise,ruby,bundle" \
  "AGENTS.md,docs,scripts,.mise.toml,.codex/environments/environment.toml,Gemfile,Gemfile.lock"

if ! rg -q '^[[:space:]]*ruby[[:space:]]*=' "$MISE_PATH"; then
  echo "Error: .mise.toml must pin ruby under [tools]."
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
