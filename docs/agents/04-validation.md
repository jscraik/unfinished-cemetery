# Validation and checks

## Fail-fast gate
Stop at the first failed validation, fix it, then rerun that gate.

## Validation checklist
1. Confirm docs and links resolve:
   - `rg -n "docs/agents/" /Users/jamiecraik/dev/unfinished-cemetery/AGENTS.md`
2. Validate Ruby/Jekyll build path:
   - `bundle exec jekyll build`
3. Validate GitHub CLI availability when workflows/scripts depend on it:
   - `bash scripts/ensure-gh-cli.sh --check-only`
4. Validate archived repo JSON when regenerated:
   - `jq -e . /Users/jamiecraik/dev/unfinished-cemetery/_data/archived_repos.json`
