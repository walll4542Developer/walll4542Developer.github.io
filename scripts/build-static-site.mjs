import { mkdir, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const contentRoot = path.join(root, 'content');
const postsRoot = path.join(contentRoot, 'posts');
const pagesRoot = path.join(contentRoot, 'pages');
const outputRoot = root;

const htmlEscape = (value = '') => String(value)
  .replaceAll('&', '&amp;')
  .replaceAll('<', '&lt;')
  .replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;')
  .replaceAll("'", '&#39;');

const attrEscape = htmlEscape;
const stripHtml = (value = '') => String(value).replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
const xmlEscape = htmlEscape;
const slugify = (value = '') => String(value)
  .normalize('NFKD')
  .replace(/[^\p{L}\p{N}]+/gu, '-')
  .replace(/^-+|-+$/g, '')
  .toLowerCase() || 'post';

const isoDate = (value) => {
  const date = new Date(value);
  if (Number.isNaN(date.valueOf())) {
    throw new Error(`Invalid date in front matter: ${value}`);
  }
  return date;
};

const dateLabel = (date) => new Intl.DateTimeFormat('en', {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  timeZone: 'Asia/Seoul'
}).format(date);

const dateMachine = (date) => Math.floor(date.valueOf() / 1000);

function parseScalar(value = '') {
  const trimmed = value.trim();
  if (!trimmed) return '';
  if (trimmed === 'true') return true;
  if (trimmed === 'false') return false;
  if ((trimmed.startsWith('"') && trimmed.endsWith('"')) || (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
    return trimmed.slice(1, -1);
  }
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    return trimmed.slice(1, -1).split(',').map((item) => parseScalar(item)).filter(Boolean);
  }
  return trimmed;
}

function parseFrontMatter(source, filePath) {
  // Content may be edited on Windows (CRLF) or in GitHub Actions (LF).
  // Normalize before locating the closing fence so the last front-matter
  // field is parsed identically on both platforms.
  const normalized = source.replace(/\r\n?/g, '\n');
  if (!normalized.startsWith('---')) return { data: {}, body: normalized };
  const close = normalized.indexOf('\n---', 3);
  if (close === -1) throw new Error(`Unclosed front matter: ${filePath}`);
  const frontMatter = normalized.slice(3, close).replace(/^\n/, '');
  const data = {};
  for (const line of frontMatter.split('\n')) {
    if (/^\s/.test(line) || line.trimStart().startsWith('#')) continue;
    const match = line.match(/^([A-Za-z][\w-]*):(?:\s*(.*))?$/);
    if (match) data[match[1]] = parseScalar(match[2]);
  }
  return { data, body: normalized.slice(close + 4).replace(/^\n/, '') };
}

function toArray(value) {
  if (Array.isArray(value)) return value.map(String).filter(Boolean);
  if (value === undefined || value === null || value === '') return [];
  return [String(value)];
}

function postSlug(filename) {
  return path.basename(filename, path.extname(filename)).replace(/^\d{4}-\d{2}-\d{2}-/, '');
}

function applyChirpyMarkdownConventions(markdown) {
  return markdown
    .replace(/^\{:\s*([^}]+)\}\s*$/gm, '')
    .replace(/\{:\s*[^}]+\}/g, '')
    .replace(/\n<!-- markdownlint-[\s\S]*?-->/g, '\n');
}

function renderMarkdown(markdown) {
  const headingIds = new Map();
  const renderer = new marked.Renderer();
  renderer.heading = function heading({ tokens, depth }) {
    const text = this.parser.parseInline(tokens);
    const base = slugify(stripHtml(text));
    const count = headingIds.get(base) || 0;
    headingIds.set(base, count + 1);
    const id = count ? `${base}-${count}` : base;
    const anchor = depth > 1 ? `<a href="#${id}" class="anchor text-muted" aria-label="Link to ${attrEscape(stripHtml(text))}"><i class="fas fa-hashtag"></i></a>` : '';
    return `<h${depth} id="${id}"><span class="me-2">${text}</span>${anchor}</h${depth}>\n`;
  };
  renderer.code = ({ text, lang }) => {
    const language = lang ? ` language-${attrEscape(lang)}` : '';
    const label = lang ? htmlEscape(lang) : 'text';
    return `<div class="language-${attrEscape(lang || 'plaintext')} highlighter-rouge"><div class="code-header"><span data-label-text="${label}"><i class="fas fa-code fa-fw small"></i></span><button type="button" aria-label="Copy code" data-copy-code><i class="far fa-clipboard"></i></button></div><div class="highlight"><pre><code class="${language.trim()}">${htmlEscape(text)}</code></pre></div></div>\n`;
  };
  renderer.image = ({ href, title, text }) => {
    const label = attrEscape(text || '');
    const titleAttribute = title ? ` title="${attrEscape(title)}"` : '';
    return `<a href="${attrEscape(href)}" class="popup img-link shimmer"><img src="${attrEscape(href)}" alt="${label}" loading="lazy"${titleAttribute}></a>`;
  };
  return marked.parse(applyChirpyMarkdownConventions(markdown), {
    gfm: true,
    breaks: false,
    renderer
  });
}

