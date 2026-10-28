#!/usr/bin/env node
/**
 * Upload the downloaded storage assets from `assets-supabase/` to the NEW
 * project and point the matching `public.questions` rows at the new object
 * names.
 *
 * The downloaded question files are named like `[1] Aku ramah dan sopan.mp4`.
 * Supabase Storage object keys are safer with ASCII slugs, so they are uploaded
 * as `1_aku-ramah-dan-sopan.mp4`. The database is updated to the exact new
 * public URLs after every upload succeeds.
 *
 * Required environment variables (not needed for --dry-run):
 *   NEW_SUPABASE_URL
 *   NEW_SERVICE_ROLE_KEY   (legacy service_role JWT or sb_secret_... key)
 *
 * Usage:
 *   node supabase/migration/upload_local_assets.mjs --dry-run
 *   node supabase/migration/upload_local_assets.mjs
 *   node supabase/migration/upload_local_assets.mjs --skip-db
 *   node supabase/migration/upload_local_assets.mjs --skip-verify
 *   node supabase/migration/upload_local_assets.mjs --skip-existing
 *   node supabase/migration/upload_local_assets.mjs --no-sound
 *
 * Optional:
 *   ASSETS_DIR=assets-supabase
 *   CHALLENGE_ID=<uuid>   (only needed if more than one challenge has videos)
 *
 * `--skip-existing` skips any object that already exists in the bucket. Omit it
 * to force re-uploading every file.
 */

import { existsSync, promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, '../..');

const args = process.argv.slice(2);
const DRY_RUN = args.includes('--dry-run');
const SKIP_DB = args.includes('--skip-db');
const SKIP_VERIFY = args.includes('--skip-verify');
const SKIP_EXISTING = args.includes('--skip-existing');
const SKIP_SOUND = args.includes('--no-sound');

const assetsArg = getArgValue('--assets-dir') || process.env.ASSETS_DIR;
const assetsDir = findAssetsDir(assetsArg);
const baseUrl = (
  process.env.NEW_SUPABASE_URL ||
  process.env.SUPABASE_URL ||
  'https://gskxaynpuycgbitgewwk.supabase.co'
).replace(/\/+$/, '');
const serviceKey =
  process.env.NEW_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || '';
const explicitChallengeId = process.env.CHALLENGE_ID || getArgValue('--challenge-id') || '';

const MIME_TYPES = {
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  webp: 'image/webp',
  mp3: 'audio/mpeg',
  wav: 'audio/wav',
  m4a: 'audio/mp4',
  ogg: 'audio/ogg',
  mp4: 'video/mp4',
  webm: 'video/webm',
  mov: 'video/quicktime',
};

// The old database path for question 9 had a typo; the question text and the
// new slug use the correct spelling.
const TITLE_FIXES = new Map([['aku suka keadlian', 'Aku suka keadilan']]);

function getArgValue(name) {
  const prefix = `${name}=`;
  const match = args.find((arg) => arg.startsWith(prefix));
  return match ? match.slice(prefix.length) : '';
}

function findAssetsDir(explicit) {
  const candidates = explicit
    ? [explicit]
    : ['assets-supabase', 'asset-supabase', 'assets/supabase'];
  for (const candidate of candidates) {
    const resolved = path.resolve(PROJECT_ROOT, candidate);
    if (existsSync(resolved)) return resolved;
  }
  throw new Error(
    `Assets directory not found. Tried: ${candidates.join(', ')}. ` +
      'Use --assets-dir=<path> to point at the downloaded files.',
  );
}

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
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

function assertServiceKey(key) {
  if (key.startsWith('eyJ')) {
    try {
      const payload = JSON.parse(
        Buffer.from(key.split('.')[1], 'base64url').toString('utf8'),
      );
      if (payload.role !== 'service_role') {
        throw new Error(
          `NEW_SERVICE_ROLE_KEY is a "${payload.role}" key, not a service_role key.`,
        );
      }
    } catch (error) {
      if (error.message.includes('not a service_role key')) throw error;
      throw new Error(`Could not decode NEW_SERVICE_ROLE_KEY as a JWT: ${error.message}`);
    }
  } else if (!key.startsWith('sb_secret_')) {
    console.warn(
      'Warning: NEW_SERVICE_ROLE_KEY does not look like a legacy JWT or sb_secret_... key.',
    );
  }
}

function encodePath(objectPath) {
  return objectPath.split('/').map(encodeURIComponent).join('/');
}

function mimeFor(filePath) {
  const extension = filePath.split('.').pop()?.toLowerCase() || '';
  return MIME_TYPES[extension] || 'application/octet-stream';
}

