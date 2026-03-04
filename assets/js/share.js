/**
 * Unfinished Cemetery — Share button + lightweight event hook.
 *
 * Events emitted:
 *  - share_clicked  { method }
 *  - share_success  { method }
 *  - share_cancelled { method }
 *  - share_failed   { method, error }
 *
 * Optional: set <meta name="uc-events-endpoint" content="https://..."> to POST JSON via sendBeacon/fetch.
 */
(function () {
  'use strict';

  const shareButtons = document.querySelectorAll('[data-uc-share="headstone"]');
  if (shareButtons.length === 0) return;

  function getEventsEndpoint() {
    const meta = document.querySelector('meta[name="uc-events-endpoint"]');
    const value = meta?.getAttribute('content')?.trim();
    return value ? value : null;
  }

  const eventsEndpoint = getEventsEndpoint();

  function emitEvent(event, props) {
    const detail = {
      event,
      props: props ?? {},
      ts: Date.now(),
      path: window.location.pathname,
      referrer: document.referrer || null,
    };

    try {
      window.dispatchEvent(new CustomEvent('uc:event', { detail }));
    } catch (_) {
      // ignore
    }

    if (!eventsEndpoint) return;

    const payload = JSON.stringify(detail);

    try {
      if (navigator.sendBeacon) {
        const blob = new Blob([payload], { type: 'application/json' });
        navigator.sendBeacon(eventsEndpoint, blob);
        return;
      }
    } catch (_) {
      // ignore
    }

    try {
      void fetch(eventsEndpoint, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: payload,
        keepalive: true,
        credentials: 'omit',
        mode: 'cors',
      });
    } catch (_) {
      // ignore
    }
  }

  async function copyToClipboard(text) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);
      return;
    }

    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', 'true');
    textarea.style.position = 'fixed';
    textarea.style.top = '-9999px';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();
    const ok = document.execCommand('copy');
    document.body.removeChild(textarea);
    if (!ok) throw new Error('copy_failed');
  }

  function setTempButtonLabel(button, label) {
    const original = button.getAttribute('data-uc-share-original-label') ?? button.textContent ?? '';
    button.setAttribute('data-uc-share-original-label', original);
    button.textContent = label;
    button.setAttribute('data-uc-share-state', 'success');
    window.setTimeout(() => {
      button.textContent = original;
      button.removeAttribute('data-uc-share-state');
    }, 2000);
  }

  shareButtons.forEach((button) => {
    button.addEventListener('click', async () => {
      const title = button.getAttribute('data-uc-share-title') ?? document.title;
      const text = button.getAttribute('data-uc-share-text') ?? '';
      const url = button.getAttribute('data-uc-share-url') ?? window.location.href;

      const method = typeof navigator.share === 'function' ? 'web_share' : 'copy_link';
      emitEvent('share_clicked', { method });

      try {
        if (typeof navigator.share === 'function') {
          await navigator.share({ title, text, url });
          emitEvent('share_success', { method });
          setTempButtonLabel(button, 'Shared');
          return;
        }

        await copyToClipboard(url);
        emitEvent('share_success', { method });
        setTempButtonLabel(button, 'Copied link');
      } catch (err) {
        const errorName = typeof err === 'object' && err && 'name' in err ? String(err.name) : 'unknown';

        if (errorName === 'AbortError') {
          emitEvent('share_cancelled', { method });
          return;
        }

        emitEvent('share_failed', { method, error: errorName });
        setTempButtonLabel(button, 'Share failed');
      }
    });
  });
})();

