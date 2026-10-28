#!/usr/bin/env node
/**
 * upload_r2.mjs
 *
 * Uploads everything in `assets-r2/` (built by prepare_r2_assets.mjs) to a
 * Cloudflare R2 bucket via the S3-compatible API, then verifies every object
 * through the public custom domain.
 *
 * Env (put in a temp file or shell):
 *   R2_ACCESS_KEY_ID       R2 API token access key
 *   R2_SECRET_ACCESS_KEY   R2 API token secret
 *   R2_S3_ENDPOINT         https://<accountid>.r2.cloudflarestorage.com
 *   R2_BUCKET              bucket name (default: media)
 *   R2_PUBLIC_BASE         public base URL, e.g. https://media.scl-vguard.com
 *   SUPABASE_SERVICE_KEY   optional — only needed with --db to run the URL
 *                          rewrite directly (otherwise the script writes
 *                          rewrite_urls_for_r2.sql for the SQL editor)
 *
 * Flags:
 *   --skip-existing   HEAD each object first; skip ones already uploaded
 *   --skip-verify     skip the public-domain verification pass
 *   --db              after a successful upload+verify, run the DB URL rewrite
 *                     via the Supabase REST API (needs SUPABASE_SERVICE_KEY)
 *   --dry-run         print the plan, upload nothing
 */
import { createHash, createHmac } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const MANIFEST = path.join(ROOT, 'assets-r2', 'manifest.json');
const SQL_OUT = path.join(ROOT, 'supabase', 'migration', 'rewrite_urls_for_r2.sql');

const skipExisting = process.argv.includes('--skip-existing');
const skipVerify = process.argv.includes('--skip-verify');
const runDb = process.argv.includes('--db');
const dryRun = process.argv.includes('--dry-run');

for (const name of ['R2_ACCESS_KEY_ID', 'R2_SECRET_ACCESS_KEY', 'R2_S3_ENDPOINT']) {
  if (!process.env[name]) {
    console.error(`Missing env ${name}. Set R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY / R2_S3_ENDPOINT (and R2_BUCKET, R2_PUBLIC_BASE).`);
    process.exit(1);
  }
}
const ACCESS_KEY = process.env.R2_ACCESS_KEY_ID;
const SECRET_KEY = process.env.R2_SECRET_ACCESS_KEY;
const ENDPOINT = process.env.R2_S3_ENDPOINT.replace(/\/$/, '');
const BUCKET = process.env.R2_BUCKET || 'media';
const PUBLIC_BASE = (process.env.R2_PUBLIC_BASE || 'https://media.scl-vguard.com').replace(/\/$/, '');
const SUPABASE_URL = 'https://gskxaynpuycgbitgewwk.supabase.co';
const OLD_PREFIX = `${SUPABASE_URL}/storage/v1/object/public/`;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || '';

if (!existsSync(MANIFEST)) {
  console.error('assets-r2/manifest.json not found — run prepare_r2_assets.mjs first.');
  process.exit(1);
}
const manifest = JSON.parse(readFileSync(MANIFEST, 'utf8'));
const totalMiB = manifest.reduce((s, m) => s + m.bytes, 0) / 1048576;
console.log(`Bucket: ${BUCKET}   Endpoint: ${ENDPOINT}   Public: ${PUBLIC_BASE}`);
console.log(`Files to upload: ${manifest.length} (${totalMiB.toFixed(1)} MiB total)\n`);

// ---------------------------------------------------------------------------
// Minimal AWS SigV4 signer for R2 (region "auto", service "s3")
// ---------------------------------------------------------------------------
const sha256hex = (data) => createHash('sha256').update(data).digest('hex');
const hmac = (key, data) => createHmac('sha256', key).update(data).digest();

