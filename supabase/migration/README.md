# Supabase migration kit (`child_games`)

Copy the existing Supabase project into a **new** project under another account,
without modifying or deleting the old one.

> **The old project is only read.** `export_old.sh` runs `pg_dump`, which only
> issues `SELECT`-style reads. No `DROP`, `DELETE`, `UPDATE`, or `ALTER` is sent
> to the old database. Keep the old project online until the new one is verified.

## Media is now served from Cloudflare R2 (2026-10-28)

With ~500 expected users, streaming the ~439 MB of original videos through
Supabase would exhaust the Free plan's 10 GB monthly egress after ~11 users, so
all media was moved to a Cloudflare R2 bucket (`media`) exposed at
`https://media.scl-vguard.com` (custom domain, zone `scl-vguard.com`, free
plan). R2 has **no egress fees**, so user count no longer matters.

- Question videos were re-encoded to 720p (H.264 CRF 26, AAC 96k, faststart):
  439 MB → **14.4 MB total** (`prepare_r2_assets.mjs`, originals untouched in
  `assets-supabase/`).
- Object keys mirror the Supabase paths, so the DB switch was a pure prefix
  swap: `https://gskx…supabase.co/storage/v1/object/public/` →
  `https://media.scl-vguard.com/` (`upload_r2.mjs --db`, SQL kept in
  `rewrite_urls_for_r2.sql`).
- All 20 objects verified: `200` + range streaming `206` + CORS
  `access-control-allow-origin: *`.
- Supabase is still used for the **database** (tiny JSON traffic only). Its
  storage files remain online untouched as a fallback and can be deleted later.

## What gets copied

| What | Where it comes from |
| --- | --- |
| Tables, columns, constraints, indexes, functions, triggers, sequences | `dump/schema.sql` |
| RLS policies on the `public` schema | `dump/schema.sql` |
| Rows: `challenges`, `questions`, `options`, `users`, `user_answers`, `rei_accumulate`, `games`, ... | `dump/data.sql` (`public` schema only) |
| Auth users (`auth.users`, `auth.identities`) | **not copied by default** — see the optional section at the end |
| Storage bucket metadata (`storage.buckets`, `storage.objects`) | created by `migrate_storage.mjs` |
| Storage files (logo, question images, option images, music) | `migrate_storage.mjs` or `upload_local_assets.mjs` |
| Custom RLS policies on `auth` / `storage` | **not included** — recreate manually if you added them |
| Edge functions | **not included** — deploy separately if used |

The old project's `challenges` rows are in `dump/data.sql`. After restore you can
verify with `select count(*) from public.challenges;`.

## Can I do this with only the Supabase CLI?

Yes for the **dump**. The CLI does not have a one-command project clone, and it
cannot replay a full `pg_dump` data file:

- `supabase db dump` — the CLI export path used by `export_old.sh`.
- `supabase db push` — applies files in `supabase/migrations/`; it does **not**
  copy rows from a dump.
- `supabase db pull` — pulls the remote schema into migrations; no data.
- `supabase db query -f data.sql` — runs SQL, but a `pg_dump --use-copy` data
  file contains `COPY ... FROM stdin` and `\.`, which are psql protocol, not
  SQL. It fails with `syntax error at or near "1"`.
- `supabase storage cp` — copies through the Storage API; it cannot bypass the
  old project's `402` restriction.

The reliable CLI workflow is therefore **CLI for dump + `psql` for restore**:

```bash
# Export (the same commands export_old.sh runs)
npx supabase@latest db dump --db-url "$OLD_DB_URL" \
  -f supabase/migration/dump/roles.sql --role-only
npx supabase@latest db dump --db-url "$OLD_DB_URL" \
  -f supabase/migration/dump/schema.sql
npx supabase@latest db dump --db-url "$OLD_DB_URL" \
  -f supabase/migration/dump/data.sql \
  --use-copy --data-only --schema public

# Restore
psql "$NEW_DB_URL" --single-transaction --variable ON_ERROR_STOP=1 \
  --file supabase/migration/dump/roles.sql \
  --file supabase/migration/dump/schema.sql \
  --command 'SET session_replication_role = replica' \
  --file supabase/migration/dump/data.sql
```

