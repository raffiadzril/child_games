/*
SQL Script untuk testing media detection pada questions
Jalankan di Supabase SQL Editor untuk membuat sample data

Pastikan sudah ada challenge_id yang valid terlebih dahulu!
*/

-- 1. Tambah sample data dengan gambar
INSERT INTO questions (id, challenge_id, question_text, image_url, question_number) 
VALUES (
  gen_random_uuid()::text,
  'your-challenge-id-here', -- Ganti dengan challenge ID yang valid
  'Lihat gambar ini! Apa yang kamu lihat?',
  'https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=500&h=300&fit=crop',
  1
);

-- 2. Tambah sample data dengan video MP4
INSERT INTO questions (id, challenge_id, question_text, image_url, question_number) 
VALUES (
  gen_random_uuid()::text,
  'your-challenge-id-here', -- Ganti dengan challenge ID yang valid
  'Tonton video ini dan jawab pertanyaan!',
  'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
  2
);

-- 3. Tambah sample data tanpa media
INSERT INTO questions (id, challenge_id, question_text, image_url, question_number) 
VALUES (
  gen_random_uuid()::text,
  'your-challenge-id-here', -- Ganti dengan challenge ID yang valid
  'Ini adalah pertanyaan tanpa media. Berapa hasil 2 + 2?',
  null,
  3
);

-- 4. Tambah sample data dengan video WEBM
INSERT INTO questions (id, challenge_id, question_text, image_url, question_number) 
VALUES (
  gen_random_uuid()::text,
  'your-challenge-id-here', -- Ganti dengan challenge ID yang valid
  'Video dengan format berbeda',
  'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-webm-file.webm',
  4
);

-- Query untuk melihat semua questions dengan media type yang akan terdeteksi
SELECT 
  id,
  question_text,
  image_url,
  CASE 
    WHEN image_url IS NULL OR image_url = '' THEN 'none'
    WHEN LOWER(image_url) ~ '\.(mp4|mov|avi|mkv|webm|m4v|flv|3gp)(\?.*)?$' THEN 'video'
    WHEN LOWER(image_url) ~ '\.(jpg|jpeg|png|gif|webp|svg|bmp)(\?.*)?$' THEN 'image'
    ELSE 'unknown'
  END as detected_media_type
FROM questions
ORDER BY question_number;
