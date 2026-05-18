/* eslint-env browser */

export function initProtection() {
  const swallow = (event) => {
    event.preventDefault();
    event.stopPropagation();
    return false;
  };

  document.addEventListener('contextmenu', swallow);

  document.addEventListener('copy', (event) => {
    event.preventDefault();
    if (event.clipboardData) {
      event.clipboardData.setData('text/plain', '');
    }
  });
  document.addEventListener('cut', swallow);

  document.addEventListener('dragstart', (event) => {
    const target = event.target;
    if (target && (target.tagName === 'IMG' || target.tagName === 'SVG' || target.closest?.('img, svg'))) {
      event.preventDefault();
    }
  });

  document.addEventListener('selectstart', (event) => {
    const target = event.target;
    if (target instanceof HTMLElement && target.closest('input, textarea, [contenteditable="true"]')) {
      return;
    }
    event.preventDefault();
  });

  document.addEventListener('keydown', (event) => {
    const key = (event.key || '').toLowerCase();
    const ctrl = event.ctrlKey || event.metaKey;

    if (key === 'f12') {
      swallow(event);
      return;
    }

    if (ctrl && event.shiftKey && (key === 'i' || key === 'j' || key === 'c' || key === 'k')) {
      swallow(event);
      return;
    }

    if (ctrl && (key === 'u' || key === 's' || key === 'p')) {
      swallow(event);
      return;
    }

    if (ctrl && (key === 'a' || key === 'c' || key === 'x')) {
      const active = document.activeElement;
      if (active instanceof HTMLElement && active.closest('input, textarea, [contenteditable="true"]')) {
        return;
      }
      swallow(event);
    }
  }, { capture: true });

  document.querySelectorAll('img').forEach((img) => {
    img.setAttribute('draggable', 'false');
  });
  const imgObserver = new MutationObserver((records) => {
    for (const record of records) {
      for (const node of record.addedNodes) {
        if (node instanceof HTMLImageElement) {
          node.setAttribute('draggable', 'false');
        } else if (node instanceof HTMLElement) {
          node.querySelectorAll?.('img').forEach((img) => img.setAttribute('draggable', 'false'));
        }
      }
    }
  });
  imgObserver.observe(document.documentElement, { childList: true, subtree: true });

  window.addEventListener('beforeprint', (event) => {
    event.preventDefault?.();
  });
}
