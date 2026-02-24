# Tooling and command policy

## Preferred command tools
- Search: `rg`
- File discovery: `fd`
- JSON parsing/validation: `jq`
- Shell wrapper: `zsh -lc`

## Repo command surface (observed)
- Install dependencies: `bundle install`
- Local dev server: `bundle exec jekyll serve`
- Production build: `bundle exec jekyll build`
- Ensure gh exists: `bash scripts/ensure-gh-cli.sh --check-only`
- Refresh archived repos data: `./scripts/fetch_archived_repos.sh`

## Guardrails
- Ask before adding dependencies or changing system settings.
- Keep execution single-threaded unless explicitly requested.
- Prefer existing scripts in `/Users/jamiecraik/dev/unfinished-cemetery/scripts/` over ad-hoc replacements.