`export_old.sh` and `restore_new.sh` are thin wrappers around those commands.
If `psql` is missing, `restore_new.sh` runs the same command in a `postgres:17`
Docker container.

## 0. Create the new project

Create the new project first. Then note:

- **Project URL** (`https://<new-ref>.supabase.co`)
- **anon / publishable key**
- **service_role / secret key** (only needed for storage copy — never put it in the Flutter app)
- **Database password** (**Database → Settings → Reset database password**)

Use the **Session pooler** connection string if your network doesn't support IPv6:

```text
postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres
```

Direct connection:

```text
postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres
```

If the password contains special characters, percent-encode it (`@` → `%40`, etc.).

> Both projects can be in the same region to reduce latency during the copy.
> The new project must be empty. `restore_new.sh` is not idempotent.

## 1. Export the old project (read-only)

```bash
export OLD_DB_URL='postgresql://postgres.jokvxdrxswytjjhxuhvk:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres'

./supabase/migration/export_old.sh
```

This writes `supabase/migration/dump/roles.sql`, `schema.sql`, `data.sql`, and
`SHA256SUMS`. The dump contains personal data — it is git-ignored, keep it private.

If the Session pooler drops a large `COPY` (for example `user_answers`), dump the
data with the direct database host from a host-network container:

```bash
docker run --rm --network host \
  --user "$(id -u):$(id -g)" \
  -e PGPASSWORD='<old-db-password>' \
  -v "$PWD/supabase/migration/dump:/dump" \
  postgres:17 pg_dump \
  'postgresql://postgres@db.jokvxdrxswytjjhxuhvk.supabase.co:5432/postgres?sslmode=require' \
  --data-only --schema public --no-owner --no-privileges \
  -f /dump/data.sql
```

The direct host is IPv6-only; `--network host` lets the container use the host's
IPv6 route. This bypasses the pooler's long-connection limits.

## 2. Restore into the new project

```bash
export NEW_DB_URL='postgresql://postgres.<new-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres'

./supabase/migration/restore_new.sh
```

The script runs everything in one transaction and sets
`session_replication_role = replica` while loading rows, so triggers don't fire
during the copy. If anything fails, the whole restore rolls back.

On Supabase, `roles.sql` may contain `ALTER ROLE "supabase_admin"`; the managed
`postgres` role cannot change that reserved role, so `restore_new.sh` filters
that line automatically. If you run the `psql` command manually, remove or
comment that line.

If `psql` isn't installed, the script automatically uses the `postgres:17`
Docker image. Docker is also required by `supabase db dump`.

## 3. Verify the row counts

Run the verifier against both databases and compare. The `public` tables should
match exactly. The `auth` / `storage` counts will be empty in the new project —
those schemas are not copied by this kit.

```bash
DB_URL="$OLD_DB_URL" ./supabase/migration/verify.sh > /tmp/old-counts.txt
DB_URL="$NEW_DB_URL" ./supabase/migration/verify.sh > /tmp/new-counts.txt
diff -u /tmp/old-counts.txt /tmp/new-counts.txt
```

At minimum, check these tables in the new project:

```sql
select count(*) from public.challenges;
select count(*) from public.questions;
select count(*) from public.options;
```

## 4. Copy the storage files

The SQL dump contains only the `public` schema. The storage script creates the
buckets in the new project and copies the actual files:

```bash
export OLD_SUPABASE_URL='https://jokvxdrxswytjjhxuhvk.supabase.co'
export OLD_SERVICE_ROLE_KEY='<old service_role / secret key>'
export NEW_SUPABASE_URL='https://<new-ref>.supabase.co'
export NEW_SERVICE_ROLE_KEY='<new service_role / secret key>'

node supabase/migration/migrate_storage.mjs
```