function sigv4Headers(method, bucket, key, extraHeaders = {}, payloadHash) {
  const host = new URL(ENDPOINT).host;
  const now = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const amzDate = `${now.getUTCFullYear()}${pad(now.getUTCMonth() + 1)}${pad(now.getUTCDate())}T${pad(now.getUTCHours())}${pad(now.getUTCMinutes())}${pad(now.getUTCSeconds())}Z`;
  const dateStamp = amzDate.slice(0, 8);

  const canonicalUri = `/${bucket}/${key.split('/').map(encodeURIComponent).join('/')}`;
  const headers = { host, 'x-amz-content-sha256': payloadHash, 'x-amz-date': amzDate, ...extraHeaders };
  const sortedNames = Object.keys(headers).map((k) => k.toLowerCase()).sort();
  const canonicalHeaders = sortedNames.map((n) => {
    const value = headers[Object.keys(headers).find((k) => k.toLowerCase() === n)];
    return `${n}:${String(value).trim()}\n`;
  }).join('');
  const signedHeaders = sortedNames.join(';');

  const canonicalRequest = [method, canonicalUri, '', canonicalHeaders, signedHeaders, payloadHash].join('\n');
  const scope = `${dateStamp}/auto/s3/aws4_request`;
  const stringToSign = ['AWS4-HMAC-SHA256', amzDate, scope, sha256hex(canonicalRequest)].join('\n');

  const kDate = hmac(`AWS4${SECRET_KEY}`, dateStamp);
  const kRegion = hmac(kDate, 'auto');
  const kService = hmac(kRegion, 's3');
  const kSigning = hmac(kService, 'aws4_request');
  const signature = createHmac('sha256', kSigning).update(stringToSign).digest('hex');

  return {
    ...headers,
    Authorization: `AWS4-HMAC-SHA256 Credential=${ACCESS_KEY}/${scope}, SignedHeaders=${signedHeaders}, Signature=${signature}`,
  };
}

const contentTypeFor = (file) =>
  file.endsWith('.mp4') ? 'video/mp4' : file.endsWith('.png') ? 'image/png' : 'application/octet-stream';

async function s3Request(method, key, body) {
  const url = `${ENDPOINT}/${BUCKET}/${key.split('/').map(encodeURIComponent).join('/')}`;
  const payloadHash = body ? sha256hex(body) : sha256hex('');
  const extra = {};
  if (body) {
    extra['content-type'] = contentTypeFor(key);
    extra['cache-control'] = 'public, max-age=31536000, immutable';
  }
  const res = await fetch(url, { method, headers: sigv4Headers(method, BUCKET, key, extra, payloadHash), body });
  return res;
}

// ---------------------------------------------------------------------------
// 1. Upload pass
// ---------------------------------------------------------------------------
let uploaded = 0, skipped = 0, failed = 0;
for (const item of manifest) {
  const { ref, file, bytes } = item;
  if (skipExisting) {
    const head = await s3Request('HEAD', ref);
    if (head.status === 200) {
      const remote = Number(head.headers.get('content-length'));
      if (remote === bytes) {
        console.log(`skip (already uploaded)  ${ref}`);
        skipped++;
        continue;
      }
      console.log(`re-upload (size differs: remote ${remote} vs local ${bytes})  ${ref}`);
    } else if (head.status !== 404) {
      console.log(`HEAD ${ref} -> ${head.status}; attempting upload`);
    }
  }
  if (dryRun) {
    console.log(`[dry-run] would upload  ${ref}  (${(bytes / 1048576).toFixed(1)} MiB)`);
    continue;
  }
  const body = readFileSync(path.join(ROOT, file));
  const res = await s3Request('PUT', ref, body);
  if (res.ok) {
    console.log(`uploaded                 ${ref}  (${(bytes / 1048576).toFixed(1)} MiB)`);
    uploaded++;
  } else {
    const text = await res.text().catch(() => '');
    console.error(`FAILED ${res.status}  ${ref}\n${text.slice(0, 300)}`);
    failed++;
  }
}

if (dryRun) {
  console.log(`\nDry run complete — ${manifest.length} objects would be uploaded.`);
  process.exit(0);
}
console.log(`\nUpload pass: ${uploaded} uploaded, ${skipped} skipped, ${failed} failed`);
if (failed > 0) process.exit(1);

