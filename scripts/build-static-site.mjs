import { access, mkdir, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const contentRoot = path.join(root, 'content');
const postsRoot = path.join(contentRoot, 'posts');
const pagesRoot = path.join(contentRoot, 'pages');

const htmlEscape = (value = '') => String(value)
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;').replaceAll("'", '&#39;');
const attrEscape = htmlEscape;
const stripHtml = (value = '') => String(value).replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
const slugify = (value = '') => String(value).normalize('NFKD').replace(/[^\p{L}\p{N}]+/gu, '-').replace(/^-+|-+$/g, '').toLowerCase() || 'post';
const dateLabel = (date) => new Intl.DateTimeFormat('en', { month: 'short', day: '2-digit', year: 'numeric', timeZone: 'Asia/Seoul' }).format(date).toUpperCase();
const postSlug = (filename) => path.basename(filename, path.extname(filename)).replace(/^\d{4}-\d{2}-\d{2}-/, '');

function parseScalar(value = '') {
  const trimmed = value.trim();
  if (!trimmed) return '';
  if (trimmed === 'true') return true;
  if (trimmed === 'false') return false;
  if ((trimmed.startsWith('"') && trimmed.endsWith('"')) || (trimmed.startsWith("'") && trimmed.endsWith("'"))) return trimmed.slice(1, -1);
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) return trimmed.slice(1, -1).split(',').map(parseScalar).filter(Boolean);
  return trimmed;
}

function parseFrontMatter(source, filePath) {
  const normalized = source.replace(/\r\n?/g, '\n');
  if (!normalized.startsWith('---')) return { data: {}, body: normalized };
  const close = normalized.indexOf('\n---', 3);
  if (close === -1) throw new Error(`Unclosed front matter: ${filePath}`);
  const data = {};
  for (const line of normalized.slice(3, close).replace(/^\n/, '').split('\n')) {
    if (/^\s/.test(line) || line.trimStart().startsWith('#')) continue;
    const match = line.match(/^([A-Za-z][\w-]*):(?:\s*(.*))?$/);
    if (match) data[match[1]] = parseScalar(match[2]);
  }
  return { data, body: normalized.slice(close + 4).replace(/^\n/, '') };
}

const toArray = (value) => Array.isArray(value) ? value.map(String).filter(Boolean) : value === undefined || value === null || value === '' ? [] : [String(value)];
const mathExpression = /\$\$[\s\S]+?\$\$|\\\[[\s\S]+?\\\]|\\\([\s\S]+?\\\)|(?<!\\)\$(?!\$)(?:\\.|[^$\\\n])+(?<!\\)\$(?!\$)/g;

function applyMarkdownConventions(markdown) {
  return markdown.replace(/^\{:\s*([^}]+)\}\s*$/gm, '').replace(/\{:\s*[^}]+\}/g, '').replace(/\n<!-- markdownlint-[\s\S]*?-->/g, '\n');
}