async function readMarkdownFiles(folder) {
  const entries = await readdir(folder, { withFileTypes: true });
  const files = entries.filter((entry) => entry.isFile() && /\.md$/i.test(entry.name)).map((entry) => entry.name).sort();
  return Promise.all(files.map(async (name) => {
    const filePath = path.join(folder, name);
    const raw = await readFile(filePath, 'utf8');
    const { data, body } = parseFrontMatter(raw, filePath);
    return { filePath, filename: name, data, markdown: body };
  }));
}

async function ensureDir(directory) {
  await mkdir(directory, { recursive: true });
}

async function writeOutput(relativePath, content) {
  const destination = path.join(outputRoot, relativePath);
  await ensureDir(path.dirname(destination));
  await writeFile(destination, content, 'utf8');
}

function pageScripts(kind, math = false) {
  const common = [
    '<script src="/assets/js/dist/theme.min.js"></script>',
    '<script defer src="https://cdn.jsdelivr.net/npm/loading-attribute-polyfill@2.1.1/dist/loading-attribute-polyfill.umd.min.js"></script>',
    '<script defer src="/assets/js/static-site.js"></script>',
    '<script defer src="/app.js"></script>'
  ];
  if (kind === 'post' || kind === 'page') {
    common.splice(2, 0, '<script defer src="https://cdn.jsdelivr.net/npm/glightbox@3.3.0/dist/js/glightbox.min.js"></script>');
  }
  if (math) {
    common.push('<script src="/assets/js/data/mathjax.js"></script>');
    common.push('<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-chtml.js"></script>');
  }
  return common.join('\n  ');
}

function nav(site, active) {
  const items = [
    ['home', '/', 'fas fa-home', 'Home'],
    ['categories', '/categories/', 'fas fa-stream', 'Categories'],
    ['tags', '/tags/', 'fas fa-tags', 'Tags'],
    ['archives', '/archives/', 'fas fa-archive', 'Archives'],
    ['about', '/about/', 'fas fa-info-circle', 'About']
  ];
  const socialLinks = [
    site.social?.github && `<a href="${attrEscape(site.social.github)}" aria-label="github" target="_blank" rel="noopener noreferrer"><i class="fab fa-github"></i></a>`,
    site.social?.x && `<a href="${attrEscape(site.social.x)}" aria-label="x" target="_blank" rel="noopener noreferrer"><i class="fa-brands fa-x-twitter"></i></a>`,
    site.author?.email && `<a href="mailto:${attrEscape(site.author.email)}" aria-label="email"><i class="fas fa-envelope"></i></a>`,
    '<a href="/feed.xml" aria-label="rss"><i class="fas fa-rss"></i></a>'
  ].filter(Boolean).join('\n      ');
  return `<aside aria-label="Sidebar" id="sidebar" class="d-flex flex-column align-items-end">
  <header class="profile-wrapper">
    <a href="/" id="avatar" class="rounded-circle">${site.avatar ? `<img src="${attrEscape(site.avatar)}" width="112" height="112" alt="avatar" onerror="this.style.display='none'">` : ''}</a>
    <a class="site-title d-block" href="/">${htmlEscape(site.title)}</a>
    <p class="site-subtitle fst-italic mb-0">${htmlEscape(site.tagline)}</p>
  </header>
  <nav class="flex-column flex-grow-1 w-100 ps-0">
    <ul class="nav">${items.map(([id, href, icon, label]) => `
      <li class="nav-item${id === active ? ' active' : ''}"><a href="${href}" class="nav-link"><i class="fa-fw ${icon}"></i><span>${label.toUpperCase()}</span></a></li>`).join('')}
    </ul>
  </nav>
  <div class="sidebar-bottom d-flex flex-wrap align-items-center w-100">${socialLinks}</div>
</aside>`;
}

