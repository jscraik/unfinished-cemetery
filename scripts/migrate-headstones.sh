#!/usr/bin/env bash
set -euo pipefail

APPLY=false
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: scripts/migrate-headstones.sh [--dry-run|--apply] [--help]

Options:
  --dry-run  Show proposed changes (default)
  --apply    Write migration changes to files
USAGE
}

while (($# > 0)); do
  case "$1" in
    --dry-run)
      APPLY=false
      shift
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

APPLY="$APPLY" REPO_ROOT="$REPO_ROOT" ruby <<'RUBY'
require 'yaml'

apply = ENV.fetch('APPLY', 'false') == 'true'
repo_root = ENV.fetch('REPO_ROOT')
schema_path = File.join(repo_root, '_data', 'headstone-schema.yml')
headstones_glob = File.join(repo_root, '_headstones', '*.md')

schema = YAML.load_file(schema_path)
heading_aliases = schema.fetch('heading_aliases', {})

total_changed = 0

Dir.glob(headstones_glob).sort.each do |path|
  rel = path.sub("#{repo_root}/", "")
  content = File.read(path)

  match = content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
  unless match
    warn "WARN: #{rel}: missing frontmatter, skipping migration"
    next
  end

  frontmatter = match[1]
  body = match[2]
  changed = []

  heading_aliases.each do |from, to|
    pattern = /^##\s+#{Regexp.escape(from)}\s*$/m
    next unless body.match?(pattern)

    body = body.gsub(pattern, "## #{to}")
    changed << "renamed heading '#{from}' -> '#{to}'"
  end

  canonical_survived = body.match?(/^##\s+What Survived\s*$/)
  unless canonical_survived
    body = body.rstrip + "\n\n## What Survived\n\n- _TBD during migration._\n"
    changed << "added missing '## What Survived' section placeholder"
  end

  next if changed.empty?

  total_changed += 1
  if apply
    updated = "---\n#{frontmatter}\n---\n#{body}"
    File.write(path, updated)
    puts "APPLIED: #{rel}"
    changed.each { |c| puts "  - #{c}" }
  else
    puts "DRY-RUN: #{rel}"
    changed.each { |c| puts "  - #{c}" }
  end
end

if total_changed.zero?
  puts "No migration changes required."
else
  mode = apply ? "Applied" : "Proposed"
  puts "#{mode} migration updates for #{total_changed} file(s)."
end
RUBY
