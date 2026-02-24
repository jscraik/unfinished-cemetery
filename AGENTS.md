schema_version: 1

# Unfinished Cemetery Agent Guidelines

This repository is a Jekyll-based anti-portfolio that publishes archived project postmortems as "headstones."

## Mandatory workflow snippet
1. Explore project first, then invoke skill.
2. IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for any React, Tauri, Apps-SDK-ui, Tailwind, Vite, Storybook + Chat Widget tasks.
3. Add a Table of Contents for docs.

## Required essentials
- Package manager: **Bundler** (`Gemfile`, `bundle install`).
- Non-standard build/typecheck commands: **no typecheck command observed**; build with `bundle exec jekyll build`, serve with `bundle exec jekyll serve`.
- Default compatibility posture: **canonical-only**.

## References (informational)
- Global protocol: /Users/jamiecraik/.codex/AGENTS.md
- Security and standards baseline: /Users/jamiecraik/.codex/instructions/standards.md
- RVCP source of truth: /Users/jamiecraik/.codex/instructions/rvcp-common.md

## Tooling essentials
- Run shell commands with `zsh -lc`.
- Prefer `rg`, `fd`, and `jq` for search, file discovery, and JSON.
- Before choosing tools, read `/Users/jamiecraik/.codex/instructions/tooling.md`.
- Ask before adding dependencies or system settings.
- Execution mode: single-threaded by default; do not parallelize or spawn subagents unless explicitly requested.

## Global discovery order
1. `/Users/jamiecraik/.codex/AGENTS.md`
2. Nearest repo `AGENTS.md`
3. Linked instruction files under `docs/agents/`
4. If conflicts appear, pause and ask which instruction wins.

## Documentation map
### Table of Contents
- [Instruction map](docs/agents/01-instruction-map.md)
- [Tooling and command policy](docs/agents/02-tooling-policy.md)
- [Local memory workflow](docs/agents/03-local-memory.md)
- [Validation and checks](docs/agents/04-validation.md)
- [Contradictions and cleanup](docs/agents/05-contradictions-and-cleanup.md)
