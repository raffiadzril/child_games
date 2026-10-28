-- Rewrite the old project's storage URLs stored in public table rows.
--
-- Usage (normally via rewrite_storage_urls.sh):
--   psql "$NEW_DB_URL" \
--     -v old_url='https://old-ref.supabase.co' \
--     -v new_url='https://new-ref.supabase.co' \
--     -f rewrite_storage_urls.sql
--
-- This only changes the host. Signed URLs (/storage/v1/object/sign/...)
-- contain a token tied to the old project and still need to be regenerated.

SET migration.old_url = :'old_url';
SET migration.new_url = :'new_url';

BEGIN;

DO $$
DECLARE
  old_url text := current_setting('migration.old_url');
  new_url text := current_setting('migration.new_url');
  target record;
BEGIN
  FOR target IN
    SELECT *
    FROM (VALUES
      ('public.challenges', 'image_url'),
      ('public.questions', 'image_url'),
      ('public.options', 'image_url'),
      ('public.games', 'image_url')
    ) AS candidates(table_name, column_name)
  LOOP
    IF to_regclass(target.table_name) IS NOT NULL THEN
      EXECUTE format(
        'UPDATE %s SET %I = replace(%I, $1, $2) WHERE %I LIKE $1 || ''%%''',
        target.table_name,
        target.column_name,
        target.column_name,
        target.column_name
      ) USING old_url, new_url;
    END IF;
  END LOOP;
END $$;

COMMIT;

-- Report signed URLs that still need to be regenerated. This scans every
-- public table with an image_url column, so it works even if some tables are
-- missing.
SELECT table_name, signed_urls
FROM (
  SELECT table_name,
         (xpath(
           '/row/c/text()',
           query_to_xml(
             format(
               'SELECT count(*) AS c FROM public.%I WHERE %I LIKE %L',
               table_name,
               column_name,
               '%/storage/v1/object/sign/%'
             ),
             false,
             true,
             ''
           )
         ))[1]::text::bigint AS signed_urls
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'image_url'
) signed
WHERE signed_urls > 0
ORDER BY table_name;
