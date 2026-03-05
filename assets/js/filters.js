/**
 * Unfinished Cemetery — Archive filtering.
 * Initial release controls: cause, duration, has_savaged_code.
 * Staged hooks already exposed in card data attrs: domains, is_revivable, is_permanently_dead.
 */
(function () {
  'use strict';

  const grid = document.getElementById('headstone-grid');
  if (!grid) return;

  const cards = Array.from(grid.querySelectorAll('.headstone-card'));
  if (cards.length === 0) return;

  const controls = {
    cause: document.querySelector('[data-filter-control="cause"]'),
    duration: document.querySelector('[data-filter-control="duration"]'),
    salvaged: document.querySelector('[data-filter-control="salvaged"]'),
  };

  const clearButtons = document.querySelectorAll('[data-filter-clear]');
  const summary = document.getElementById('filter-summary');
  const emptyState = document.getElementById('filter-empty-state');

  function readFilters() {
    return {
      cause: controls.cause?.value || '',
      duration: controls.duration?.value || '',
      salvaged: controls.salvaged?.value || '',
    };
  }

  function matches(card, filters) {
    if (filters.cause && card.dataset.cause !== filters.cause) return false;
    if (filters.duration && card.dataset.durationBucket !== filters.duration) return false;
    if (filters.salvaged && card.dataset.hasSalvagedCode !== filters.salvaged) return false;
    return true;
  }

  function updateSummary(visibleCount, filters) {
    if (!summary) return;

    const activeFilters = Object.entries(filters)
      .filter(([, value]) => value)
      .map(([key, value]) => `${key}: ${value}`);

    if (activeFilters.length === 0) {
      summary.textContent = `Showing all ${visibleCount} archived projects.`;
      return;
    }

    summary.textContent = `Showing ${visibleCount} archived projects (${activeFilters.join(', ')}).`;
  }

  function applyFilters() {
    const filters = readFilters();
    let visibleCount = 0;

    cards.forEach((card) => {
      const visible = matches(card, filters);
      card.hidden = !visible;
      if (visible) visibleCount += 1;
    });

    if (emptyState) {
      emptyState.hidden = visibleCount > 0;
    }

    updateSummary(visibleCount, filters);

    const params = new URLSearchParams(window.location.search);
    Object.entries(filters).forEach(([key, value]) => {
      if (value) {
        params.set(key, value);
      } else {
        params.delete(key);
      }
    });

    const next = `${window.location.pathname}${params.toString() ? `?${params.toString()}` : ''}${window.location.hash}`;
    window.history.replaceState({}, '', next);
  }

  function clearFilters() {
    if (controls.cause) controls.cause.value = '';
    if (controls.duration) controls.duration.value = '';
    if (controls.salvaged) controls.salvaged.value = '';
    applyFilters();
  }

  function hydrateFromQuery() {
    const params = new URLSearchParams(window.location.search);
    if (controls.cause && params.has('cause')) controls.cause.value = params.get('cause') || '';
    if (controls.duration && params.has('duration')) controls.duration.value = params.get('duration') || '';
    if (controls.salvaged && params.has('salvaged')) controls.salvaged.value = params.get('salvaged') || '';
  }

  Object.values(controls).forEach((control) => {
    control?.addEventListener('change', applyFilters);
  });

  clearButtons.forEach((button) => {
    button.addEventListener('click', clearFilters);
  });

  hydrateFromQuery();
  applyFilters();
})();
