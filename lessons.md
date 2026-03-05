---
layout: default
title: Lessons
permalink: /lessons/
---

{%- assign archived_repos = site.data.archived_repos -%}
{%- if archived_repos == nil -%}
  {%- assign archived_repos = "" | split: "," -%}
{%- endif -%}
{%- assign archived_repo_tokens = "|" -%}
{%- for archived_repo in archived_repos -%}
  {%- assign archived_repo_tokens = archived_repo_tokens | append: archived_repo.name | downcase | append: "|" -%}
{%- endfor -%}

<section id="lessons-app" class="lessons-page">
  <header class="headstone-header">
    <h1>Lessons Index</h1>
    <p class="meta">Pick a scenario to get the most relevant cemetery lessons.</p>
  </header>

  <div class="headstone-content">
    <label for="lessons-scenario">Scenario</label>
    <select id="lessons-scenario">
      <option value="avoid_scope_explosion">Avoid scope explosion</option>
      <option value="avoid_policy_risk">Avoid policy risk</option>
      <option value="recover_from_confusion">Recover from confusion or doubt</option>
      <option value="ship_pragmatic_tools">Ship pragmatic tools first</option>
    </select>
    <button id="lessons-run" class="page-link" type="button">Refresh recommendations</button>
  </div>

  <div id="lessons-results" class="lessons-results" aria-live="polite"></div>
  <p id="lessons-empty" class="lessons-empty" hidden>No recommendations available yet for this scenario.</p>
</section>

<script id="lessons-data" type="application/json">
[
  {%- assign sorted_headstones = site.headstones | sort: 'name' -%}
  {%- assign first_entry = true -%}
  {%- for headstone in sorted_headstones -%}
    {%- assign repo_name = "" -%}
    {%- if headstone.repo -%}
      {%- assign repo_name = headstone.repo | split: '/' | last | downcase -%}
    {%- endif -%}
    {%- assign is_archived = false -%}
    {%- if headstone.archived == true -%}
      {%- assign is_archived = true -%}
    {%- elsif repo_name != "" and archived_repo_tokens contains repo_name -%}
      {%- assign is_archived = true -%}
    {%- endif -%}
    {%- unless is_archived -%}{%- continue -%}{%- endunless -%}

    {%- assign birth_parts = headstone.birth | split: '-' -%}
    {%- assign death_parts = headstone.death | split: '-' -%}
    {%- assign duration_months = nil -%}
    {%- if birth_parts.size > 1 and death_parts.size > 1 -%}
      {%- assign duration_months = death_parts[0] | minus: birth_parts[0] | times: 12 | plus: death_parts[1] | minus: birth_parts[1] -%}
    {%- endif -%}
    {%- assign has_salvaged_code = headstone.has_salvaged_code -%}
    {%- if has_salvaged_code == nil -%}
      {%- assign has_salvaged_code = false -%}
      {%- if headstone.content contains "## What Survived" or headstone.content contains "## The Code That Survived" -%}
        {%- assign has_salvaged_code = true -%}
      {%- endif -%}
    {%- endif -%}
    {%- assign slug_value = headstone.slug | default: headstone.name | slugify -%}
    {%- assign confidence_value = headstone.confidence | default: 0.6 -%}

    {%- unless first_entry -%},{%- endunless -%}
    {%- assign first_entry = false -%}
    {
      "id": {{ slug_value | jsonify }},
      "name": {{ headstone.name | jsonify }},
      "slug": {{ slug_value | jsonify }},
      "url": {{ headstone.url | relative_url | jsonify }},
      "cause": {{ headstone.cause | jsonify }},
      "tags": {{ headstone.tags | default: empty | jsonify }},
      "duration_months": {{ duration_months | default: "null" }},
      "has_salvaged_code": {{ has_salvaged_code | jsonify }},
      "confidence": {{ confidence_value | jsonify }},
      "epitaph": {{ headstone.epitaph | default: "" | strip_newlines | jsonify }}
    }
  {%- endfor -%}
]
</script>