Buckets used by the app:

- `challenges` — app logo
- `option` — option images
- `question` — question images/videos
- `sound-music-vocal` — background music and sound effects

For this project, the exact files referenced by the current data are listed in
`supabase/migration/required_storage_files.txt` — **21 unique files** (the logo
is already uploaded). The 15 question videos are the main remaining items; there
are also 3 option images, 1 challenge image, and 2 sound files.

**Current status:** all files referenced by the app data are uploaded — the 15
question videos, the 3 option images, the challenge image, and the logo.
`public.questions.image_url` and `public.options.image_url` now point at the new
project, and every public URL was verified with `200`. Sound/music is
intentionally not migrated (`--no-sound`; `AppConfig.isMusicEnabled` and
`AppConfig.isSoundEnabled` are both `false`).

The new project is on the Free plan, which rejects files larger than 50 MB.
Question 12 was 54.4 MiB, so it was re-encoded to 1080p H.264/AAC (about 7.5 MiB)
for the upload. The original downloaded file is unchanged.

### If the files were downloaded manually

If the old dashboard exported the files into `assets-supabase/` (or
`asset-supabase/`), use the local uploader instead of `migrate_storage.mjs`:

```bash
node supabase/migration/upload_local_assets.mjs --no-sound --skip-existing --dry-run
node supabase/migration/upload_local_assets.mjs --no-sound --skip-existing
```

The uploader:

- renames `[1] Aku ramah dan sopan.mp4` to `1_aku-ramah-dan-sopan.mp4` (and the
  other 14 videos to the same `N_lowercase-slug.mp4` convention);
- maps `option/senyum.png` to `option/challenge-sopan-ramah/smile.png`;
- uploads with upsert;
- updates the 15 `public.questions.image_url` rows to the new public URLs;
- verifies the public URLs.

`--dry-run` prints the full upload plan without requiring a key. `--no-sound`
skips the sound/music bucket entirely (the current choice). `--skip-existing`
skips objects that are already in the bucket, which is useful when adding the
challenge image later. If `challenges/challenges-1.png` is missing, the script
warns and continues with the available files.

To copy only some buckets:

```bash
BUCKETS=challenges,option,question node supabase/migration/migrate_storage.mjs
```

Use `DRY_RUN=1` to list buckets/files without uploading:

```bash
DRY_RUN=1 node supabase/migration/migrate_storage.mjs
```

## 5. Rewrite old URLs stored in rows

Rows such as `challenges.image_url`, `questions.image_url`,
`options.image_url`, and `games.image_url` still point to the old project.

```bash
OLD_PROJECT_REF=jokvxdrxswytjjhxuhvk \
NEW_PROJECT_REF=<new-ref> \
./supabase/migration/rewrite_storage_urls.sh
```

The script prints a count of **signed** URLs (`/storage/v1/object/sign/...`).
Those contain a token tied to the old project; replacing the host is not enough.
Regenerate them, or make the bucket public and store public URLs instead.

In this project there were **no signed URLs**: all 15 question URLs and 45 option
URLs use `/object/public/`. If another project has signed question URLs, prefer
generating them at runtime with
`supabase.storage.from('question').createSignedUrl(path, expiresIn)`, or make the
bucket public and store public URLs.

## 6. Update the Flutter app

The project URL and anon key now live in
`lib/core/config/supabase_config.dart`:

- `SupabaseConfig.url` — new project URL
- `SupabaseConfig.anonKey` — new **anon JWT** (public key)
- `SupabaseConfig.publicObject(bucket, path)` — public storage URL helper

`lib/main.dart` and the logo URLs in the four screens use it. You can override
the values at build time without editing code:

```bash
flutter run \
  --dart-define=SUPABASE_URL='https://<new-ref>.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<new anon JWT>'
```

