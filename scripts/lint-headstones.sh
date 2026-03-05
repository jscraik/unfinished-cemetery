#!/usr/bin/env bash
set -euo pipefail

MODE="warn"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: scripts/lint-headstones.sh [--mode warn|ci] [--help]

Modes:
  warn  Alias headings are warnings (default)
  ci    Alias headings are enforced after alias_accepted_until date
USAGE
}

while (($# > 0)); do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
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

if [[ "$MODE" != "warn" && "$MODE" != "ci" ]]; then
  echo "Invalid mode: $MODE" >&2
  exit 2
fi

MODE="$MODE" REPO_ROOT="$REPO_ROOT" ruby <<'RUBY'
require 'yaml'
require 'date'

mode = ENV.fetch('MODE', 'warn')
repo_root = ENV.fetch('REPO_ROOT')
schema_path = File.join(repo_root, '_data', 'headstone-schema.yml')
taxonomy_path = File.join(repo_root, '_data', 'headstone-taxonomy.yml')
headstones_glob = File.join(repo_root, '_headstones', '*.md')

schema = YAML.load_file(schema_path)
taxonomy = YAML.load_file(taxonomy_path)

required_frontmatter = schema.fetch('required_frontmatter')
field_types = schema.fetch('field_types')
required_sections = schema.fetch('required_sections')
heading_aliases = schema.fetch('heading_aliases', {})
accepted_until = Date.parse(schema.dig('migration', 'alias_accepted_until').to_s)
allowed_causes = taxonomy.fetch('causes').keys

errors = []
warnings = []

def parse_frontmatter(content)
  return [nil, content] unless content.start_with?("---\n")

  parts = content.split(/^---\s*$/)
  return [nil, content] if parts.length < 3

  frontmatter_text = parts[1]
  body = parts[2..].join("---\n")
  [YAML.safe_load(frontmatter_text, permitted_classes: [Date], aliases: true) || {}, body]
end

def valid_yyyy_mm?(value)
  !!(value.is_a?(String) && value.match?(/^\d{4}-(0[1-9]|1[0-2])$/))
end

Dir.glob(headstones_glob).sort.each do |path|
  rel = path.sub("#{repo_root}/", "")
  content = File.read(path)
  frontmatter, body = parse_frontmatter(content)

  if frontmatter.nil?
    errors << "#{rel}: missing YAML frontmatter"
    next
  end

  required_frontmatter.each do |key|
    value = frontmatter[key]
    errors << "#{rel}: missing required frontmatter key '#{key}'" if value.nil?
  end

  field_types.each do |key, kind|
    value = frontmatter[key]
    next if value.nil?

    case kind
    when 'string'
      errors << "#{rel}: '#{key}' must be a string" unless value.is_a?(String)
    when 'yyyy-mm'
      errors << "#{rel}: '#{key}' must match YYYY-MM" unless valid_yyyy_mm?(value)
    when 'enum'
      errors << "#{rel}: '#{key}' must be one of [#{allowed_causes.join(', ')}]" unless allowed_causes.include?(value)
    when 'string_array'
      unless value.is_a?(Array) && value.all? { |v| v.is_a?(String) }
        errors << "#{rel}: '#{key}' must be an array of strings"
        next
      end

      downcased = value.all? { |v| v == v.downcase }
      errors << "#{rel}: '#{key}' values must be lowercase" unless downcased
    when 'string_or_empty'
      errors << "#{rel}: '#{key}' must be a string (empty allowed)" unless value.is_a?(String)
    when 'boolean'
      errors << "#{rel}: '#{key}' must be boolean" unless value == true || value == false
    when 'float_0_1'
      numeric = value.is_a?(Numeric)
      range_ok = numeric && value >= 0 && value <= 1
      errors << "#{rel}: '#{key}' must be numeric between 0 and 1" unless range_ok
    end
  end

  headings = body.scan(/^##\s+(.+?)\s*$/).flatten
  canonical = headings.map { |h| heading_aliases[h] || h }

  required_sections.each do |section|
    errors << "#{rel}: missing required section '## #{section}'" unless canonical.include?(section)
  end

  headings.each do |h|
    next unless heading_aliases.key?(h)

    msg = "#{rel}: heading alias '## #{h}' should be '## #{heading_aliases[h]}'"
    if mode == 'ci' && Date.today > accepted_until
      errors << msg
    else
      warnings << msg
    end
  end

  if frontmatter['is_revivable'] == true && frontmatter['is_permanently_dead'] == true
    errors << "#{rel}: 'is_revivable' and 'is_permanently_dead' cannot both be true"
  end
end

warnings.each { |w| warn "WARN: #{w}" }
errors.each { |e| warn "ERROR: #{e}" }

if errors.any?
  warn "\nHeadstone lint failed: #{errors.size} error(s), #{warnings.size} warning(s)."
  exit 1
end

puts "Headstone lint passed: 0 error(s), #{warnings.size} warning(s)."
RUBY
