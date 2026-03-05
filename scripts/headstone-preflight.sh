#!/usr/bin/env bash
set -euo pipefail

FORMAT="text"
EXPERIMENTAL_SCORING=false
TARGET_CAUSE=""
TARGET_TAGS=""
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: scripts/headstone-preflight.sh [options]

Options:
  --format text|json          Output format (default: text)
  --experimental-scoring      Enable weighted viability score output
  --target-cause <cause>      Optional target cause for score adjustment
  --target-tags <a,b,c>       Optional comma-separated tags for score adjustment
  --help                      Show this help
USAGE
}

while (($# > 0)); do
  case "$1" in
    --format)
      FORMAT="${2:-}"
      shift 2
      ;;
    --experimental-scoring)
      EXPERIMENTAL_SCORING=true
      shift
      ;;
    --target-cause)
      TARGET_CAUSE="${2:-}"
      shift 2
      ;;
    --target-tags)
      TARGET_TAGS="${2:-}"
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

if [[ "$FORMAT" != "text" && "$FORMAT" != "json" ]]; then
  echo "Invalid --format: $FORMAT" >&2
  exit 2
fi

FORMAT="$FORMAT" \
EXPERIMENTAL_SCORING="$EXPERIMENTAL_SCORING" \
TARGET_CAUSE="$TARGET_CAUSE" \
TARGET_TAGS="$TARGET_TAGS" \
REPO_ROOT="$REPO_ROOT" \
ruby <<'RUBY'
require 'yaml'
require 'json'
require 'date'

repo_root = ENV.fetch('REPO_ROOT')
format = ENV.fetch('FORMAT', 'text')
experimental_scoring = ENV.fetch('EXPERIMENTAL_SCORING', 'false') == 'true'
target_cause = ENV.fetch('TARGET_CAUSE', '').strip
target_tags = ENV.fetch('TARGET_TAGS', '').split(',').map(&:strip).reject(&:empty?)

headstone_paths = Dir.glob(File.join(repo_root, '_headstones', '*.md')).sort
archived_repos_path = File.join(repo_root, '_data', 'archived_repos.json')
archived_repo_names = if File.exist?(archived_repos_path)
  JSON.parse(File.read(archived_repos_path)).map { |r| r.fetch('name', '').downcase }.reject(&:empty?)
else
  []
end