function topbar(title, breadcrumb = 'Home') {
  return `<header id="topbar-wrapper" class="flex-shrink-0" aria-label="Top Bar">
  <div id="topbar" class="d-flex align-items-center justify-content-between px-lg-3 h-100">
    <nav id="breadcrumb" aria-label="Breadcrumb"><span><a href="/">Home</a></span><span>${htmlEscape(breadcrumb)}</span></nav>
    <button type="button" id="sidebar-trigger" class="btn btn-link" aria-label="Sidebar"><i class="fas fa-bars fa-fw"></i></button>
    <div id="topbar-title">${htmlEscape(title)}</div>
    <button type="button" id="search-trigger" class="btn btn-link" aria-label="Search"><i class="fas fa-search fa-fw"></i></button>
    <search id="search" class="align-items-center ms-3 ms-lg-0"><i class="fas fa-search fa-fw"></i><input class="form-control" id="search-input" type="search" aria-label="search" autocomplete="off" placeholder="Search..."></search>
    <button type="button" class="btn btn-link text-decoration-none" id="search-cancel">Cancel</button>
  </div>
</header>`;
}

function trendingTags(posts) {
  const counts = new Map();
  posts.forEach((post) => post.tags.forEach((tag) => counts.set(tag, (counts.get(tag) || 0) + 1)));
  return [...counts.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])).slice(0, 10);
}

function panel(posts, toc = '') {
  const recent = posts.slice(0, 5).map((post) => `<li class="text-truncate lh-lg"><a href="${post.url}">${htmlEscape(post.title)}</a></li>`).join('');
  const tags = trendingTags(posts).map(([tag]) => `<a class="post-tag btn btn-outline-primary" href="/tags/${slugify(tag)}/">${htmlEscape(tag)}</a>`).join('');
  return `<aside aria-label="Panel" id="panel-wrapper" class="col-xl-3 ps-2 text-muted">
  <div class="access">
    <section id="access-lastmod"><h2 class="panel-heading">Recently Updated</h2><ul class="content list-unstyled ps-0 pb-1 ms-1 mt-2">${recent}</ul></section>
    <section><h2 class="panel-heading">Trending Tags</h2><div class="d-flex flex-wrap mt-3 mb-1 me-3">${tags}</div></section>
  </div>${toc}
</aside>`;
}

function footer(site) {
  return `<footer aria-label="Site Info" class="d-flex flex-column justify-content-center text-muted flex-lg-row justify-content-lg-between align-items-lg-center pb-lg-3">
  <p>© <time>${new Date().getFullYear()}</time> <a href="${attrEscape(site.author.url)}">${htmlEscape(site.author.name)}</a>. <span>Some rights reserved.</span></p>
  <p>Built as a static HTML site with a <a href="https://github.com/cotes2020/jekyll-theme-chirpy" target="_blank" rel="noopener">Chirpy-compatible</a> interface.</p>
</footer>`;
}

function searchOverlay(posts) {
  const tags = trendingTags(posts).map(([tag]) => `<a class="post-tag btn btn-outline-primary" href="/tags/${slugify(tag)}/">${htmlEscape(tag)}</a>`).join('');
  return `<div id="search-result-wrapper" class="d-flex justify-content-center d-none"><div class="col-11 content"><div id="search-hints"><section><h2 class="panel-heading">Trending Tags</h2><div class="d-flex flex-wrap mt-3 mb-1 me-3">${tags}</div></section></div><div id="search-results" class="d-flex flex-wrap flex-md-row flex-column text-muted mt-3"></div></div></div>`;
}

