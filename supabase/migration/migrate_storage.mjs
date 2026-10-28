#!/usr/bin/env node
/**
 * Copy Supabase Storage buckets and objects from the OLD project to the NEW one.
 *
 * Required environment variables:
 *   OLD_SUPABASE_URL
 *   OLD_SERVICE_ROLE_KEY   (legacy service_role JWT or sb_secret_... key)
 *   NEW_SUPABASE_URL
 *   NEW_SERVICE_ROLE_KEY
 *
 * Optional:
 *   BUCKETS=challenges,option,question,sound-music-vocal
 *   CONCURRENCY=4
 *   DRY_RUN=1
 *
 * The script only reads from the old project. It creates missing buckets in the
 * new project and uploads files with upsert enabled.
 */

const OLD_URL = requiredEnv('OLD_SUPABASE_URL').replace(/\/+$/, '');
const OLD_KEY = requiredEnv('OLD_SERVICE_ROLE_KEY');
const NEW_URL = requiredEnv('NEW_SUPABASE_URL').replace(/\/+$/, '');
const NEW_KEY = requiredEnv('NEW_SERVICE_ROLE_KEY');

const BUCKETS = (process.env.BUCKETS || '')
  .split(',')
  .map((value) => value.trim())
  .filter(Boolean);

const CONCURRENCY = Math.max(1, Number(process.env.CONCURRENCY || 4));
const DRY_RUN = process.env.DRY_RUN === '1';

const MIME_TYPES = {
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  gif: 'image/gif',
  webp: 'image/webp',
  svg: 'image/svg+xml',
  bmp: 'image/bmp',
  ico: 'image/x-icon',
  mp3: 'audio/mpeg',
  wav: 'audio/wav',
  m4a: 'audio/mp4',
  ogg: 'audio/ogg',
  mp4: 'video/mp4',
  webm: 'video/webm',
  mov: 'video/quicktime',
  avi: 'video/x-msvideo',
  pdf: 'application/pdf',
  json: 'application/json',
  txt: 'text/plain',
};

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    console.error(`Missing required environment variable: ${name}`);
    process.exit(1);
  }
  return value;
}

function authHeaders(key) {
  const headers = { apikey: key };
  // Legacy keys are JWTs. New sb_secret_... keys authenticate via apikey only.
  if (key.startsWith('eyJ')) {
    headers.Authorization = `Bearer ${key}`;
  }
  return headers;
}

async function storageApi(baseUrl, key, path, options = {}) {
  const response = await fetch(`${baseUrl}/storage/v1${path}`, {
    ...options,
    headers: {
      ...authHeaders(key),
      ...(options.headers || {}),
    },
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(
      `${options.method || 'GET'} ${path} -> ${response.status} ${body.slice(0, 500)}`,
    );
  }

  return response;
}

function encodePath(path) {
  return path.split('/').map(encodeURIComponent).join('/');
}

function mimeFor(path) {
  const extension = path.split('.').pop()?.toLowerCase() || '';
  return MIME_TYPES[extension] || 'application/octet-stream';
}

async function listBuckets() {
  const response = await storageApi(OLD_URL, OLD_KEY, '/bucket');
  return response.json();
}

async function listNewBucketNames() {
  const response = await storageApi(NEW_URL, NEW_KEY, '/bucket');
  const buckets = await response.json();
  return new Set(buckets.map((bucket) => bucket.name));
}

async function createBucket(bucket) {
  await storageApi(NEW_URL, NEW_KEY, '/bucket', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      id: bucket.name,
      name: bucket.name,
      public: Boolean(bucket.public),
      file_size_limit: bucket.file_size_limit ?? null,
      allowed_mime_types: bucket.allowed_mime_types ?? null,
    }),
  });
}

/**
 * Recursively list every file in a bucket. The Storage list endpoint paginates
 * at 1000 entries and returns folders with `metadata: null`.
 */