function formatBytes(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KiB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MiB`;
}

function slugify(title) {
  return title
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/&/g, ' dan ')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-+/g, '-');
}

async function buildQuestionItems() {
  const questionDir = path.join(assetsDir, 'question');
  if (!existsSync(questionDir)) {
    throw new Error(`Question directory not found: ${questionDir}`);
  }

  const names = await fs.readdir(questionDir);
  const items = [];

  for (const name of names) {
    const match = name.match(/^\[(\d+)\]\s*(.+?)\.mp4$/i);
    if (!match) {
      if (!name.startsWith('.')) console.warn(`Skipping unrecognized question file: ${name}`);
      continue;
    }

    const number = Number(match[1]);
    const title = match[2].trim();
    const fixedTitle = TITLE_FIXES.get(title.toLowerCase()) || title;
    const slug = slugify(fixedTitle);
    if (!slug) {
      throw new Error(`Could not create a slug for question ${number}: ${name}`);
    }

    items.push({
      bucket: 'question',
      objectPath: `${number}_${slug}.mp4`,
      sourcePath: path.join(questionDir, name),
      mimeType: 'video/mp4',
      label: `question ${number}`,
    });
  }

  items.sort((a, b) => Number(a.objectPath.split('_')[0]) - Number(b.objectPath.split('_')[0]));

  const seen = new Set();
  for (const item of items) {
    const number = item.objectPath.split('_')[0];
    if (seen.has(number)) throw new Error(`Duplicate question number: ${number}`);
    seen.add(number);
  }

  return items;
}

function buildOptionItems() {
  const optionDir = path.join(assetsDir, 'option');
  if (!existsSync(optionDir)) {
    console.warn(`Option directory not found: ${optionDir}`);
    return [];
  }

  const definitions = [
    {
      objectPath: 'challenge-sopan-ramah/flat.png',
      candidates: ['flat.png'],
    },
    {
      objectPath: 'challenge-sopan-ramah/sad.png',
      candidates: ['sad.png'],
    },
    {
      // The old database uses smile.png; the downloaded file is senyum.png.
      objectPath: 'challenge-sopan-ramah/smile.png',
      candidates: ['smile.png', 'senyum.png'],
    },
  ];

  const items = [];
  for (const definition of definitions) {
    const sourceName = definition.candidates.find((name) =>
      existsSync(path.join(optionDir, name)),
    );
    if (!sourceName) {
      console.warn(
        `Missing option image for ${definition.objectPath} ` +
          `(looked for: ${definition.candidates.join(', ')})`,
      );
      continue;
    }

    items.push({
      bucket: 'option',
      objectPath: definition.objectPath,
      sourcePath: path.join(optionDir, sourceName),
      mimeType: 'image/png',
      label: `option ${sourceName}`,
    });
  }

  return items;
}

function buildExtraItems() {
  const items = [];

  const extras = [
    {
      bucket: 'challenges',
      objectPath: 'challenges-1.png',
      sourcePath: path.join(assetsDir, 'challenges', 'challenges-1.png'),
      mimeType: 'image/png',
      label: 'challenge image',
    },
    {
      bucket: 'challenges',
      objectPath: 'logo.png',
      sourcePath: path.join(assetsDir, 'challenges', 'logo.png'),
      mimeType: 'image/png',
      label: 'app logo',
    },
    {
      bucket: 'sound-music-vocal',
      objectPath: 'music/funny-cartoon-kids-background-music-350273.mp3',
      sourcePath: path.join(
        assetsDir,
        'sound-music-vocal',
        'music',
        'funny-cartoon-kids-background-music-350273.mp3',
      ),
      mimeType: 'audio/mpeg',
      label: 'background music',
    },
    {
      bucket: 'sound-music-vocal',
      objectPath: 'soundeffect/click-app.mp3',
      sourcePath: path.join(
        assetsDir,
        'sound-music-vocal',
        'soundeffect',
        'click-app.mp3',
      ),
      mimeType: 'audio/mpeg',
      label: 'click sound',
    },
  ];

  for (const item of extras) {
    if (SKIP_SOUND && item.bucket === 'sound-music-vocal') continue;
    if (existsSync(item.sourcePath)) {
      items.push(item);
    } else if (item.bucket === 'challenges' && item.objectPath === 'challenges-1.png') {
      console.warn(`Missing challenge image: ${item.sourcePath}`);
    } else if (item.bucket === 'sound-music-vocal') {
      console.warn(`Missing sound file: ${item.sourcePath}`);
    }
  }

  return items;
}

async function objectExists(bucket, objectPath) {
  const response = await fetch(
    `${baseUrl}/storage/v1/object/${encodeURIComponent(bucket)}/${encodePath(objectPath)}`,
    {
      method: 'HEAD',
      headers: authHeaders(serviceKey),
      signal: AbortSignal.timeout(30 * 1000),
    },
  );

  return response.ok;
}

async function uploadObject(item) {
  const stat = await fs.stat(item.sourcePath);
  if (SKIP_EXISTING && (await objectExists(item.bucket, item.objectPath))) {
    return { bytes: stat.size, skipped: true };
  }

  const body = await fs.readFile(item.sourcePath);
  const response = await fetch(
    `${baseUrl}/storage/v1/object/${encodeURIComponent(item.bucket)}/${encodePath(item.objectPath)}`,
    {
      method: 'POST',
      headers: {
        ...authHeaders(serviceKey),
        'Content-Type': item.mimeType,
        'Cache-Control': 'public, max-age=3600',
        'x-upsert': 'true',
      },
      body,
      signal: AbortSignal.timeout(15 * 60 * 1000),
    },
  );

  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error(
      `Upload failed for ${item.bucket}/${item.objectPath}: ${response.status} ${text.slice(0, 500)}`,
    );
  }

  return { bytes: stat.size, skipped: false };
}

async function restApi(pathname, options = {}) {
  const response = await fetch(`${baseUrl}/rest/v1${pathname}`, {
    ...options,
    headers: {
      ...authHeaders(serviceKey),
      ...(options.headers || {}),
    },
    signal: AbortSignal.timeout(60 * 1000),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error(
      `${options.method || 'GET'} /rest/v1${pathname} -> ${response.status} ${text.slice(0, 500)}`,
    );
  }

  if (response.status === 204) return null;
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

async function loadImageQuestions() {
  return restApi(
    '/questions?select=id,challenge_id,question_number,image_url' +
      '&image_url=not.is.null&order=challenge_id.asc,question_number.asc',
  );
}

function pickChallenge(rows, questionNumbers) {
  const groups = new Map();
  for (const row of rows) {
    if (!row.image_url?.includes('/storage/v1/object/public/question/')) continue;
    if (!groups.has(row.challenge_id)) groups.set(row.challenge_id, []);
    groups.get(row.challenge_id).push(row);
  }

  if (explicitChallengeId) {
    const rowsForChallenge = groups.get(explicitChallengeId) || [];
    if (rowsForChallenge.length === 0) {
      throw new Error(`No video questions found for CHALLENGE_ID=${explicitChallengeId}`);
    }
    return [explicitChallengeId, rowsForChallenge];
  }

  const candidates = [...groups.entries()].filter(([, group]) => {
    const numbers = new Set(group.map((row) => Number(row.question_number)));
    return [...questionNumbers].every((number) => numbers.has(number));
  });

  if (candidates.length === 1) return candidates[0];

  if (candidates.length === 0) {
    throw new Error(
      'No challenge has video questions for all 15 downloaded files. ' +
        'Set CHALLENGE_ID to choose the target challenge.',
    );
  }

  const details = candidates
    .map(([id, group]) => `${id} (${group.length} image question(s))`)
    .join(', ');
  throw new Error(
    `More than one challenge matches the downloaded question numbers: ${details}. ` +
      'Set CHALLENGE_ID to choose one.',
  );
}

async function updateDatabase(questionItems) {
  const rows = await loadImageQuestions();
  const numbers = questionItems.map((item) => Number(item.objectPath.split('_')[0]));
  const [challengeId, challengeRows] = pickChallenge(rows, numbers);
  const byNumber = new Map(
    challengeRows.map((row) => [Number(row.question_number), row]),
  );

  console.log(`\n==> Updating public.questions (challenge ${challengeId})`);
  let updated = 0;
  for (const item of questionItems) {
    const number = Number(item.objectPath.split('_')[0]);
    const row = byNumber.get(number);
    if (!row) {
      console.warn(`  No question row found for number ${number}; skipped.`);
      continue;
    }

    const newUrl = `${baseUrl}/storage/v1/object/public/question/${item.objectPath}`;
    if (row.image_url === newUrl) {
      console.log(`  q${number}: already up to date`);
      continue;
    }

    await restApi(`/questions?id=eq.${encodeURIComponent(row.id)}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify({ image_url: newUrl }),
    });

    updated += 1;
    console.log(`  q${number}: ${row.image_url}`);
    console.log(`       -> ${newUrl}`);
  }

  const after = await loadImageQuestions();
  const afterRows = after.filter((row) => row.challenge_id === challengeId);
  const afterByNumber = new Map(
    afterRows.map((row) => [Number(row.question_number), row]),
  );
  const missing = questionItems.filter((item) => {
    const number = Number(item.objectPath.split('_')[0]);
    const expected = `${baseUrl}/storage/v1/object/public/question/${item.objectPath}`;
    return afterByNumber.get(number)?.image_url !== expected;
  });

  if (missing.length) {
    throw new Error(
      `Database verification failed for question(s): ${missing
        .map((item) => item.objectPath)
        .join(', ')}`,
    );
  }

  console.log(`  rows updated: ${updated}`);
  console.log('  database verification: OK');
}

