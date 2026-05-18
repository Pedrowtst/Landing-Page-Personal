const FAB_VISIBLE_CLASS = 'is-fab-visible';
const MOBILE_QUERY = '(max-width: 768px)';

export function initFloatingFab() {
  const fab = document.querySelector('.fab-whatsapp');
  const heroCtas = document.querySelector('.hero .ctas');
  if (!fab || !heroCtas) return;

  const mobile = window.matchMedia?.(MOBILE_QUERY);
  let ticking = false;

  const sync = () => {
    ticking = false;

    if (mobile && !mobile.matches) {
      document.body.classList.remove(FAB_VISIBLE_CLASS);
      return;
    }

    const rect = heroCtas.getBoundingClientRect();
    const clearLine = window.innerHeight * 0.66;
    const shouldShow = rect.bottom < clearLine || window.scrollY > window.innerHeight * 0.92;
    document.body.classList.toggle(FAB_VISIBLE_CLASS, shouldShow);
  };

  const requestSync = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(sync);
  };

  sync();
  window.addEventListener('scroll', requestSync, { passive: true });
  window.addEventListener('resize', requestSync, { passive: true });
  window.visualViewport?.addEventListener('resize', requestSync, { passive: true });
  mobile?.addEventListener?.('change', requestSync);
}
