
DO $$
DECLARE
    v_question_id UUID;
    v_challenge_id UUID := 'd94f6c69-61c8-4c3f-9ebe-f564a56151fa';
BEGIN
-- Pertanyaan 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku ramah dan sopan', 1
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku mendengarkan jika temanku berbicara', 2
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku taat pada aturan', 3
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku baik kepada semua orang', 4
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku bangga pada diriku', 5
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku senang jika temanku bermain adil', 6
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku selalu bermain dengan adil', 7
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku rajin membantu', 8
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku suka keadilan', 9
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku suka berbagi dengan adil tanpa membeda-bedakan', 10
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku suka mengajak semua temanku bermain bersama', 11
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku bisa bermain dengan siapa saja', 12
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku tidak pernah membiarkan temanku menyendiri', 13
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku merasa bahwa berbeda itu bukan masalah', 14
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');

-- Pertanyaan 15
    v_question_id := gen_random_uuid();
    INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES (
        v_question_id, v_challenge_id, 'Aku mendukung temanku agar lebih percaya diri', 15
    );
    INSERT INTO options (question_id, option_label, option_text, score_option, image_url) VALUES
        (v_question_id, 'A', 'Selalu', 100, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/smile.png'),
        (v_question_id, 'B', 'Kadang-kadang', 50, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/flat.png'),
        (v_question_id, 'C', 'Belum', 0, 'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/option/challenge-sopan-ramah/sad.png');
END $$;