// ---------------------------------------------------------------------------
// 2. Verification pass through the public domain (what the app actually uses)
// ---------------------------------------------------------------------------
if (!skipVerify) {
  console.log('\n==> Verifying public URLs');
  let ok = 0, bad = 0, corsSeen = null;
  for (const item of manifest) {
    const { ref, bytes } = item;
    const head = await fetch(`${PUBLIC_BASE}/${ref}`, { method: 'HEAD' });
    const sizeOk = Number(head.headers.get('content-length')) === bytes;
    const range = await fetch(`${PUBLIC_BASE}/${ref}`, { headers: { Range: 'bytes=0-0' } });
    const rangeOk = range.status === 206 && (range.headers.get('content-range') || '').startsWith('bytes 0-0/');
    if (!corsSeen && head.headers.get('access-control-allow-origin')) corsSeen = head.headers.get('access-control-allow-origin');
    if (head.status === 200 && sizeOk && rangeOk) {
      console.log(`  200 + 206 OK   ${ref}`);
      ok++;
    } else {
      console.error(`  PROBLEM       ${ref}  head=${head.status} size=${head.headers.get('content-length')}/${bytes} range=${range.status}`);
      bad++;
    }
  }
  const originProbe = await fetch(`${PUBLIC_BASE}/${manifest[0].ref}`, { headers: { Origin: 'https://scl-vguard.com' } });
  const acao = originProbe.headers.get('access-control-allow-origin');
  console.log(`\nVerification: ${ok} OK, ${bad} problem`);
  console.log(`CORS (Origin: https://scl-vguard.com) -> ${acao ? `access-control-allow-origin: ${acao}` : 'NO CORS HEADER (check the bucket CORS policy)'}`);
  if (bad > 0) process.exit(1);
}

// ---------------------------------------------------------------------------
// 3. DB URL rewrite
// ---------------------------------------------------------------------------
const rewriteSql = `-- Rewrite storage URLs from Supabase Storage to the R2 custom domain.
-- Run in Supabase SQL editor (or via upload_r2.mjs --db with a service key).
UPDATE public.questions
  SET image_url = replace(image_url, '${OLD_PREFIX}', '${PUBLIC_BASE}/')
  WHERE image_url LIKE '%${OLD_PREFIX}%';
UPDATE public.options
  SET image_url = replace(image_url, '${OLD_PREFIX}', '${PUBLIC_BASE}/')
  WHERE image_url LIKE '%${OLD_PREFIX}%';
UPDATE public.challenges
  SET image_url = replace(image_url, '${OLD_PREFIX}', '${PUBLIC_BASE}/')
  WHERE image_url LIKE '%${OLD_PREFIX}%';
`;
writeFileSync(SQL_OUT, rewriteSql);
console.log(`\nURL-rewrite SQL written to supabase/migration/rewrite_urls_for_r2.sql`);

if (runDb) {
  if (!SERVICE_KEY) {
    console.error('--db requires SUPABASE_SERVICE_KEY in env. Run the SQL file manually instead.');
    process.exit(1);
  }
  const headers = { apikey: SERVICE_KEY, Authorization: `Bearer ${SERVICE_KEY}`, 'Content-Type': 'application/json', Prefer: 'return=representation' };
  const distinctRefs = [...new Set(manifest.map((m) => m.ref))];
  for (const ref of distinctRefs) {
    const table = ref.split('/')[0];
    const oldValue = `${OLD_PREFIX}${ref}`;
    const newValue = `${PUBLIC_BASE}/${ref}`;
    for (const t of ['questions', 'options', 'challenges']) {
      const res = await fetch(`${SUPABASE_URL}/rest/v1/${t}?image_url=eq.${encodeURIComponent(oldValue)}`, {
        method: 'PATCH', headers, body: JSON.stringify({ image_url: newValue }),
      });
      const rows = await res.json().catch(() => []);
      if (Array.isArray(rows) && rows.length > 0) console.log(`  ${t}: ${rows.length} row(s) -> ${newValue}`);
    }
  }
  console.log('DB rewrite done.');
} else {
  console.log('Next: run the SQL file in the Supabase SQL editor, or re-run with --db and SUPABASE_SERVICE_KEY set.');
}
