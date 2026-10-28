-- Rewrite storage URLs from Supabase Storage to the R2 custom domain.
-- Run in Supabase SQL editor (or via upload_r2.mjs --db with a service key).
UPDATE public.questions
  SET image_url = replace(image_url, 'https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/', 'https://media.scl-vguard.com/')
  WHERE image_url LIKE '%https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/%';
UPDATE public.options
  SET image_url = replace(image_url, 'https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/', 'https://media.scl-vguard.com/')
  WHERE image_url LIKE '%https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/%';
UPDATE public.challenges
  SET image_url = replace(image_url, 'https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/', 'https://media.scl-vguard.com/')
  WHERE image_url LIKE '%https://gskxaynpuycgbitgewwk.supabase.co/storage/v1/object/public/%';
