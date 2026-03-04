# Headstone Schema

## Table of Contents
- [Purpose](#purpose)
- [Required Frontmatter](#required-frontmatter)
- [Optional Frontmatter](#optional-frontmatter)
- [Allowed Cause Taxonomy](#allowed-cause-taxonomy)
- [Required Markdown Sections](#required-markdown-sections)
- [Validation Rules](#validation-rules)

## Purpose
Define a single canonical content contract for files in `/Users/jamiecraik/dev/unfinished-cemetery/_headstones/`.

## Required Frontmatter
- `name` (string)
- `birth` (`YYYY-MM`)
- `death` (`YYYY-MM`)
- `cause` (enum)
- `tags` (array of lowercase strings)
- `repo` (string or empty string)
- `epitaph` (string)

## Optional Frontmatter
- `archived` (boolean)
- `featured` (boolean)
- `domains` (array of lowercase strings)
- `is_revivable` (boolean)
- `is_permanently_dead` (boolean)
- `has_salvaged_code` (boolean)
- `confidence` (float between `0` and `1`)

## Allowed Cause Taxonomy
Defined in `/Users/jamiecraik/dev/unfinished-cemetery/_data/headstone-taxonomy.yml`:
- `scope-explosion`
- `doubt`
- `confusion`
- `theory-trap`
- `policy-risk`
- `compatibility-gap`
- `complexity`

## Required Markdown Sections
Each headstone must include exactly one heading for each canonical section:
- `## What It Wanted To Be`
- `## What Actually Happened`
- `## Why It Died`
- `## What Survived`

## Validation Rules
- Frontmatter keys/types are validated against `/Users/jamiecraik/dev/unfinished-cemetery/_data/headstone-schema.yml`.
- Cause values must exist in `/Users/jamiecraik/dev/unfinished-cemetery/_data/headstone-taxonomy.yml`.
- Missing required sections fail lint.
- Alias headings are warned (not failed) until migration window closes.