function documentPage({ site, title, description, active, kind, main, posts, breadcrumb = title, toc = '', canonicalPath = active === 'home' ? '/' : `/${active}/`, math = false }) {
  const canonical = `${site.siteUrl}${canonicalPath}`;
  const styles = [
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.6/dist/css/bootstrap.min.css">',
    '<link rel="stylesheet" href="/assets/css/site.css">',
    '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400&family=Source+Sans+Pro:wght@400;600;700;900&display=swap">',
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.7.1/css/all.min.css">',
    (kind === 'post' || kind === 'page') && '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tocbot@4.32.2/dist/tocbot.min.css">',
    (kind === 'post' || kind === 'page' || kind === 'home') && '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/loading-attribute-polyfill@2.1.1/dist/loading-attribute-polyfill.min.css">',
    (kind === 'post' || kind === 'page') && '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/glightbox@3.3.0/dist/css/glightbox.min.css">'
  ].filter(Boolean).join('\n  ');
  const metadata = JSON.stringify({
    '@context': 'https://schema.org',
    '@type': kind === 'post' ? 'BlogPosting' : 'WebSite',
    headline: title,
    description,
    url: canonical,
    author: { '@type': 'Person', name: site.author.name }
  });
  return `<!doctype html>
<html lang="${attrEscape(site.language || 'en')}" data-mode="${attrEscape(site.themeMode || 'dark')}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no, viewport-fit=cover">
  <meta name="theme-color" content="#1b1b1e">
  <meta name="description" content="${attrEscape(description)}">
  <link rel="canonical" href="${attrEscape(canonical)}">
  <link rel="apple-touch-icon" sizes="180x180" href="/assets/img/favicons/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/assets/img/favicons/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/assets/img/favicons/favicon-16x16.png">
  <link rel="manifest" href="/assets/img/favicons/site.webmanifest">
  <meta property="og:title" content="${attrEscape(title)}">
  <meta property="og:description" content="${attrEscape(description)}">
  <meta property="og:url" content="${attrEscape(canonical)}">
  <meta property="og:type" content="${kind === 'post' ? 'article' : 'website'}">
  <script type="application/ld+json">${metadata.replaceAll('<', '\\u003c')}</script>
  <title>${htmlEscape(active === 'home' ? site.title : `${title} | ${site.title}`)}</title>
  ${styles}
  ${pageScripts(kind, math)}
</head>
<body>
  ${nav(site, active)}
  <div id="main-wrapper" class="d-flex justify-content-center">
    <div class="container d-flex flex-column px-xxl-5">
      ${topbar(active === 'home' ? site.title : title, active === 'home' ? 'Home' : breadcrumb)}
      <div class="row flex-grow-1"><main aria-label="Main Content" class="col-12 col-lg-11 col-xl-9 px-md-4">${main}</main>${panel(posts, toc)}</div>
      <div class="row"><div id="tail-wrapper" class="col-12 col-lg-11 col-xl-9 px-md-4">${footer(site)}</div></div>
      ${searchOverlay(posts)}
    </div>
    <aside aria-label="Scroll to Top"><button id="back-to-top" type="button" class="btn btn-lg btn-box-shadow"><i class="fas fa-angle-up"></i></button></aside>
  </div>
  <div id="mask" class="d-none position-fixed w-100 h-100 z-1"></div>
</body>
</html>`;
}

function postPreview(post) {
  return `<article class="card-wrapper card"><a href="${post.url}" class="post-preview row g-0 flex-md-row-reverse"><div class="col-md-12"><div class="card-body d-flex flex-column"><h1 class="card-title my-2 mt-md-0">${htmlEscape(post.title)}</h1><div class="card-text content mt-0 mb-3"><p>${htmlEscape(post.excerpt)}</p></div><div class="post-meta flex-grow-1 d-flex align-items-end"><div class="me-auto"><i class="far fa-calendar fa-fw me-1"></i><time data-ts="${dateMachine(post.date)}" data-df="ll">${dateLabel(post.date)}</time>${post.categories.length ? ` <i class="far fa-folder-open fa-fw me-1"></i><span class="categories">${post.categories.map(htmlEscape).join(', ')}</span>` : ''}</div></div></div></div></a></article>`;
}

function paginator(posts, page, perPage) {
  const pageCount = Math.max(1, Math.ceil(posts.length / perPage));
  if (pageCount === 1) return '';
  const pages = Array.from({ length: pageCount }, (_, index) => index + 1).map((number) => `<li class="page-item${number === page ? ' active' : ''}"><a class="page-link" href="${number === 1 ? '/' : `/page/${number}/`}">${number}</a></li>`).join('');
  return `<nav aria-label="Page Navigation"><ul class="pagination align-items-center justify-content-center mb-0">${pages}</ul></nav>`;
}