def parse_document(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
  return nil unless match

  frontmatter = YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
  body = match[2]
  [frontmatter, body]
end

records = []
headstone_paths.each do |path|
  parsed = parse_document(path)
  next if parsed.nil?

  frontmatter, body = parsed
  repo = frontmatter['repo'].to_s
  repo_name = repo.empty? ? '' : repo.split('/').last.to_s.downcase
  is_archived = frontmatter['archived'] == true || (!repo_name.empty? && archived_repo_names.include?(repo_name))
  next unless is_archived

  birth = frontmatter['birth'].to_s
  death = frontmatter['death'].to_s
  duration_months = nil
  if birth.match?(/^\d{4}-(0[1-9]|1[0-2])$/) && death.match?(/^\d{4}-(0[1-9]|1[0-2])$/)
    by, bm = birth.split('-').map(&:to_i)
    dy, dm = death.split('-').map(&:to_i)
    duration_months = (dy - by) * 12 + (dm - bm)
  end

  has_salvaged_code = if !frontmatter['has_salvaged_code'].nil?
    frontmatter['has_salvaged_code'] == true
  else
    body.include?('## What Survived') || body.include?('## The Code That Survived')
  end

  records << {
    name: frontmatter['name'].to_s,
    cause: frontmatter['cause'].to_s,
    tags: Array(frontmatter['tags']).map(&:to_s),
    death: death,
    duration_months: duration_months,
    has_salvaged_code: has_salvaged_code
  }
end

if records.empty?
  payload = {
    status: 'FAIL',
    risk_profile: 'HIGH',
    reasons: ['No archived headstones found; cannot derive viability patterns'],
    must_fix: ['Add or mark archived headstones before running preflight'],
    suggestions: ['Run scripts/fetch_archived_repos.sh and ensure headstones include archive linkage']
  }
  puts(format == 'json' ? JSON.pretty_generate(payload) : "FAIL: #{payload[:reasons].first}")
  exit 1
end

cause_counts = Hash.new(0)
tag_counts = Hash.new(0)
durations = []
latest_deaths = []
salvaged_count = 0
missing_survived_sections = 0

records.each do |r|
  cause_counts[r[:cause]] += 1 unless r[:cause].empty?
  r[:tags].each { |t| tag_counts[t] += 1 unless t.empty? }
  durations << r[:duration_months] unless r[:duration_months].nil?
  latest_deaths << r[:death] if r[:death].match?(/^\d{4}-(0[1-9]|1[0-2])$/)
  salvaged_count += 1 if r[:has_salvaged_code]
  missing_survived_sections += 1 unless r[:has_salvaged_code]
end

total = records.size
top_cause, top_cause_count = cause_counts.max_by { |_, v| v } || ['', 0]
top_cause_share = total.zero? ? 0.0 : top_cause_count.to_f / total.to_f
avg_duration = durations.empty? ? nil : (durations.sum.to_f / durations.size.to_f)
salvage_rate = total.zero? ? 0.0 : salvaged_count.to_f / total.to_f

warnings = []
must_fix = []
suggestions = []

if total < 5
  warnings << "Small evidence set (#{total} archived headstones); treat recommendations cautiously"
  suggestions << "Capture more archived projects to improve preflight signal strength"
end

if top_cause_share >= 0.5
  warnings << "Cause concentration is high (#{top_cause}: #{(top_cause_share * 100).round(1)}%)"
  must_fix << "Review repeated failure motif '#{top_cause}' before starting a similar project"
end

if !avg_duration.nil? && avg_duration <= 2.0
  warnings << "Average project lifespan is short (#{avg_duration.round(2)} months)"
  suggestions << "Reduce scope and set a 2-week checkpoint before adding features"
end

if salvage_rate < 0.3
  warnings << "Low salvage density (#{(salvage_rate * 100).round(1)}% mention reusable outcomes)"
  must_fix << "Define explicit salvage milestones so a failed project still yields reusable assets"
end

if cause_counts['policy-risk'].to_i.to_f / total.to_f >= 0.4
  warnings << "Policy risk is overrepresented in failures"
  must_fix << "Validate policy and account safety constraints before implementation"
end

risk_profile =
  if warnings.size >= 3
    'HIGH'
  elsif warnings.size >= 1
    'MEDIUM'
  else
    'LOW'
  end

status = case risk_profile
when 'HIGH' then 'FAIL'
when 'MEDIUM' then 'WARN'
else 'PASS'
end

viability_score = nil
if experimental_scoring
  score = 50.0
  score += 15 if salvage_rate >= 0.5
  score -= 10 if salvage_rate < 0.2
  score += 10 if !avg_duration.nil? && avg_duration >= 3.0 && avg_duration <= 8.0
  score -= 10 if !avg_duration.nil? && avg_duration < 2.0
  score -= 15 if top_cause_share > 0.45
  score -= 10 if !target_cause.empty? && target_cause == top_cause
  score += 5 if !target_cause.empty? && target_cause != top_cause

  unless target_tags.empty?
    overlap = target_tags.count { |tag| tag_counts.key?(tag) }
    score += [overlap * 2, 8].min
  end

  score = 0 if score < 0
  score = 100 if score > 100
  viability_score = score.round(2)
end

if missing_survived_sections.positive?
  suggestions << "Run ./scripts/migrate-headstones.sh --dry-run and backfill '## What Survived' before strict mode"
else
  suggestions << "All archived headstones include salvage sections; maintain this in new entries"
end
suggestions << "Run ./scripts/lint-headstones.sh --mode ci before opening PR"

payload = {
  status: status,
  risk_profile: risk_profile,
  archived_headstones: total,
  top_cause: top_cause,
  top_cause_share: (top_cause_share * 100).round(2),
  average_duration_months: avg_duration&.round(2),
  salvage_rate: (salvage_rate * 100).round(2),
  warnings: warnings,
  must_fix: must_fix.uniq,
  suggestions: suggestions.uniq,
  viability_score: viability_score,
  scoring_mode: (experimental_scoring ? 'experimental' : 'baseline')
}

if format == 'json'
  puts JSON.pretty_generate(payload)
else
  puts "== Headstone Preflight =="
  puts "Status: #{payload[:status]} (#{payload[:risk_profile]})"
  puts "Archived headstones: #{payload[:archived_headstones]}"
  puts "Top cause: #{payload[:top_cause]} (#{payload[:top_cause_share]}%)"
  puts "Average duration (months): #{payload[:average_duration_months] || 'n/a'}"
  puts "Salvage rate: #{payload[:salvage_rate]}%"
  puts "Scoring mode: #{payload[:scoring_mode]}"
  puts "Viability score: #{payload[:viability_score]}" unless payload[:viability_score].nil?
  unless payload[:warnings].empty?
    puts "\nWarnings:"
    payload[:warnings].each { |w| puts "- #{w}" }
  end
  unless payload[:must_fix].empty?
    puts "\nMust-fix:"
    payload[:must_fix].each { |m| puts "- #{m}" }
  end
  puts "\nSuggestions:"
  payload[:suggestions].each { |s| puts "- #{s}" }
end

exit(status == 'FAIL' ? 1 : 0)
RUBY
