-- Script Migration SQL untuk Supabase
-- Menambahkan kolom survey_type dan detail kompetisi pada tabel users

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS survey_type TEXT,
ADD COLUMN IF NOT EXISTS competition_type TEXT,
ADD COLUMN IF NOT EXISTS competition_level TEXT;

-- Keterangan:
-- survey_type       : Menyimpan 'PRE' (Survei Awal) atau 'POST' (Survei Akhir)
-- competition_type  : Menyimpan 'Beregu', 'Individu', atau 'Keduanya'
-- competition_level : Menyimpan tingkat kejuaraan ('Internasional', 'Nasional', 'Provinsi', 'Kabupaten', 'Kecamatan', 'Belum Pernah Juara')