function tocFor(post) {
  const headings = [...post.html.matchAll(/<h([2-3]) id="([^"]+)"><span class="me-2">([\s\S]*?)<\/span>/g)];
  if (!headings.length) return '';
  const list = headings.map(([, level, id, text]) => `<li class="toc-entry toc-h${level}"><a href="#${id}">${stripHtml(text)}</a></li>`).join('');
  return `<section id="toc-wrapper" class="ps-0"><h2 class="panel-heading">Contents</h2><nav id="toc"><ul>${list}</ul></nav></section>`;
}

function postNavigation(posts, index) {
  const older = posts[index + 1];
  const newer = posts[index - 1];
  const button = (post, label) => post ? `<a href="${post.url}" class="btn btn-outline-primary" aria-label="${label}"><p>${htmlEscape(post.title)}</p></a>` : `<div class="btn btn-outline-primary disabled" aria-label="${label}"><p>-</p></div>`;
  return `<nav class="post-navigation d-flex justify-content-between" aria-label="Post Navigation">${button(older, 'Older')}${button(newer, 'Newer')}</nav>`;
}

function postPage(post, posts, index, site) {
  const categories = post.categories.map((category) => `<a href="/categories/${slugify(category)}/">${htmlEscape(category)}</a>`).join(', ');
  const tags = post.tags.map((tag) => `<a href="/tags/${slugify(tag)}/" class="post-tag no-text-decoration">${htmlEscape(tag)}</a>`).join('');
  const readMinutes = Math.max(1, Math.ceil(stripHtml(post.html).split(/\s+/).filter(Boolean).length / 200));
  const main = `<article class="px-1" data-toc="true"><header><h1 data-toc-skip>${htmlEscape(post.title)}</h1>${post.description ? `<p class="post-desc fw-light mb-4">${htmlEscape(post.description)}</p>` : ''}<div class="post-meta text-muted"><span>Posted <time data-ts="${dateMachine(post.date)}" data-df="ll" data-bs-toggle="tooltip" data-bs-placement="bottom">${dateLabel(post.date)}</time></span><div class="d-flex justify-content-between"><span>By <em><a href="${attrEscape(site.author.url)}">${htmlEscape(site.author.name)}</a></em></span><div><span class="readtime"><i class="far fa-clock fa-fw"></i>${readMinutes} min read</span></div></div></div></header><div class="content">${post.html}</div><div class="post-tail-wrapper text-muted">${categories ? `<div class="post-meta mb-3"><i class="far fa-folder-open fa-fw me-1"></i>${categories}</div>` : ''}${tags ? `<div class="post-tags"><i class="fa fa-tags fa-fw me-1"></i>${tags}</div>` : ''}<div class="post-tail-bottom d-flex justify-content-between align-items-center mt-5 pb-2"><div class="license-wrapper">This post is licensed under <a href="${attrEscape(site.footer.licenseUrl)}">${htmlEscape(site.footer.licenseName)}</a> by the author.</div></div></div></article>${postNavigation(posts, index)}`;
  return documentPage({ site, title: post.title, description: post.excerpt, active: 'posts', kind: 'post', main, posts, breadcrumb: post.title, toc: tocFor(post), canonicalPath: post.url, math: post.math });
}

function listingPage(site, posts, title, active, content) {
  return documentPage({ site, title, description: `${title} | ${site.title}`, active, kind: 'listing', main: `<section class="px-1"><h1>${htmlEscape(title)}</h1>${content}</section>`, posts, breadcrumb: title });
}

function groupLinks(groups, rootPath) {
  return [...groups.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([name, items]) => `<li><a href="/${rootPath}/${slugify(name)}/">${htmlEscape(name)}</a><span class="text-muted">${items.length}</span></li>`).join('');
}

async function removeGeneratedRoutes() {
  const targets = ['posts', 'page', 'about', 'archives', 'categories', 'tags'];
  await Promise.all(targets.map((target) => rm(path.join(outputRoot, target), { recursive: true, force: true })));
}

