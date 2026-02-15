#!/usr/bin/env bash
set -euo pipefail

OWNER="${GITHUB_OWNER:-jscraik}"
OUTPUT_FILE="${OUTPUT_FILE:-_data/archived_repos.json}"
PER_PAGE=100
PAGE=1
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

auth_args=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_args=("-H" "Authorization: Bearer ${GITHUB_TOKEN}")
fi

while true; do
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    url="https://api.github.com/user/repos?per_page=${PER_PAGE}&page=${PAGE}&visibility=all&affiliation=owner&sort=updated"
  else
    url="https://api.github.com/users/${OWNER}/repos?per_page=${PER_PAGE}&page=${PAGE}&type=owner&sort=updated"
  fi
  curl -sS "${auth_args[@]}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${url}" \
    > "${TMP_DIR}/page-${PAGE}.raw"

  response_count=$(jq 'length' "${TMP_DIR}/page-${PAGE}.raw")
  jq '[.[] | select(.archived == true) | {name, full_name, html_url, description, archived, created_at, pushed_at, updated_at}]' \
    "${TMP_DIR}/page-${PAGE}.raw" \
    > "${TMP_DIR}/page-${PAGE}.filtered.json"

  if [[ "${response_count}" -lt "${PER_PAGE}" ]]; then
    break
  fi

  PAGE=$((PAGE + 1))
  if [[ "${PAGE}" -gt 20 ]]; then
    break
  fi
done

if ls "${TMP_DIR}"/page-*.filtered.json >/dev/null 2>&1; then
  jq -s 'add | sort_by(.name)' "${TMP_DIR}"/page-*.filtered.json > "${OUTPUT_FILE}"
else
  echo '[]' > "${OUTPUT_FILE}"
fi

echo "Wrote archived repos to ${OUTPUT_FILE}"