function protectMath(markdown) {
  const math = [];
  const protectSegment = (segment) => segment.replace(mathExpression, (formula) => {
    const index = math.push({ value: formula, display: formula.startsWith('$$') || formula.startsWith('\\[') }) - 1;
    return `@@MATH_${index}@@`;
  });
  const parts = markdown.split(/(```[\s\S]*?```|`[^`\n]*`)/g);
  return { markdown: parts.map((part, index) => index % 2 ? part : protectSegment(part)).join(''), math };
}

function restoreMath(html, math) {
  const replaceToken = (token, inBlock = false) => {
    const entry = math[Number(token.match(/\d+/)?.[0])];
    if (!entry) return token;
    const source = htmlEscape(entry.value);
    return inBlock || entry.display ? `<div class="math-source math-display">${source}</div>` : `<span class="math-source">${source}</span>`;
  };
  const withDisplayBlocks = html.replace(/<p>\s*(@@MATH_\d+@@)\s*<\/p>\n?/g, (match, token) => {
    const entry = math[Number(token.match(/\d+/)?.[0])];
    return entry?.display ? `${replaceToken(token, true)}\n` : match;
  });
  return withDisplayBlocks.replace(/@@MATH_\d+@@/g, (token) => replaceToken(token));
}

function renderMarkdown(markdown) {
  const headingIds = new Map();
  const renderer = new marked.Renderer();
  renderer.heading = function heading({ tokens, depth }) {
    const text = this.parser.parseInline(tokens);
    const base = slugify(stripHtml(text));
    const count = headingIds.get(base) || 0;
    headingIds.set(base, count + 1);
    return `<h${depth} id="${count ? `${base}-${count}` : base}">${text}</h${depth}>\n`;
  };
  renderer.code = ({ text, lang }) => `<section class="code-block"><header><span>${htmlEscape(lang || 'TEXT')}</span><button type="button" data-copy-code aria-label="Copy code"><i class="fa-regular fa-copy"></i><b>COPY</b></button></header><pre><code class="language-${attrEscape(lang || 'plaintext')}">${htmlEscape(text)}</code></pre></section>\n`;
  renderer.image = ({ href, title, text }) => `<figure class="article-image"><a href="${attrEscape(href)}" class="popup"><img src="${attrEscape(href)}" alt="${attrEscape(text || '')}" loading="lazy"${title ? ` title="${attrEscape(title)}"` : ''}></a>${text ? `<figcaption>${htmlEscape(text)}</figcaption>` : ''}</figure>`;
  const protectedSource = protectMath(applyMarkdownConventions(markdown));
  const rendered = marked.parse(protectedSource.markdown, { gfm: true, breaks: false, renderer })
    .replace(/<p>(<figure class="article-image">[\s\S]*?<\/figure>)<\/p>\n?/g, '$1\n');
  return { html: restoreMath(rendered, protectedSource.math), math: protectedSource.math.length > 0 };
}

async function readMarkdownFiles(folder) {
  const entries = await readdir(folder, { withFileTypes: true });
  const files = entries.filter((entry) => entry.isFile() && /\.md$/i.test(entry.name)).map((entry) => entry.name).sort();
  return Promise.all(files.map(async (filename) => {
    const filePath = path.join(folder, filename);
    const raw = await readFile(filePath, 'utf8');
    const { data, body } = parseFrontMatter(raw, filePath);
    return { filePath, filename, data, markdown: body };
  }));
}

async function writeOutput(relativePath, content) {
  const destination = path.join(root, relativePath);
  await mkdir(path.dirname(destination), { recursive: true });
  await writeFile(destination, content, 'utf8');
}

function primaryImage(markdown) {
  const line = markdown.split('\n').find((value) => /^!\[[^\]]*\]\(.+\)\s*$/.test(value.trim()));
  const match = line?.trim().match(/^!\[[^\]]*\]\((.+)\)$/);
  return match?.[1]?.trim() || '';
}

async function discardMissingLocalImages(posts) {
  await Promise.all(posts.map(async (post) => {
    if (!post.image.startsWith('/')) return;
    try {
      await access(path.join(root, decodeURIComponent(post.image).replace(/^\//, '')));
    } catch {
      post.image = '';
    }
  }));
}

function countGroups(posts) {
  const categories = new Map(); const tags = new Map();
  for (const post of posts) {
    post.categories.forEach((category) => categories.set(category, [...(categories.get(category) || []), post]));
    post.tags.forEach((tag) => tags.set(tag, [...(tags.get(tag) || []), post]));
  }
  return { categories, tags };
}

function topTags(posts, limit = 8) {
  const counts = new Map();
  posts.forEach((post) => post.tags.forEach((tag) => counts.set(tag, (counts.get(tag) || 0) + 1)));
  return [...counts.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])).slice(0, limit);
}

function pageScripts({ math = false, article = false }) {
  return [
    article && '<script defer src="https://cdn.jsdelivr.net/npm/glightbox@3.3.0/dist/js/glightbox.min.js"></script>',
    '<script defer src="/assets/js/static-site.js"></script>',
    '<script defer src="/app.js"></script>',
    math && '<script>window.MathJax={tex:{inlineMath:[["$","$"],["\\\\(","\\\\)"]],displayMath:[["$$","$$"],["\\\\[","\\\\]"]],tags:"ams"},options:{skipHtmlTags:["script","noscript","style","textarea","pre","code"],processHtmlClass:"math-source"}};</script>',
    math && '<script defer id="MathJax-script" src="https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-chtml.js"></script>'
  ].filter(Boolean).join('\n  ');
}

function header(site, active) {
  const items = [['home', '/', 'HOME'], ['posts', '/posts/', 'POSTS'], ['categories', '/categories/', 'TOPICS'], ['archives', '/archives/', 'ARCHIVE'], ['about', '/about/', 'ABOUT']];
  return `<header class="site-header" data-menu-open="false"><a class="brand" href="/" aria-label="${attrEscape(site.title)} home"><img class="brand-mark" src="/assets/img/favicons/walll-v1.svg" width="33" height="33" alt=""><span><strong>낭낭하게 개발하기</strong><small>Watch this</small></span></a><nav class="site-nav" aria-label="Primary navigation">${items.map(([id, href, label]) => `<a href="${href}"${id === active ? ' aria-current="page"' : ''}>${label}</a>`).join('')}</nav><div class="header-actions"><button class="search-button" type="button" data-search-open aria-label="Search posts"><i class="fa-solid fa-magnifying-glass"></i><span>SEARCH</span><kbd>⌘ K</kbd></button><button class="menu-button" type="button" data-menu-toggle aria-label="Toggle navigation"><i class="fa-solid fa-bars"></i></button></div></header>`;
}

function footer(site) {
  return `<footer class="site-footer"><p><span>© ${new Date().getFullYear()}</span> ${htmlEscape(site.author.name)} · ${htmlEscape(site.footer.licenseName)}</p><p>BUILT FOR <em>REAL-TIME WORLDS</em></p></footer>`;
}

function searchOverlay(posts) {
  const tags = topTags(posts, 6).map(([tag]) => `<a href="/tags/${slugify(tag)}/">#${htmlEscape(tag)}</a>`).join('');
  return `<section class="search-overlay" id="search-overlay" hidden aria-label="Search posts"><div class="search-panel"><div class="search-panel-top"><p>POST SEARCH</p><button type="button" data-search-close aria-label="Close search"><i class="fa-solid fa-xmark"></i></button></div><label for="search-input">SEARCH POSTS</label><div class="search-input-wrap"><i class="fa-solid fa-magnifying-glass"></i><input id="search-input" type="search" autocomplete="off" placeholder="Shader, Unity, vector …"></div><div id="search-hints"><span>POPULAR POSTS</span><div>${tags}</div></div><div id="search-results" aria-live="polite"></div></div></section>`;
}

function tocFor(post) {
  const headings = [...post.html.matchAll(/<h([2-3]) id="([^"]+)">([\s\S]*?)<\/h\1>/g)];
  if (!headings.length) return '';
  return `<section class="rail-section table-of-contents"><p class="rail-label">IN THIS NOTE</p><nav aria-label="Table of contents"><ol>${headings.map(([, level, id, text]) => `<li class="level-${level}"><a href="#${id}">${stripHtml(text)}</a></li>`).join('')}</ol></nav></section>`;
}

function rail(posts, toc = '') {
  const recent = posts.slice(0, 4).map((post, index) => `<li><span>0${index + 1}</span><a href="${post.url}">${htmlEscape(post.title)}</a></li>`).join('');
  const tags = topTags(posts, 7).map(([tag]) => `<a href="/tags/${slugify(tag)}/">#${htmlEscape(tag)}</a>`).join('');
  return `<aside class="context-rail">${toc}<section class="rail-section"><p class="rail-label">LATEST POSTS</p><ol class="post-list">${recent}</ol></section><section class="rail-section"><p class="rail-label">TOP TAGS</p><div class="rail-tags">${tags}</div></section></aside>`;
}

function documentPage({ site, title, description, active, kind, main, posts, canonicalPath, math = false, toc = '' }) {
  const canonical = `${site.siteUrl}${canonicalPath}`;
  const styles = ['<link rel="preconnect" href="https://fonts.googleapis.com">', '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>', '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Noto+Sans+KR:wght@400;500;700;900&family=Space+Grotesk:wght@400;500;600;700&display=swap">', '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.7.1/css/all.min.css">', '<link rel="stylesheet" href="/assets/css/site.css">', kind === 'post' && '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/glightbox@3.3.0/dist/css/glightbox.min.css">'].filter(Boolean).join('\n  ');
  const metadata = JSON.stringify({ '@context': 'https://schema.org', '@type': kind === 'post' ? 'BlogPosting' : 'WebSite', headline: title, description, url: canonical, author: { '@type': 'Person', name: site.author.name } });
  return `<!doctype html><html lang="${attrEscape(site.language || 'ko')}" data-page="${attrEscape(kind)}"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"><meta name="theme-color" content="#0a0c10"><meta name="description" content="${attrEscape(description)}"><link rel="canonical" href="${attrEscape(canonical)}"><link rel="icon" type="image/svg+xml" href="/assets/img/favicons/walll-v1.svg"><link rel="icon" type="image/x-icon" href="/favicon.ico?v=walll-v1"><link rel="icon" type="image/png" sizes="16x16" href="/assets/img/favicons/favicon-16x16.png?v=walll-v1"><link rel="apple-touch-icon" sizes="180x180" href="/assets/img/favicons/apple-touch-icon.png?v=walll-v1"><link rel="icon" type="image/png" sizes="32x32" href="/assets/img/favicons/favicon-32x32.png?v=walll-v1"><link rel="manifest" href="/assets/img/favicons/site.webmanifest?v=walll-v1"><meta property="og:title" content="${attrEscape(title)}"><meta property="og:description" content="${attrEscape(description)}"><meta property="og:url" content="${attrEscape(canonical)}"><meta property="og:type" content="${kind === 'post' ? 'article' : 'website'}"><script type="application/ld+json">${metadata.replaceAll('<', '\\u003c')}</script><title>${htmlEscape(active === 'home' ? site.title : `${title} | ${site.title}`)}</title>${styles}${pageScripts({ math, article: kind === 'post' || kind === 'page' })}</head><body>${header(site, active)}${kind === 'post' ? '<div class="reading-line"><i id="reading-progress"></i></div>' : ''}<main class="site-main"><div class="page-grid">${main}${rail(posts, toc)}</div></main>${footer(site)}${searchOverlay(posts)}</body></html>`;
}

function cardImage(post) { return post.image ? `<img src="${attrEscape(post.image)}" alt="" loading="lazy">` : '<span class="card-grid-decoration" aria-hidden="true"></span>'; }
function postCard(post, index = 0) {
  const category = post.categories[0] || 'DEVLOG';
  return `<article class="post-card"><a href="${post.url}"><div class="card-media">${cardImage(post)}<span class="card-index">${String(index + 1).padStart(2, '0')}</span></div><div class="card-copy"><p class="eyebrow"><span>${htmlEscape(category)}</span><time datetime="${post.date.toISOString()}">${dateLabel(post.date)}</time></p><h2>${htmlEscape(post.title)}</h2><p>${htmlEscape(post.excerpt || post.description || 'A development post.')}</p><span class="card-link">READ POST <i class="fa-solid fa-arrow-up-right-from-square"></i></span></div></a></article>`;
}

function homePage(site, posts) {
  const featured = posts[0]; const otherPosts = posts.slice(1, Number(site.postsPerPage) || 10);
  const categoryCount = new Set(posts.flatMap((post) => post.categories)).size;
  const main = `<section class="home-page"><section class="metrics" aria-label="Blog metrics"><div><strong>${String(posts.length).padStart(2, '0')}</strong><span>POSTS</span></div><div><strong>${String(categoryCount).padStart(2, '0')}</strong><span>TOPICS</span></div><div><strong>${String(topTags(posts).length).padStart(2, '0')}</strong><span>TAGS</span></div></section>${featured ? `<section class="featured-note"><p class="section-kicker">LATEST POST</p><a href="${featured.url}"><div><p class="eyebrow"><span>${htmlEscape(featured.categories[0] || 'DEVLOG')}</span><time>${dateLabel(featured.date)}</time></p><h2>${htmlEscape(featured.title)}</h2><p>${htmlEscape(featured.excerpt || featured.description)}</p></div><span class="featured-arrow"><i class="fa-solid fa-arrow-up-right-from-square"></i></span></a></section>` : ''}<section class="note-section"><div class="section-heading"><h2>RECENT <em>POSTS</em></h2><a href="/posts/">VIEW ALL <i class="fa-solid fa-arrow-right"></i></a></div><div class="post-grid">${otherPosts.map((post, index) => postCard(post, index + 1)).join('')}</div></section></section>`;
  return documentPage({ site, title: site.title, description: site.description, active: 'home', kind: 'home', main, posts, canonicalPath: '/' });
}

function postNavigation(posts, index) {
  const navCard = (post, label) => post ? `<a href="${post.url}"><small>${label}</small><span>${htmlEscape(post.title)}</span><i class="fa-solid fa-arrow-${label === 'PREVIOUS POST' ? 'left' : 'right'}"></i></a>` : `<span class="empty-nav"><small>${label}</small><b>NO POST</b></span>`;
  return `<nav class="post-navigation" aria-label="Post navigation">${navCard(posts[index + 1], 'PREVIOUS POST')}${navCard(posts[index - 1], 'NEXT POST')}</nav>`;
}

function postPage(post, posts, index, site) {
  const categories = post.categories.map((category) => `<a href="/categories/${slugify(category)}/">${htmlEscape(category)}</a>`).join(' · ');
  const tags = post.tags.map((tag) => `<a href="/tags/${slugify(tag)}/">#${htmlEscape(tag)}</a>`).join('');
  const readMinutes = Math.max(1, Math.ceil(stripHtml(post.html).split(/\s+/).filter(Boolean).length / 200));
  const main = `<article class="article-page"><header class="article-header"><p class="system-label"><i></i> ${htmlEscape(post.categories[0] || 'DEVLOG')} / POST ${String(index + 1).padStart(2, '0')}</p><h1>${htmlEscape(post.title)}</h1>${post.description ? `<p class="article-deck">${htmlEscape(post.description)}</p>` : ''}<div class="article-meta"><time datetime="${post.date.toISOString()}">${dateLabel(post.date)}</time><span>${readMinutes} MIN READ</span><span>BY ${htmlEscape(site.author.name)}</span></div></header><div class="article-content">${post.html}</div><footer class="article-footer"><div><p class="rail-label">CATEGORY</p><p class="category-links">${categories || 'DEVLOG'}</p></div>${tags ? `<div><p class="rail-label">POST TAGS</p><p class="article-tags">${tags}</p></div>` : ''}</footer>${postNavigation(posts, index)}</article>`;
  return documentPage({ site, title: post.title, description: post.excerpt || post.description || site.description, active: 'posts', kind: 'post', main, posts, canonicalPath: post.url, math: post.math, toc: tocFor(post) });
}

function listingPage(site, posts, title, active, content, canonicalPath) {
  const main = `<section class="listing-page"><header class="listing-header"><p class="system-label"><i></i> INDEX // ${htmlEscape(active).toUpperCase()}</p><h1>${htmlEscape(title)}</h1></header>${content}</section>`;
  return documentPage({ site, title, description: `${title} | ${site.title}`, active, kind: 'listing', main, posts, canonicalPath });
}

function paginator(posts, page, perPage) {
  const pageCount = Math.max(1, Math.ceil(posts.length / perPage));
  if (pageCount === 1) return '';
  return `<nav class="pagination" aria-label="Page navigation">${Array.from({ length: pageCount }, (_, index) => index + 1).map((number) => `<a href="${number === 1 ? '/' : `/page/${number}/`}"${number === page ? ' aria-current="page"' : ''}>${String(number).padStart(2, '0')}</a>`).join('')}</nav>`;
}

function groupLinks(groups, rootPath) {
  return `<ul class="group-list">${[...groups.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([name, items], index) => `<li><a href="/${rootPath}/${slugify(name)}/"><span>${String(index + 1).padStart(2, '0')}</span>${htmlEscape(name)}<b>${String(items.length).padStart(2, '0')}</b><i class="fa-solid fa-arrow-right"></i></a></li>`).join('')}</ul>`;
}

async function removeGeneratedRoutes() { await Promise.all(['posts', 'page', 'about', 'archives', 'categories', 'tags'].map((target) => rm(path.join(root, target), { recursive: true, force: true }))); }

async function createRuntimeFiles(site, buildId) {
  const worker = `const CACHE='game-tech-${buildId}';self.addEventListener('install',event=>self.skipWaiting());self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));self.addEventListener('fetch',event=>{if(event.request.method!==\"GET\"||new URL(event.request.url).origin!==self.location.origin)return;event.respondWith(fetch(event.request).then(response=>{const copy=response.clone();caches.open(CACHE).then(cache=>cache.put(event.request,copy));return response;}).catch(()=>caches.match(event.request)));});\n`;
  const manifest = JSON.stringify({ name: site.title, short_name: site.title, description: site.description, start_url: '/', display: 'standalone', background_color: '#0a0c10', theme_color: '#0a0c10', icons: [{ src: '/assets/img/favicons/android-chrome-192x192.png?v=walll-v1', sizes: '192x192', type: 'image/png' }, { src: '/assets/img/favicons/android-chrome-512x512.png?v=walll-v1', sizes: '512x512', type: 'image/png' }] }, null, 2) + '\n';
  await Promise.all([writeOutput('app.js', "if ('serviceWorker' in navigator) { window.addEventListener('load', () => navigator.serviceWorker.register('/sw.js').catch(() => {})); }\n"), writeOutput('sw.js', worker), writeOutput('assets/js/data/swconf.js', `const swconf={cacheName:'${buildId}',resources:['/']};\n`), writeOutput('assets/img/favicons/site.webmanifest', manifest), writeOutput('assets/img/favicons/browserconfig.xml', '<?xml version="1.0" encoding="utf-8"?><browserconfig><msapplication><tile><square150x150logo src="/assets/img/favicons/mstile-150x150.png?v=walll-v1"/><TileColor>#0a0c10</TileColor></tile></msapplication></browserconfig>\n'), writeOutput('.nojekyll', '')]);
}

async function build() {
  const site = JSON.parse(await readFile(path.join(contentRoot, 'site.json'), 'utf8'));
  const sourcePosts = await readMarkdownFiles(postsRoot);
  const sourcePages = await readMarkdownFiles(pagesRoot);
  const posts = sourcePosts.map((source) => {
    const date = new Date(source.data.date);
    if (Number.isNaN(date.valueOf())) throw new Error(`Invalid date in front matter: ${source.filePath}`);
    const rendered = renderMarkdown(source.markdown);
    return { ...source, title: source.data.title || postSlug(source.filename), excerpt: source.data.excerpt || source.data.description || '', description: source.data.description || '', date, categories: toArray(source.data.categories), tags: toArray(source.data.tags ?? source.data.tag), slug: postSlug(source.filename), url: `/posts/${postSlug(source.filename)}/`, image: primaryImage(source.markdown), html: rendered.html, math: source.data.math === true || rendered.math };
  }).sort((a, b) => b.date - a.date || a.slug.localeCompare(b.slug));
  const { categories, tags } = countGroups(posts);
  await discardMissingLocalImages(posts);
  const about = sourcePages.find((page) => page.filename.toLowerCase() === 'about.md');
  const aboutRendered = about ? renderMarkdown(about.markdown) : { html: '<p>About content has not been written yet.</p>', math: false };
  const perPage = Number(site.postsPerPage) || 10;
  await removeGeneratedRoutes();
  await writeOutput('index.html', homePage(site, posts));
  const totalPages = Math.max(1, Math.ceil(posts.length / perPage));
  for (let page = 2; page <= totalPages; page += 1) {
    const pagePosts = posts.slice((page - 1) * perPage, page * perPage);
    await writeOutput(`page/${page}/index.html`, listingPage(site, posts, `Posts / ${String(page).padStart(2, '0')}`, 'posts', `<div class="post-grid">${pagePosts.map(postCard).join('')}</div>${paginator(posts, page, perPage)}`, `/page/${page}/`));
  }
  await Promise.all(posts.map((post, index) => writeOutput(`posts/${post.slug}/index.html`, postPage(post, posts, index, site))));
  await writeOutput('posts/index.html', listingPage(site, posts, 'All Posts', 'posts', `<div class="post-grid">${posts.map(postCard).join('')}</div>`, '/posts/'));
  const archives = new Map(); posts.forEach((post) => { const year = String(post.date.getUTCFullYear()); archives.set(year, [...(archives.get(year) || []), post]); });
  const archiveContent = `<div class="archive-list">${[...archives.entries()].sort((a, b) => b[0].localeCompare(a[0])).map(([year, entries]) => `<section><h2>${year}</h2>${entries.map((post, index) => `<a href="${post.url}"><span>${String(index + 1).padStart(2, '0')}</span><time>${dateLabel(post.date)}</time><b>${htmlEscape(post.title)}</b><i class="fa-solid fa-arrow-up-right-from-square"></i></a>`).join('')}</section>`).join('')}</div>`;
  await writeOutput('archives/index.html', listingPage(site, posts, 'Archive', 'archives', archiveContent, '/archives/'));
  await writeOutput('categories/index.html', listingPage(site, posts, 'Topics', 'categories', groupLinks(categories, 'categories'), '/categories/'));
  await Promise.all([...categories.entries()].map(([category, entries]) => writeOutput(`categories/${slugify(category)}/index.html`, listingPage(site, posts, category, 'categories', `<div class="post-grid">${entries.map(postCard).join('')}</div>`, `/categories/${slugify(category)}/`))));
  const tagContent = `<div class="tag-cloud">${[...tags.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([tag, entries]) => `<a href="/tags/${slugify(tag)}/">#${htmlEscape(tag)}<span>${String(entries.length).padStart(2, '0')}</span></a>`).join('')}</div>`;
  await writeOutput('tags/index.html', listingPage(site, posts, 'Post Tags', 'tags', tagContent, '/tags/'));
  await Promise.all([...tags.entries()].map(([tag, entries]) => writeOutput(`tags/${slugify(tag)}/index.html`, listingPage(site, posts, `#${tag}`, 'tags', `<div class="post-grid">${entries.map(postCard).join('')}</div>`, `/tags/${slugify(tag)}/`))));
  await writeOutput('about/index.html', documentPage({ site, title: about?.data.title || 'About', description: site.description, active: 'about', kind: 'page', main: `<article class="article-page about-page"><header class="article-header"><p class="system-label"><i></i> OPERATOR PROFILE</p><h1>${htmlEscape(about?.data.title || 'About')}</h1></header><div class="article-content">${aboutRendered.html}</div></article>`, posts, canonicalPath: '/about/', math: aboutRendered.math }));
  await writeOutput('404.html', documentPage({ site, title: 'Page Not Found', description: 'The requested page does not exist.', active: 'home', kind: 'listing', main: '<section class="listing-page not-found"><p class="system-label"><i></i> ERROR / 404</p><h1>PAGE NOT<br><em>FOUND.</em></h1><p>The page you requested does not exist.</p><a class="button-primary" href="/">RETURN HOME <i class="fa-solid fa-arrow-right"></i></a></section>', posts, canonicalPath: '/404.html' }));
  const search = posts.map((post) => ({ title: post.title, url: post.url, categories: post.categories.join(', '), tags: post.tags.join(', '), date: post.date.toISOString(), content: stripHtml(post.html) }));
  await writeOutput('assets/js/data/search.json', `${JSON.stringify(search)}\n`);
  const updated = new Date(Math.max(...posts.map((post) => post.date.valueOf()))).toISOString();
  const feedEntries = posts.slice(0, 20).map((post) => `<entry><title>${htmlEscape(post.title)}</title><link href="${site.siteUrl}${post.url}"/><id>${site.siteUrl}${post.url}</id><updated>${post.date.toISOString()}</updated><summary>${htmlEscape(post.excerpt)}</summary><content type="html">${htmlEscape(post.html)}</content></entry>`).join('');
  await writeOutput('feed.xml', `<?xml version="1.0" encoding="utf-8"?><feed xmlns="http://www.w3.org/2005/Atom"><title>${htmlEscape(site.title)}</title><id>${site.siteUrl}/</id><updated>${updated}</updated>${feedEntries}</feed>`);
  const urls = ['/', '/posts/', '/about/', '/archives/', '/categories/', '/tags/', ...posts.map((post) => post.url)];
  await writeOutput('sitemap.xml', `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls.map((url) => `<url><loc>${site.siteUrl}${url}</loc></url>`).join('')}</urlset>`);
  await writeOutput('robots.txt', `User-agent: *\nAllow: /\nSitemap: ${site.siteUrl}/sitemap.xml\n`);
  await createRuntimeFiles(site, `walll-v1-${posts.length}-${Math.max(...posts.map((post) => post.date.valueOf()))}`);
  console.log(`Built ${posts.length} posts, ${categories.size} categories, and ${tags.size} tags as static HTML.`);
}

await build();