async function createRuntimeFiles(site, buildId) {
  const app = `if ('serviceWorker' in navigator) { window.addEventListener('load', () => navigator.serviceWorker.register('/sw.js').catch(() => {})); }\n`;
  const worker = `const CACHE = 'walll-static-${buildId}';\nself.addEventListener('install', event => self.skipWaiting());\nself.addEventListener('activate', event => event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE).map(key => caches.delete(key)))).then(() => self.clients.claim())));\nself.addEventListener('fetch', event => { if (event.request.method !== 'GET' || new URL(event.request.url).origin !== self.location.origin) return; event.respondWith(fetch(event.request).then(response => { const copy = response.clone(); caches.open(CACHE).then(cache => cache.put(event.request, copy)); return response; }).catch(() => caches.match(event.request))); });\n`;
  const swconf = `const swconf = { cacheName: '${buildId}', resources: ['/'], interceptor: { paths: [], urlPrefixes: [] }, purge: false };\n`;
  const mathjax = `window.MathJax = { tex: { inlineMath: [['$', '$'], ['\\\\(', '\\\\)']], displayMath: [['$$', '$$'], ['\\\\[', '\\\\]']], tags: 'ams' }, options: { skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code'] } };\n`;
  const webManifest = JSON.stringify({
    name: site.title,
    short_name: site.title,
    description: site.description,
    start_url: '/',
    display: 'standalone',
    background_color: '#1b1b1e',
    theme_color: '#1b1b1e',
    icons: [
      { src: '/assets/img/favicons/android-chrome-192x192.png', sizes: '192x192', type: 'image/png' },
      { src: '/assets/img/favicons/android-chrome-512x512.png', sizes: '512x512', type: 'image/png' }
    ]
  }, null, 2) + '\n';
  const browserConfig = `<?xml version="1.0" encoding="utf-8"?><browserconfig><msapplication><tile><square150x150logo src="/assets/img/favicons/mstile-150x150.png"/><TileColor>#1b1b1e</TileColor></tile></msapplication></browserconfig>\n`;
  await Promise.all([
    writeOutput('app.js', app),
    writeOutput('sw.js', worker),
    writeOutput('assets/js/data/swconf.js', swconf),
    writeOutput('assets/js/data/mathjax.js', mathjax),
    writeOutput('assets/img/favicons/site.webmanifest', webManifest),
    writeOutput('assets/img/favicons/browserconfig.xml', browserConfig),
    writeOutput('.nojekyll', '')
  ]);
}

