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

## What It Taught Me

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
