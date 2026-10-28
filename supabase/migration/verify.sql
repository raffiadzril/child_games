-- Row counts and schema checks for comparing the old and new projects.
-- Run this against both databases with verify.sh.

\pset pager off

\echo '== Database =='
SELECT current_database() AS database,
       current_setting('server_version') AS postgres_version,
       inet_server_addr() AS server_addr;

\echo '== Public table row counts =='
SELECT table_name, row_count
FROM (
  SELECT table_name,
         (xpath(
           '/row/c/text()',
           query_to_xml(
             format('SELECT count(*) AS c FROM public.%I', table_name),
             false,
             true,
             ''
           )
         ))[1]::text::bigint AS row_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
) counts
ORDER BY table_name;

\echo '== Storage metadata =='
SELECT name, row_count
FROM (
  SELECT 'storage.buckets' AS name,
         CASE WHEN to_regclass('storage.buckets') IS NULL THEN NULL
              ELSE (xpath('/row/c/text()', query_to_xml('SELECT count(*) AS c FROM storage.buckets', false, true, '')))[1]::text::bigint
         END AS row_count
  UNION ALL
  SELECT 'storage.objects',
         CASE WHEN to_regclass('storage.objects') IS NULL THEN NULL
              ELSE (xpath('/row/c/text()', query_to_xml('SELECT count(*) AS c FROM storage.objects', false, true, '')))[1]::text::bigint
         END
) storage_counts
ORDER BY name;

\echo '== Auth =='
SELECT name, row_count
FROM (
  SELECT 'auth.users' AS name,
         CASE WHEN to_regclass('auth.users') IS NULL THEN NULL
              ELSE (xpath('/row/c/text()', query_to_xml('SELECT count(*) AS c FROM auth.users', false, true, '')))[1]::text::bigint
         END AS row_count
  UNION ALL
  SELECT 'auth.identities',
         CASE WHEN to_regclass('auth.identities') IS NULL THEN NULL
              ELSE (xpath('/row/c/text()', query_to_xml('SELECT count(*) AS c FROM auth.identities', false, true, '')))[1]::text::bigint
         END
) auth_counts
ORDER BY name;

\echo '== RLS policies in public =='
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
