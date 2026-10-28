#!/usr/bin/env node
/**
 * prepare_r2_assets.mjs
 *
 * Builds `assets-r2/` — a clean staging folder ready to upload to Cloudflare R2:
 *
 *   - collects every storage object referenced by the DB (questions / options /
 *     challenges) plus `challenges/logo.png`
 *   - re-encodes question videos to 720p (H.264 CRF 26, AAC 96k, faststart) for
 *     fast start on school/mobile connections; originals in `assets-supabase/`
 *     are never modified
 *   - keeps object keys identical to the Supabase storage paths
 *     (`question/<slug>.mp4`, `option/*.png`, `challenges/*.png`) so the DB
 *     rewrite is a pure URL-prefix swap
 *   - writes `assets-r2/manifest.json` consumed by `upload_r2.mjs`
 *
 * Flags:
 *   --force           re-transcode / re-copy even if the output already exists
 *   --skip-transcode  copy the existing (already-encoded) files as-is
 */
import { spawnSync } from 'node:child_process';
import { createWriteStream, existsSync, mkdirSync, readFileSync, statSync, writeFileSync, readdirSync } from 'node:fs';
import { copyFileSync } from 'node:fs';
import path from 'node:path';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const SRC = path.join(ROOT, 'assets-supabase');
const OUT = path.join(ROOT, 'assets-r2');

const force = process.argv.includes('--force');
const skipTranscode = process.argv.includes('--skip-transcode');

// --- Supabase config from the Flutter config file --------------------------
const cfg = readFileSync(path.join(ROOT, 'lib/core/config/supabase_config.dart'), 'utf8');
const defaults = [...cfg.matchAll(/defaultValue:\s*'([^']+)'/g)].map((m) => m[1]);
const SUPABASE_URL = (defaults[0] || '').replace(/\/$/, '');
const SUPABASE_ANON = defaults[1] || '';
if (!SUPABASE_URL || !SUPABASE_ANON) throw new Error('Could not read SUPABASE_URL / anon key from supabase_config.dart');
const PROJECT_REF = SUPABASE_URL.match(/https:\/\/([a-z0-9]+)\.supabase\.co/)?.[1];
const OLD_REF = 'jokvxdrxswytjjhxuhvk';

// --- 1. Collect every storage object referenced by the DB ------------------
const refs = new Set(['challenges/logo.png']);
const oldProjectRefs = [];
const anonHeaders = { apikey: SUPABASE_ANON, Authorization: `Bearer ${SUPABASE_ANON}` };

for (const table of ['questions', 'options', 'challenges']) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${table}?select=*`, { headers: anonHeaders });
  if (!res.ok) {
    console.error(`WARN: cannot read table "${table}" (${res.status}) — continuing`);
    continue;
  }
  const rows = await res.json();
  console.log(`table ${table}: ${rows.length} rows`);
  for (const row of rows) {
    for (const value of Object.values(row)) {
      if (typeof value !== 'string') continue;
      const newRef = value.match(new RegExp(`${PROJECT_REF}\\.supabase\\.co/storage/v1/object/public/(.+)$`));
      if (newRef) refs.add(newRef[1]);
      const oldRef = value.match(new RegExp(`${OLD_REF}\\.supabase\\.co/storage/v1/object/public/(.+)$`));
      if (oldRef) oldProjectRefs.push(`${table}: ${oldRef[1]}`);
    }
  }
}

if (oldProjectRefs.length) {
  console.error(`\nWARNING: ${oldProjectRefs.length} DB value(s) still point at the OLD project (402-blocked):`);
  for (const r of [...new Set(oldProjectRefs)]) console.error(`  - ${r}`);
}

const refList = [...refs].sort();
console.log(`\nObjects referenced by the app: ${refList.length}`);
for (const r of refList) console.log(`  - ${r}`);

// --- 2. Resolve each object to a local source file -------------------------
function findSource(bucket, key) {
  // exact match first (e.g. option/flat.png, challenges/challenges-1.png)
  const exact = path.join(SRC, bucket, path.basename(key));
  if (existsSync(exact)) return exact;
  // question videos: DB key `12_aku-...mp4` -> local `[12] Aku ... .mp4`
  const m = path.basename(key).match(/^(\d+)_/);
  if (m) {
    const dir = path.join(SRC, bucket);
    if (existsSync(dir)) {
      const prefix = `[${m[1]}]`; // exact bracket form, avoids matching [1] vs [10]
      const hit = readdirSync(dir).find((f) => f.startsWith(prefix) && f.toLowerCase().endsWith(path.extname(key)));
      if (hit) return path.join(dir, hit);
    }
  }
  return null;
}

async function download(ref, dest) {
  const url = `${SUPABASE_URL}/storage/v1/object/public/${ref}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${res.status} downloading ${url}`);
  await pipeline(Readable.fromWeb(res.body), createWriteStream(dest));
  console.log(`    downloaded from new Supabase (${(statSync(dest).size / 1048576).toFixed(1)} MiB): ${ref}`);
}

// --- 3. Build the staging tree --------------------------------------------
mkdirSync(OUT, { recursive: true });
const manifest = [];
let videos = 0, copied = 0, skipped = 0;

for (const ref of refList) {
  const idx = ref.indexOf('/');
  const bucket = ref.slice(0, idx);
  const key = ref.slice(idx + 1);
  const dest = path.join(OUT, ref); // staging tree mirrors the exact upload tree (bucket/…/key)
  mkdirSync(path.dirname(dest), { recursive: true });

  const isVideo = dest.endsWith('.mp4');
  if (existsSync(dest) && !force) {
    skipped++;
    manifest.push({ ref, file: path.relative(ROOT, dest), bytes: statSync(dest).size });
    continue;
  }

  const src = findSource(bucket, key);
  if (src && isVideo && !skipTranscode) {
    process.stdout.write(`transcode 720p  ${path.basename(key)}  <-  ${path.basename(src)} ... `);
    const res = spawnSync(
      'ffmpeg',
      ['-y', '-nostdin', '-i', src, '-vf', 'scale=720:720:force_original_aspect_ratio=decrease:force_divisible_by=2', '-c:v', 'libx264',
       '-preset', 'veryfast', '-crf', '26', '-c:a', 'aac', '-b:a', '96k',
       '-movflags', '+faststart', dest, '-loglevel', 'error'],
      { stdio: ['ignore', 'ignore', 'inherit'] },
    );
    if (res.status !== 0) throw new Error(`ffmpeg failed for ${src}`);
    console.log(`${(statSync(dest).size / 1048576).toFixed(1)} MiB`);
    videos++;
  } else if (src) {
    copyFileSync(src, dest);
    console.log(`copy           ${ref}`);
    copied++;
  } else {
    await download(ref, dest);
    copied++;
  }
  manifest.push({ ref, file: path.relative(ROOT, dest), bytes: statSync(dest).size });
}

writeFileSync(path.join(OUT, 'manifest.json'), JSON.stringify(manifest, null, 2));

const total = manifest.reduce((sum, m) => sum + m.bytes, 0);
console.log(`\nDone: ${videos} transcoded, ${copied} copied/downloaded, ${skipped} skipped`);
console.log(`Staging folder: ${OUT}`);
console.log(`Total: ${(total / 1048576).toFixed(1)} MiB across ${manifest.length} files (manifest.json written)`);
