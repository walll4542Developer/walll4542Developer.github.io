(() => {
  const byId = (id) => document.getElementById(id);
  const searchTrigger = byId('search-trigger');
  const searchCancel = byId('search-cancel');
  const search = byId('search');
  const input = byId('search-input');
  const resultsWrapper = byId('search-result-wrapper');
  const results = byId('search-results');
  const hints = byId('search-hints');
  const sidebarTrigger = byId('sidebar-trigger');
  const sidebar = byId('sidebar');
  const backToTop = byId('back-to-top');
  let index = [];

  const closeSearch = () => {
    document.body.classList.remove('search-active');
    resultsWrapper?.classList.add('d-none');
    search?.classList.remove('d-flex');
    input && (input.value = '');
  };
  const openSearch = () => {
    document.body.classList.add('search-active');
    resultsWrapper?.classList.remove('d-none');
    search?.classList.add('d-flex');
    input?.focus();
  };
  const renderResults = (query) => {
    if (!results) return;
    const normalized = query.trim().toLowerCase();
    const matches = normalized ? index.filter((entry) => `${entry.title} ${entry.categories} ${entry.tags} ${entry.content}`.toLowerCase().includes(normalized)).slice(0, 30) : [];
    hints?.classList.toggle('d-none', normalized.length > 0);
    results.innerHTML = matches.map((entry) => `<article class="px-1 px-sm-2 px-lg-4 px-xl-0 w-100"><header><h2><a href="${entry.url}">${entry.title}</a></h2><div class="post-meta text-muted">${entry.categories || ''} ${entry.tags || ''}</div></header><p>${entry.content.slice(0, 180)}${entry.content.length > 180 ? '…' : ''}</p></article>`).join('') || (normalized ? '<p class="text-muted">No results found.</p>' : '');
  };

  fetch('/assets/js/data/search.json').then((response) => response.ok ? response.json() : []).then((data) => { index = Array.isArray(data) ? data : []; }).catch(() => {});
  searchTrigger?.addEventListener('click', openSearch);
  searchCancel?.addEventListener('click', closeSearch);
  input?.addEventListener('input', (event) => renderResults(event.target.value));
  sidebarTrigger?.addEventListener('click', () => sidebar?.classList.toggle('sidebar-expanded'));
  backToTop?.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  document.querySelectorAll('[data-copy-code]').forEach((button) => button.addEventListener('click', () => {
    const code = button.closest('.highlighter-rouge')?.querySelector('code')?.innerText;
    if (code) navigator.clipboard?.writeText(code);
  }));
  if (window.GLightbox) window.GLightbox({ selector: '.popup' });
})();