async function build() {
  const site = JSON.parse(await readFile(path.join(contentRoot, 'site.json'), 'utf8'));
  const sourcePosts = await readMarkdownFiles(postsRoot);
  const sourcePages = await readMarkdownFiles(pagesRoot);
  const posts = sourcePosts.map((source) => {
    const date = isoDate(source.data.date);
    const categories = toArray(source.data.categories);
    const tags = toArray(source.data.tags ?? source.data.tag);
    return {
      ...source,
      title: source.data.title || postSlug(source.filename),
      excerpt: source.data.excerpt || source.data.description || '',
      description: source.data.description || '',
      date,
      categories,
      tags,
      math: source.data.math === true,
      slug: postSlug(source.filename),
      url: `/posts/${postSlug(source.filename)}/`,
      html: renderMarkdown(source.markdown)
    };
  }).sort((a, b) => b.date - a.date || a.slug.localeCompare(b.slug));
  const about = sourcePages.find((page) => page.filename.toLowerCase() === 'about.md');
  const categories = new Map();
  const tags = new Map();
  posts.forEach((post) => {
    post.categories.forEach((category) => categories.set(category, [...(categories.get(category) || []), post]));
    post.tags.forEach((tag) => tags.set(tag, [...(tags.get(tag) || []), post]));
  });

  await removeGeneratedRoutes();
  const perPage = Number(site.postsPerPage) || 10;
  const totalPages = Math.max(1, Math.ceil(posts.length / perPage));
  for (let page = 1; page <= totalPages; page += 1) {
    const pagePosts = posts.slice((page - 1) * perPage, page * perPage);
    const main = `<div id="post-list" class="flex-grow-1 px-xl-1">${pagePosts.map(postPreview).join('')}</div>${paginator(posts, page, perPage)}`;
    const html = documentPage({ site, title: site.title, description: site.description, active: 'home', kind: 'home', main, posts, breadcrumb: 'Home' });
    await writeOutput(page === 1 ? 'index.html' : `page/${page}/index.html`, html);
  }

  await Promise.all(posts.map((post, index) => writeOutput(`posts/${post.slug}/index.html`, postPage(post, posts, index, site))));
  const allPostsList = `<div id="post-list" class="flex-grow-1 px-xl-1">${posts.map(postPreview).join('')}</div>`;
  await writeOutput('posts/index.html', listingPage(site, posts, 'Posts', 'posts', allPostsList));

  const archives = new Map();
  posts.forEach((post) => {
    const year = String(post.date.getUTCFullYear());
    archives.set(year, [...(archives.get(year) || []), post]);
  });
  const archivesHtml = [...archives.entries()].sort((a, b) => b[0].localeCompare(a[0])).map(([year, yearPosts]) => `<h2>${year}</h2><ul class="list-unstyled">${yearPosts.map((post) => `<li class="d-flex"><time class="me-3 text-muted">${dateLabel(post.date)}</time><a href="${post.url}">${htmlEscape(post.title)}</a></li>`).join('')}</ul>`).join('');
  await writeOutput('archives/index.html', listingPage(site, posts, 'Archives', 'archives', `<div id="archives">${archivesHtml}</div>`));

  await writeOutput('categories/index.html', listingPage(site, posts, 'Categories', 'categories', `<ul class="content ps-0">${groupLinks(categories, 'categories')}</ul>`));
  await Promise.all([...categories.entries()].map(([category, categoryPosts]) => writeOutput(`categories/${slugify(category)}/index.html`, listingPage(site, posts, category, 'categories', `<div id="post-list">${categoryPosts.map(postPreview).join('')}</div>`))));
  await writeOutput('tags/index.html', listingPage(site, posts, 'Tags', 'tags', `<div class="d-flex flex-wrap">${[...tags.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([tag, tagPosts]) => `<a class="post-tag btn btn-outline-primary" href="/tags/${slugify(tag)}/">${htmlEscape(tag)} <span class="text-muted">${tagPosts.length}</span></a>`).join('')}</div>`));
  await Promise.all([...tags.entries()].map(([tag, tagPosts]) => writeOutput(`tags/${slugify(tag)}/index.html`, listingPage(site, posts, tag, 'tags', `<div id="post-list">${tagPosts.map(postPreview).join('')}</div>`))));

  const aboutHtml = about ? renderMarkdown(about.markdown) : '<p>About content has not been written yet.</p>';
  await writeOutput('about/index.html', documentPage({ site, title: about?.data.title || 'About', description: site.description, active: 'about', kind: 'page', main: `<article class="px-1"><div class="content">${aboutHtml}</div></article>`, posts, breadcrumb: 'About' }));
  await writeOutput('404.html', documentPage({ site, title: 'Page not found', description: 'The requested page does not exist.', active: 'home', kind: 'listing', main: '<section class="px-1"><h1>404</h1><p>The requested page does not exist.</p><p><a class="btn btn-outline-primary" href="/">Back to home</a></p></section>', posts, breadcrumb: '404' }));

  const search = posts.map((post) => ({ title: post.title, url: post.url, categories: post.categories.join(', '), tags: post.tags.join(', '), date: post.date.toISOString(), content: stripHtml(post.html) }));
  await writeOutput('assets/js/data/search.json', `${JSON.stringify(search)}\n`);
  const updated = new Date(Math.max(...posts.map((post) => post.date.valueOf()))).toISOString();
  const feedEntries = posts.slice(0, 20).map((post) => `<entry><title>${xmlEscape(post.title)}</title><link href="${site.siteUrl}${post.url}"/><id>${site.siteUrl}${post.url}</id><updated>${post.date.toISOString()}</updated><summary>${xmlEscape(post.excerpt)}</summary><content type="html">${xmlEscape(post.html)}</content></entry>`).join('');
  await writeOutput('feed.xml', `<?xml version="1.0" encoding="utf-8"?><feed xmlns="http://www.w3.org/2005/Atom"><title>${xmlEscape(site.title)}</title><id>${site.siteUrl}/</id><updated>${updated}</updated>${feedEntries}</feed>`);
  const urls = ['/', '/posts/', '/about/', '/archives/', '/categories/', '/tags/', ...posts.map((post) => post.url)];
  await writeOutput('sitemap.xml', `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls.map((url) => `<url><loc>${site.siteUrl}${url}</loc></url>`).join('')}</urlset>`);
  await writeOutput('robots.txt', `User-agent: *\nAllow: /\nSitemap: ${site.siteUrl}/sitemap.xml\n`);
  const buildId = `${posts.length}-${Math.max(...posts.map((post) => post.date.valueOf()))}`;
  await createRuntimeFiles(site, buildId);
  console.log(`Built ${posts.length} posts, ${categories.size} categories, and ${tags.size} tags as static HTML.`);
}

await build();