async function verifyPublicUrl(bucket, objectPath) {
  const url = `${baseUrl}/storage/v1/object/public/${bucket}/${encodePath(objectPath)}`;
  let response = await fetch(url, {
    method: 'HEAD',
    signal: AbortSignal.timeout(30 * 1000),
  });

  if (response.status === 405 || response.status === 501) {
    response = await fetch(url, {
      headers: { Range: 'bytes=0-0' },
      signal: AbortSignal.timeout(30 * 1000),
    });
  }

  return { url, status: response.status, ok: response.ok };
}

async function verifyUploads(items) {
  console.log('\n==> Verifying public URLs');
  const failures = [];
  for (const item of items) {
    const result = await verifyPublicUrl(item.bucket, item.objectPath);
    console.log(`  ${result.status} ${item.bucket}/${item.objectPath}`);
    if (!result.ok) failures.push(result);
  }

  if (failures.length) {
    throw new Error(
      `Public URL verification failed for ${failures.length} object(s): ` +
        failures.map((failure) => failure.url).join(', '),
    );
  }
}

async function main() {
  console.log(`Assets directory: ${assetsDir}`);
  console.log(`New project: ${baseUrl}`);
  if (SKIP_SOUND) console.log('Sound/music: intentionally skipped (--no-sound).');

  const questionItems = await buildQuestionItems();
  const optionItems = buildOptionItems();
  const extraItems = buildExtraItems();
  const items = [...questionItems, ...optionItems, ...extraItems];

  const expectedNumbers = Array.from({ length: 15 }, (_, index) => index + 1);
  const foundNumbers = new Set(
    questionItems.map((item) => Number(item.objectPath.split('_')[0])),
  );
  const missingNumbers = expectedNumbers.filter((number) => !foundNumbers.has(number));
  if (missingNumbers.length) {
    console.warn(`Missing question video(s) for number(s): ${missingNumbers.join(', ')}`);
  }

  console.log('\n==> Upload plan');
  let totalBytes = 0;
  for (const item of items) {
    const stat = await fs.stat(item.sourcePath);
    totalBytes += stat.size;
    console.log(
      `  ${item.bucket}/${item.objectPath}  (${formatBytes(stat.size)})  <- ${path.relative(
        PROJECT_ROOT,
        item.sourcePath,
      )}`,
    );
  }
  console.log(`  total: ${items.length} object(s), ${formatBytes(totalBytes)}`);

  if (DRY_RUN) {
    console.log('\nDRY RUN: no uploads and no database changes were made.');
    return;
  }

  requiredEnv('NEW_SUPABASE_URL');
  requiredEnv('NEW_SERVICE_ROLE_KEY');
  assertServiceKey(serviceKey);

  console.log('\n==> Uploading');
  let uploaded = 0;
  let skipped = 0;
  for (const [index, item] of items.entries()) {
    process.stdout.write(
      `  [${index + 1}/${items.length}] ${item.bucket}/${item.objectPath} ... `,
    );
    const result = await uploadObject(item);
    if (result.skipped) {
      skipped += 1;
      console.log(`SKIP (already exists, ${formatBytes(result.bytes)})`);
    } else {
      uploaded += 1;
      console.log(`OK (${formatBytes(result.bytes)})`);
    }
  }

  if (!SKIP_DB) {
    await updateDatabase(questionItems);
  }

  if (!SKIP_VERIFY) {
    await verifyUploads(items);
  }

  console.log('\n==> Summary');
  console.log(`  uploaded: ${uploaded}/${items.length}`);
  if (skipped) console.log(`  skipped (already present): ${skipped}`);
  if (!SKIP_DB) console.log('  database: updated and verified');
  console.log('  done');
}

main().catch((error) => {
  console.error(`\nFatal error: ${error.message}`);
  process.exitCode = 1;
});
