# Contradictions and cleanup

## Contradictions found
1. Baseline text said "package manager: none (configuration-only repo)."
   - Observed repo uses Bundler and Jekyll (`Gemfile`, `bundle exec jekyll ...`).
   - Resolution: use repo-specific guidance (Bundler/Jekyll) as canonical for this repository.

## Flag for deletion
- "Package manager: none (configuration-only repo)" for this repo context.
- Any repeated global policy blocks copied verbatim into multiple local files.
- Any instruction that references commands or paths not present in this repository.
