import { access, readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const required = ['index.html', 'posts/index.html', 'archives/index.html', 'categories/index.html', 'tags/index.html', 'about/index.html', 'assets/css/site.css', 'assets/js/data/search.json', 'app.js', 'sw.js'];

for (const relativePath of required) {
  await access(path.join(root, relativePath));
}

const search = JSON.parse(await readFile(path.join(root, 'assets/js/data/search.json'), 'utf8'));
if (!Array.isArray(search) || search.length === 0) throw new Error('Search index is empty.');
for (const entry of search) {
  const file = path.join(root, entry.url.replace(/^\//, ''), 'index.html');
  const info = await stat(file);
  if (!info.isFile()) throw new Error(`Missing generated post: ${entry.url}`);
}

async function listHtmlFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(entries.map(async (entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) return listHtmlFiles(entryPath);
    return entry.isFile() && entry.name.endsWith('.html') ? [entryPath] : [];
  }));
  return nested.flat();
}

const htmlRoots = ['.', 'posts', 'page', 'about', 'archives', 'categories', 'tags'];
const htmlFiles = (await Promise.all(htmlRoots.map((relativePath) => listHtmlFiles(path.join(root, relativePath))))).flat();
const missingLinks = new Set();
for (const file of htmlFiles) {
  const html = await readFile(file, 'utf8');
  for (const match of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    const value = match[1].split(/[?#]/, 1)[0];
    if (!value.startsWith('/') || value.startsWith('//')) continue;
    const decoded = decodeURIComponent(value);
    const target = path.join(root, decoded.replace(/^\//, ''));
    const candidates = path.extname(target) ? [target] : [path.join(target, 'index.html'), target];
    try {
      await Promise.any(candidates.map((candidate) => access(candidate)));
    } catch {
      missingLinks.add(`${path.relative(root, file)} -> ${value}`);
    }
  }
}
if (missingLinks.size) throw new Error(`Broken local links (${missingLinks.size}):\n${[...missingLinks].slice(0, 20).join('\n')}`);
console.log(`Static site checks passed for ${search.length} posts and ${htmlFiles.length} HTML files.`);
