import { cp, lstat, mkdir, rm } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const destination = process.argv[2];

if (!destination) {
  throw new Error('Usage: node scripts/prepare-pages-artifact.mjs <destination>');
}

const excluded = new Set([
  '.devcontainer',
  '.editorconfig',
  '.gitattributes',
  '.gitignore',
  '.github',
  '.git',
  '.vscode',
  'content',
  'LICENSE',
  'migration',
  'node_modules',
  'package.json',
  'pnpm-lock.yaml',
  'README.md',
  'scripts'
]);

await rm(destination, { recursive: true, force: true });
await mkdir(destination, { recursive: true });

await cp(root, destination, {
  recursive: true,
  force: true,
  filter: async (source) => {
    const relative = path.relative(root, source);
    if (!relative) return true;
    const topLevel = relative.split(path.sep, 1)[0];
    if (excluded.has(topLevel)) return false;
    return !(await lstat(source)).isSymbolicLink();
  }
});
