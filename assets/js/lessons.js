/**
 * Unfinished Cemetery — Lessons index recommendations.
 * Deterministic top-3 scoring with rationale output.
 */
(function () {
  'use strict';

  const app = document.getElementById('lessons-app');
  if (!app) return;

  const dataEl = document.getElementById('lessons-data');
  if (!dataEl) return;

  let headstones = [];
  try {
    headstones = JSON.parse(dataEl.textContent || '[]');
  } catch (error) {
    console.error('Failed to parse lessons data', error);
    return;
  }

  const scenarioSelect = document.getElementById('lessons-scenario');
  const runButton = document.getElementById('lessons-run');
  const resultList = document.getElementById('lessons-results');
  const emptyState = document.getElementById('lessons-empty');

  const scenarios = {
    avoid_scope_explosion: {
      label: 'Avoid scope explosion',
      cause: ['scope-explosion'],
      durationBias: 'short',
      tags: ['platform', 'over-ambitious'],
      prompt: 'Start narrow, enforce hard scope boundaries, and avoid platform ambitions too early.',
    },
    avoid_policy_risk: {
      label: 'Avoid policy risk',
      cause: ['policy-risk'],
      durationBias: 'short',
      tags: ['policy', 'safety', 'api'],
      prompt: 'Validate platform policy stability and user safety before committing build effort.',
    },
    recover_from_confusion: {
      label: 'Recover from confusion or doubt',
      cause: ['confusion', 'doubt'],
      durationBias: 'medium',
      tags: ['learning', 'health'],
      prompt: 'Prioritize clarity loops, external validation, and confidence recovery checkpoints.',
    },
    ship_pragmatic_tools: {
      label: 'Ship pragmatic tools first',
      cause: ['theory-trap', 'complexity', 'scope-explosion'],
      durationBias: 'short',
      tags: ['planning', 'governance', 'platform'],
      prompt: 'Prefer narrow tools over broad platforms; optimize for shipped utility.',
    },
  };

  function durationBucket(months) {
    if (typeof months !== 'number' || Number.isNaN(months)) return 'unknown';
    if (months <= 2) return 'short';
    if (months <= 6) return 'medium';
    return 'long';
  }

  function score(headstone, scenario) {
    let total = 0;
    const reasons = [];

    if (scenario.cause.includes(headstone.cause)) {
      total += 0.45;
      reasons.push(`cause match: ${headstone.cause}`);
    }

    const tagOverlap = (headstone.tags || []).filter((tag) => scenario.tags.includes(tag));
    if (tagOverlap.length > 0) {
      total += Math.min(0.25, tagOverlap.length * 0.1);
      reasons.push(`tag overlap: ${tagOverlap.join(', ')}`);
    }

    const bucket = durationBucket(headstone.duration_months);
    if (bucket === scenario.durationBias) {
      total += 0.2;
      reasons.push(`duration bias: ${bucket}`);
    }

    if (headstone.has_salvaged_code) {
      total += 0.1;
      reasons.push('salvage pattern available');
    }

    const confidence = typeof headstone.confidence === 'number' ? headstone.confidence : 0.6;
    total += Math.max(0, Math.min(0.1, confidence * 0.1));

    return {
      score: Number(total.toFixed(4)),
      reasons,
    };
  }

  function renderRecommendations() {
    const scenarioKey = scenarioSelect?.value;
    const scenario = scenarioKey ? scenarios[scenarioKey] : null;
    if (!scenario || !resultList || !emptyState) return;

    const ranked = headstones
      .map((entry) => {
        const result = score(entry, scenario);
        return { ...entry, ...result };
      })
      .sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return (a.slug || '').localeCompare(b.slug || '');
      });

    const recommendations = ranked.slice(0, 3).filter((entry) => entry.score > 0);
    resultList.innerHTML = '';

    if (recommendations.length === 0) {
      emptyState.hidden = false;
      return;
    }

    emptyState.hidden = true;

    const intro = document.createElement('p');
    intro.className = 'lessons-intro';
    intro.textContent = scenario.prompt;
    resultList.appendChild(intro);

    recommendations.forEach((entry, index) => {
      const item = document.createElement('article');
      item.className = 'lesson-card';
      item.innerHTML = `
        <h3>${index + 1}. <a href="${entry.url}">${entry.name}</a></h3>
        <p class="lesson-epitaph">${entry.epitaph || ''}</p>
        <p class="lesson-score">Score: ${entry.score.toFixed(2)}</p>
        <p class="lesson-rationale"><strong>Why:</strong> ${entry.reasons.join(' · ') || 'general relevance'}</p>
      `;
      resultList.appendChild(item);
    });
  }

  runButton?.addEventListener('click', renderRecommendations);
  scenarioSelect?.addEventListener('change', renderRecommendations);

  renderRecommendations();
})();