`supabase_flutter` 2.9.1 only accepts `anonKey`, not `publishableKey`. To use the
new `sb_publishable_...` key, upgrade to `supabase_flutter` >= 2.13.0 (Flutter
>= 3.35) and rename the parameter to `publishableKey`.

The runtime URLs now point at the new project. `sound_service.dart` uses
`SupabaseConfig.publicObject` for the new `sound-music-vocal` bucket; the MP3
files still need to be uploaded. The seed SQL host was updated too. Remaining
old references are only migration docs and test fixtures.

If the old project is restricted and you cannot copy storage yet, rewriting the
URLs now is safe: the app falls back to placeholders for missing images. Upload
the files to the same paths later and they will start working.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `psql: You must install at least one postgresql-client` | The scripts fall back to Docker automatically. Keep Docker running. |
| `supabase db dump` fails | Docker must be running. Try the Session pooler connection string. |
| Old project returns `402 exceed_cached_egress_quota` | The owner must remove the spend cap or upgrade the plan temporarily. Direct Postgres may still work for `db dump`; REST/Storage/Auth are blocked. |
| `supabase db query` fails with `syntax error at or near "1"` | It cannot replay a `pg_dump --use-copy` file (`COPY ... FROM stdin` is psql-specific). Use `psql` or `restore_new.sh`. |
| `supabase db push` restored the schema but no rows | `db push` applies migrations, not a data dump. Use `psql` for `data.sql`. |
| `ALTER ROLE "supabase_admin" is a reserved role` | `restore_new.sh` filters that line automatically. For a manual restore, remove or comment it. |
| `pg_dump: PQgetCopyData() failed: SSL connection has been closed unexpectedly` | The pooler dropped a large `COPY`. Use the direct host with `docker run --network host` (see step 1). |
| `ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres"` fails | Comment out that line in `schema.sql`; the publication already exists. |
| `permission denied to grant role "postgres"` while restoring `roles.sql` | Comment out the `GRANT "postgres" TO "cli_login_postgres" ...` line in `dump/roles.sql` (Supabase's documented workaround). |
| `ALTER ... OWNER TO "supabase_admin"` errors | Comment out those lines in `dump/schema.sql`. |
| Restore fails while loading `data.sql` | Check the failing table/row in the output. `data.sql` contains only `public`; create a fresh project and retry. |
| Duplicate key on a second restore | The new project is no longer empty. Create a fresh project or reset it. |
| Storage upload 400/403 | Check that you used the **service_role / secret** key, not the anon key. |
| Files uploaded but app still shows old images | Run step 5 to rewrite the URLs in the database rows. |

## Optional: migrate Supabase Auth users

The current app writes to `public.users` directly and the login screen is
disabled, so `auth` rows are **not** copied by default. If you do use Supabase
Auth, dump and restore them separately:

```bash
npx supabase db dump --db-url "$OLD_DB_URL" \
  -f supabase/migration/dump/auth-data.sql \
  --use-copy --data-only --schema auth

psql "$NEW_DB_URL" --single-transaction --variable ON_ERROR_STOP=1 \
  --command 'SET session_replication_role = replica' \
  --file supabase/migration/dump/auth-data.sql
```

Password hashes are portable, but sessions/refresh tokens from the old project
will not be valid on the new one. If the old and new projects run different
GoTrue versions, some `auth` columns may not match — inspect the error and dump
only the tables you need (`auth.users`, `auth.identities`). If any `public` table
has a foreign key to `auth.users`, restore the auth data **before** `data.sql`.

## Important

- **Do not delete the old project yet.** Keep it as a fallback until the new app
  has been tested end to end.
- The old project is currently returning `402 exceed_cached_egress_quota` for
  REST/Storage/Auth. Direct Postgres still works, but the old storage files are
  unreachable until the owner removes the spend cap or upgrades temporarily.
- Don't commit `supabase/migration/dump/` — it contains user data.