async function listFiles(bucket, prefix = '') {
  const files = [];
  const limit = 1000;
  let offset = 0;

  while (true) {
    const response = await storageApi(OLD_URL, OLD_KEY, `/object/list/${encodeURIComponent(bucket)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        prefix,
        limit,
        offset,
        sortBy: { column: 'name', order: 'asc' },
      }),
    });

    const page = await response.json();
    if (page.length === 0) break;

    for (const entry of page) {
      const path = prefix ? `${prefix}/${entry.name}` : entry.name;
      const isFolder = !entry.id || !entry.metadata;

      if (isFolder) {
        files.push(...(await listFiles(bucket, path)));
      } else {
        files.push({
          path,
          mimeType: entry.metadata?.mimetype || mimeFor(path),
          cacheControl: entry.metadata?.cacheControl || 'max-age=3600',
          size: Number(entry.metadata?.size || 0),
        });
      }
    }

    if (page.length < limit) break;
    offset += limit;
  }

  return files;
}

async function mapLimit(items, limit, fn) {
  const results = new Array(items.length);
  let nextIndex = 0;

  async function worker() {
    while (true) {
      const index = nextIndex++;
      if (index >= items.length) return;
      results[index] = await fn(items[index], index);
    }
  }

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
}

async function migrateFile(bucket, file) {
  if (DRY_RUN) {
    return { path: file.path, skipped: true };
  }

  const downloadResponse = await storageApi(
    OLD_URL,
    OLD_KEY,
    `/object/${encodeURIComponent(bucket)}/${encodePath(file.path)}`,
  );
  const body = Buffer.from(await downloadResponse.arrayBuffer());

  await storageApi(
    NEW_URL,
    NEW_KEY,
    `/object/${encodeURIComponent(bucket)}/${encodePath(file.path)}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': file.mimeType,
        'Cache-Control': file.cacheControl,
        'x-upsert': 'true',
      },
      body,
    },
  );

  return { path: file.path };
}

function formatBytes(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KiB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MiB`;
}

async function main() {
  console.log(`Old project: ${OLD_URL}`);
  console.log(`New project: ${NEW_URL}`);
  if (DRY_RUN) console.log('DRY RUN: no files will be uploaded.\n');

  const allBuckets = await listBuckets();
  const selected = BUCKETS.length
    ? allBuckets.filter((bucket) => BUCKETS.includes(bucket.name))
    : allBuckets;

  const missing = BUCKETS.filter((name) => !allBuckets.some((bucket) => bucket.name === name));
  if (missing.length) {
    console.warn(`Warning: buckets not found in old project: ${missing.join(', ')}`);
  }

  if (selected.length === 0) {
    console.log('No buckets to migrate.');
    return;
  }

  const newBucketNames = DRY_RUN ? new Set() : await listNewBucketNames();
  let totalFiles = 0;
  let uploadedFiles = 0;
  const failures = [];

  for (const bucket of selected) {
    console.log(`\n==> Bucket: ${bucket.name} (${bucket.public ? 'public' : 'private'})`);

    if (!DRY_RUN && !newBucketNames.has(bucket.name)) {
      console.log('    creating bucket in new project...');
      await createBucket(bucket);
      newBucketNames.add(bucket.name);
    }

    const files = await listFiles(bucket.name);
    const bytes = files.reduce((sum, file) => sum + file.size, 0);
    totalFiles += files.length;

    console.log(`    ${files.length} file(s), ${formatBytes(bytes)}`);

    if (files.length === 0) continue;

    let done = 0;
    await mapLimit(files, CONCURRENCY, async (file) => {
      try {
        await migrateFile(bucket.name, file);
        if (!DRY_RUN) uploadedFiles += 1;
      } catch (error) {
        failures.push({ bucket: bucket.name, path: file.path, error: error.message });
        console.error(`    FAILED ${file.path}: ${error.message}`);
      } finally {
        done += 1;
        if (done % 25 === 0 || done === files.length) {
          console.log(`    progress: ${done}/${files.length}`);
        }
      }
    });
  }

  console.log('\n==> Summary');
  console.log(`    files found: ${totalFiles}`);
  if (DRY_RUN) {
    console.log('    dry run: nothing uploaded');
  } else {
    console.log(`    files uploaded: ${uploadedFiles}`);
    console.log(`    failures: ${failures.length}`);
  }

  if (failures.length) {
    console.log('\nFailed files:');
    for (const failure of failures) {
      console.log(`  - ${failure.bucket}/${failure.path}: ${failure.error}`);
    }
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(`Fatal error: ${error.message}`);
  process.exitCode = 1;
});
