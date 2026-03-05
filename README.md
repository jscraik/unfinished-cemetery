# Unfinished Cemetery

A ritualized archive of abandoned projects. Honoring what died so we can learn what lives.

**Live site:** https://jscraik.github.io/unfinished-cemetery

## What This Is

Most portfolios show curated victories. This shows curated failures — but failures as expertise.

Each "headstone" is a project that died with dignity:
- Birth date (when it started)
- Death date (when it ended)  
- Cause of death (why it ended)
- What it wanted to be (the vision)
- What it taught me (the lesson)
- An epitaph (the essence)

## Why Public?

An **anti-portfolio**. It signals "I know what not to do." It inverts shame into authority.

## Local Development

```bash
# Clone
git clone https://github.com/jscraik/unfinished-cemetery.git
cd unfinished-cemetery

# Install dependencies
bundle install

# Serve locally
bundle exec jekyll serve

# Open http://localhost:4000
```

## Headstone Quality Workflow

Run these checks before opening a PR:

```bash
# 1) Validate schema and required sections
./scripts/lint-headstones.sh --mode ci
# Expected: "Headstone lint passed: 0 error(s), 0 warning(s)."

# 2) Preview structural migrations safely
./scripts/migrate-headstones.sh --dry-run
# Expected: "No migration changes required." (or an explicit proposal list)

# 3) Run viability preflight (baseline)
./scripts/headstone-preflight.sh
# Expected: PASS/WARN/FAIL summary with must-fix and suggestions

# 4) Optional weighted scoring mode
./scripts/headstone-preflight.sh --experimental-scoring --target-cause scope-explosion --target-tags platform,automation
# Expected: includes viability_score in output
```

## Adding a Headstone

1. Create a new file in `_headstones/`
2. Use this frontmatter:

```yaml
---
name: Project Name
birth: 2024-01
death: 2024-06
cause: scope-explosion
tags: [platform, over-ambitious]
repo: https://github.com/jscraik/project (optional)
epitaph: "Short, memorable quote from the project."
---

## What It Wanted To Be

Description of the original vision.

## Why It Died

Honest assessment of what went wrong.

## What Survived

Lessons extracted from the failure.
```

3. Write the eulogy in Markdown
4. Commit and push — GitHub Actions auto-deploys

## Design

- **Jekyll** for static site generation
- **Custom SCSS** — dark theme with accent colors
- **Professional typography** — Cormorant Garamond + Inter
- **Responsive** — works on mobile and desktop
- **No JavaScript frameworks** — vanilla JS for random visit

## License

MIT — use the concept, adapt the design, build your own cemetery.
