# Headstone Migration Guide

## Table of Contents
- [Purpose](#purpose)
- [Canonical Section Mapping](#canonical-section-mapping)
- [Timeline](#timeline)
- [Migration Workflow](#migration-workflow)
- [Safety Rules](#safety-rules)

## Purpose
Safely migrate legacy headstones to the canonical schema without losing authored voice.

## Canonical Section Mapping
Current accepted aliases map to `## What Survived`:
- `## What It Taught Me`
- `## The Lesson`
- `## The Code That Survived`
- `## The Irony`
- `## The Aftermath`

## Timeline
- **Now (2026-03-04):** alias headings warn only.
- **2026-04-01:** strict mode for changed headstones.
- **2026-06-30:** alias headings no longer accepted in strict mode.

## Migration Workflow
1. Run dry-run:
   - `scripts/migrate-headstones.sh --dry-run`
2. Review proposed changes.
3. Apply explicit migration:
   - `scripts/migrate-headstones.sh --apply`
4. Re-run lint:
   - `scripts/lint-headstones.sh --mode=ci`

## Safety Rules
- Always run `--dry-run` first.
- Never rewrite paragraph content, only headings/metadata.
- Keep one commit for schema migration changes for easy review/rollback.
