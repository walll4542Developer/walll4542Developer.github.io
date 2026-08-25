(() => {
  const $ = (selector, root = document) => root.querySelector(selector);
  const escapeHtml = (value = '') => String(value).replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character]));
  const menu = $('.site-header');
  const menuToggle = $('[data-menu-toggle]');
  const overlay = $('#search-overlay');
  const input = $('#search-input');
  const results = $('#search-results');
  const hints = $('#search-hints');
  let index = [];

  const closeSearch = () => {
    if (!overlay) return;
    overlay.hidden = true;
    document.body.style.overflow = '';
  };
  const openSearch = () => {
    if (!overlay) return;
    overlay.hidden = false;
    document.body.style.overflow = 'hidden';
    requestAnimationFrame(() => input?.focus());
  };
  const renderResults = (query) => {
    if (!results) return;
    const normalized = query.trim().toLowerCase();
    const matches = normalized ? index.filter((entry) => `${entry.title} ${entry.categories} ${entry.tags} ${entry.content}`.toLowerCase().includes(normalized)).slice(0, 24) : [];
    if (hints) hints.hidden = normalized.length > 0;
    results.innerHTML = matches.map((entry) => `<a class="search-result" href="${escapeHtml(entry.url)}"><p class="result-meta">${escapeHtml(entry.categories || 'DEVLOG')} // ${escapeHtml(entry.tags || 'POST')}</p><h2>${escapeHtml(entry.title)}</h2><p class="result-copy">${escapeHtml(entry.content.slice(0, 180))}${entry.content.length > 180 ? '…' : ''}</p></a>`).join('') || (normalized ? '<p class="search-empty">NO MATCHING POSTS FOUND.</p>' : '');
  };

  fetch('/assets/js/data/search.json').then((response) => response.ok ? response.json() : []).then((data) => { index = Array.isArray(data) ? data : []; }).catch(() => {});
  menuToggle?.addEventListener('click', () => {
    const expanded = menu?.dataset.menuOpen === 'true';
    if (menu) menu.dataset.menuOpen = String(!expanded);
  });
  $('[data-search-open]')?.addEventListener('click', openSearch);
  $('[data-search-close]')?.addEventListener('click', closeSearch);
  overlay?.addEventListener('click', (event) => { if (event.target === overlay) closeSearch(); });
  input?.addEventListener('input', (event) => renderResults(event.target.value));
  document.addEventListener('keydown', (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') { event.preventDefault(); openSearch(); }
    if (event.key === 'Escape') closeSearch();
  });
  document.querySelectorAll('[data-copy-code]').forEach((button) => button.addEventListener('click', async () => {
    const code = button.closest('.code-block')?.querySelector('code')?.innerText;
    if (!code) return;
    try {
      await navigator.clipboard.writeText(code);
      const original = button.innerHTML;
      button.innerHTML = '<i class="fa-solid fa-check"></i><b>COPIED</b>';
      setTimeout(() => { button.innerHTML = original; }, 1500);
    } catch { /* Clipboard access may be unavailable on older static hosts. */ }
  }));
  if (window.GLightbox) window.GLightbox({ selector: '.popup' });
  const progress = $('#reading-progress');
  if (progress) {
    const updateProgress = () => {
      const height = document.documentElement.scrollHeight - window.innerHeight;
      progress.style.width = `${height > 0 ? Math.min(100, (window.scrollY / height) * 100) : 0}%`;
    };
    updateProgress();
    window.addEventListener('scroll', updateProgress, { passive: true });
  }
})();
