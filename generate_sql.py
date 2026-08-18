import json
import uuid

with open('adult_questions.json', encoding='utf-8') as f:
    items = json.load(f)

challenge_id = 'a1b2c3d4-e5f6-7890-abcd-131313131313'

sql_lines = [
    '-- SQL Script to insert Adult REI Questions (>= 13 Years Old) into Supabase',
    f"INSERT INTO challenges (id, title, description, category, is_active) VALUES ('{challenge_id}', 'Assesmen REI (13+ Tahun)', 'Kuesioner Respect, Equity, & Inclusion untuk usia 13 tahun ke atas', 'REI 13+', true) ON CONFLICT (id) DO NOTHING;\n"
]

options_template = [
    ('A', 'Sangat tidak seperti saya', 1, 5),
    ('B', 'Tidak seperti saya', 2, 4),
    ('C', 'Kadang seperti saya', 3, 3),
    ('D', 'Seperti Saya', 4, 2),
    ('E', 'Sangat seperti saya', 5, 1)
]

for item in items:
    q_id = str(uuid.uuid4())
    q_text = item['question_text'].replace("'", "''")
    q_num = item['no']
    is_pos = item['point_type'] == '+'
    
    sql_lines.append(f"-- Question {q_num}: {item['variable']} ({item['indicator']}) [{item['point_type']}]")
    sql_lines.append(f"INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('{q_id}', '{challenge_id}', '{q_text}', {q_num});")
    
    opts_sql = []
    for label, text, pos_score, neg_score in options_template:
        opt_id = str(uuid.uuid4())
        score = pos_score if is_pos else neg_score
        opts_sql.append(f"('{opt_id}', '{q_id}', '{label}', '{text}', {score})")
    
    sql_lines.append("INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES\n  " + ",\n  ".join(opts_sql) + ";\n")

with open('adult_questions.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines))

print('adult_questions.sql generated successfully!')
