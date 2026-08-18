-- SQL Script to insert Adult REI Questions (>= 13 Years Old) into Supabase
INSERT INTO challenges (id, title, description, category, is_active) VALUES ('a1b2c3d4-e5f6-7890-abcd-131313131313', 'Assesmen REI (13+ Tahun)', 'Kuesioner Respect, Equity, & Inclusion untuk usia 13 tahun ke atas', 'REI 13+', true) ON CONFLICT (id) DO NOTHING;

-- Question 1: Respect (Developing Self-Respect) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('ed2f2787-d0af-49f2-982c-02ec1d48062a', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tetap menghargai kemampuan diri saya meskipun kemampuan olahraga saya berbeda dengan teman-teman.', 1);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('fefc1c47-01e4-4b2a-967d-5e5d1b7cfafa', 'ed2f2787-d0af-49f2-982c-02ec1d48062a', 'A', 'Sangat tidak seperti saya', 1),
  ('f98fffba-45c8-4974-952f-4731f34d4d27', 'ed2f2787-d0af-49f2-982c-02ec1d48062a', 'B', 'Tidak seperti saya', 2),
  ('50a5f538-d3cb-4133-86df-df5d36cffd7a', 'ed2f2787-d0af-49f2-982c-02ec1d48062a', 'C', 'Kadang seperti saya', 3),
  ('70f0064d-3924-402d-a2d2-1c792ccd104e', 'ed2f2787-d0af-49f2-982c-02ec1d48062a', 'D', 'Seperti Saya', 4),
  ('8d9ced16-f465-4181-b4a5-600f09764a17', 'ed2f2787-d0af-49f2-982c-02ec1d48062a', 'E', 'Sangat seperti saya', 5);

-- Question 2: Respect (Developing Self-Respect) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('e132aa00-085a-4d56-a34a-167e4be9cd7e', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Ketika teman bermain lebih baik dari saya, saya  merasa kemampuan saya tidak cukup baik.', 2);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('a08b7c1a-6c6e-4ac5-ab7b-ecbfcd47b827', 'e132aa00-085a-4d56-a34a-167e4be9cd7e', 'A', 'Sangat tidak seperti saya', 5),
  ('31d7bba2-9949-4696-a833-20f929266a21', 'e132aa00-085a-4d56-a34a-167e4be9cd7e', 'B', 'Tidak seperti saya', 4),
  ('f50e1efe-7996-43fd-8d12-c1acac9dea6c', 'e132aa00-085a-4d56-a34a-167e4be9cd7e', 'C', 'Kadang seperti saya', 3),
  ('d2fcab08-200f-40ab-8747-074bf8204115', 'e132aa00-085a-4d56-a34a-167e4be9cd7e', 'D', 'Seperti Saya', 2),
  ('ca11fb8b-2601-4b1d-9644-738c71464676', 'e132aa00-085a-4d56-a34a-167e4be9cd7e', 'E', 'Sangat seperti saya', 1);

-- Question 3: Respect (Developing Self-Respect) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('46d2b614-188a-4f50-b942-10ee363e7023', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Ketika kemampuan saya tidak seperti yang saya harapkan, saya merasa kecewa pada diri sendiri.', 3);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('c188b1c6-1af2-4be5-a229-fa0c4fd896c9', '46d2b614-188a-4f50-b942-10ee363e7023', 'A', 'Sangat tidak seperti saya', 5),
  ('97cd72fd-5375-4f82-bb6d-ddb84edc8f79', '46d2b614-188a-4f50-b942-10ee363e7023', 'B', 'Tidak seperti saya', 4),
  ('719187e7-905f-433d-9c86-33fc8622cf56', '46d2b614-188a-4f50-b942-10ee363e7023', 'C', 'Kadang seperti saya', 3),
  ('35bded0b-dbba-4e4e-b06a-1acdfbd18b88', '46d2b614-188a-4f50-b942-10ee363e7023', 'D', 'Seperti Saya', 2),
  ('908ce5d6-c6ae-4a49-9f94-55eb73dfb74d', '46d2b614-188a-4f50-b942-10ee363e7023', 'E', 'Sangat seperti saya', 1);

-- Question 4: Respect (Concept of Respect) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('ae62a6f5-507a-4f71-941b-3fef8bf04074', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Jika saya tidak setuju dengan pendapat teman saya, saya biasanya tetap tertarik untuk mendengarkannya.', 4);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('f4ab000f-312f-42d7-9779-3ab716760467', 'ae62a6f5-507a-4f71-941b-3fef8bf04074', 'A', 'Sangat tidak seperti saya', 1),
  ('df5247a9-c512-4558-a5ac-69894a0d5e1d', 'ae62a6f5-507a-4f71-941b-3fef8bf04074', 'B', 'Tidak seperti saya', 2),
  ('f62636b8-1b77-44ef-a91b-cd233902276e', 'ae62a6f5-507a-4f71-941b-3fef8bf04074', 'C', 'Kadang seperti saya', 3),
  ('656fa4ee-ae2c-49a3-bcbc-8d6194f224ef', 'ae62a6f5-507a-4f71-941b-3fef8bf04074', 'D', 'Seperti Saya', 4),
  ('5405fa52-11b6-4eb1-a3ad-a37639a86676', 'ae62a6f5-507a-4f71-941b-3fef8bf04074', 'E', 'Sangat seperti saya', 5);

-- Question 5: Respect (Concept of Respect) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya bisa menyampaikan pendapat yang berbeda tanpa membuat teman saya merasa tidak nyaman.', 5);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('1017f658-2422-45da-b421-1c356684dc21', '5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'A', 'Sangat tidak seperti saya', 1),
  ('c9cc201e-d18e-452c-a582-de57616b92ba', '5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'B', 'Tidak seperti saya', 2),
  ('82d974a8-4dd0-4bd3-83f8-4af1d7b3bd3e', '5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'C', 'Kadang seperti saya', 3),
  ('d798fe44-8ff0-4d4b-b123-9b73be46a8c0', '5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'D', 'Seperti Saya', 4),
  ('678d876e-c635-44a4-9acd-142d09721d26', '5e354406-cd22-4f45-a7a4-5b6bcf1f405f', 'E', 'Sangat seperti saya', 5);

-- Question 6: Respect (Concept of Respect) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('f588b670-5769-43e1-9685-b56dc77a3099', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya lebih mudah menghargai teman yang cara bermain atau cara berpikirnya sama dengan saya.', 6);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('d9976051-38a7-468f-9473-ca0fe5a57cc0', 'f588b670-5769-43e1-9685-b56dc77a3099', 'A', 'Sangat tidak seperti saya', 5),
  ('52998b59-c454-4292-b8b3-6678f2e72b1e', 'f588b670-5769-43e1-9685-b56dc77a3099', 'B', 'Tidak seperti saya', 4),
  ('f4d0ac71-169e-4316-9531-1935f5f47e46', 'f588b670-5769-43e1-9685-b56dc77a3099', 'C', 'Kadang seperti saya', 3),
  ('b3a909a0-9eb4-45ff-8c77-af09210f9c36', 'f588b670-5769-43e1-9685-b56dc77a3099', 'D', 'Seperti Saya', 2),
  ('3d48e148-da5b-4d35-b12f-43c238939ef0', 'f588b670-5769-43e1-9685-b56dc77a3099', 'E', 'Sangat seperti saya', 1);

-- Question 7: Respect (Rules & Authorities) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tidak pernah melanggar aturan permainan', 7);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('05c458b7-8cb7-4b2c-bc16-2bf5e555e6eb', '2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'A', 'Sangat tidak seperti saya', 1),
  ('21d7ade7-08ca-4250-b2bd-d62a0c0745fc', '2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'B', 'Tidak seperti saya', 2),
  ('bee651d8-9ffd-4ff7-bd71-caf024f7f6b1', '2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'C', 'Kadang seperti saya', 3),
  ('37f373b2-a5b0-4d6d-ad5a-5fb980feed1c', '2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'D', 'Seperti Saya', 4),
  ('6d145b62-174f-49d5-b602-c1e05f8ea99d', '2fc802b4-14e6-4efe-9df3-6e6fb15e497e', 'E', 'Sangat seperti saya', 5);

-- Question 8: Respect (Rules & Authorities) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tetap menerima keputusan wasit meskipun keputusan itu tidak sesuai dengan yang saya harapkan.', 8);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('1cf85c41-bdfb-4af5-a5c8-e3bf13f0e61f', 'b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'A', 'Sangat tidak seperti saya', 1),
  ('0189bf95-9cbf-4591-8a0c-0e0962e37b31', 'b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'B', 'Tidak seperti saya', 2),
  ('d2bb5cef-ca1f-417f-9400-9c2ae05ca0f0', 'b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'C', 'Kadang seperti saya', 3),
  ('d741b1f7-b95b-4c76-88fe-6b871945b720', 'b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'D', 'Seperti Saya', 4),
  ('7cc56d49-69d0-4c03-8f85-4de7c6f76f51', 'b053bae9-fe2b-4492-9ad2-1b32fbe4e080', 'E', 'Sangat seperti saya', 5);

-- Question 9: Respect (Rules & Authorities) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Jika menurut saya suatu aturan tidak masuk akal, saya merasa tidak perlu terlalu mengikutinya.', 9);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('868959dc-83d8-490d-b691-af9c49d8e0a1', 'ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'A', 'Sangat tidak seperti saya', 5),
  ('7fe657b7-c5df-4486-a6df-4a5e31bdb3bd', 'ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'B', 'Tidak seperti saya', 4),
  ('5d6aae53-5efa-4a74-942d-43efd8d5e5d8', 'ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'C', 'Kadang seperti saya', 3),
  ('793a11d5-769d-4b3d-ba53-e8381eef4be1', 'ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'D', 'Seperti Saya', 2),
  ('390f2f75-10b9-4810-b2b8-639964a1fe15', 'ee8cb3db-b1df-4b91-b8c2-a869acc4012b', 'E', 'Sangat seperti saya', 1);

-- Question 10: Respect (Conflict Resolution) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saat berselisih dengan teman dalam permainan, saya biasanya memilih diam dan membiarkannya begitu saja.', 10);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('73aad581-dd0f-40bb-8944-4bb15d4289a9', '2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'A', 'Sangat tidak seperti saya', 5),
  ('03e630c3-29a9-4f5e-98d5-770fb0a04a30', '2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'B', 'Tidak seperti saya', 4),
  ('e5d6a382-4c3b-410e-a9ba-cdc7a9e1597f', '2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'C', 'Kadang seperti saya', 3),
  ('1926bea6-a829-4e58-abe0-6c43cb13bc09', '2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'D', 'Seperti Saya', 2),
  ('c913bd9d-5d60-4ccb-9145-de5a987b6b06', '2cfd761a-c39a-4ff8-a0cc-01a9c5686671', 'E', 'Sangat seperti saya', 1);

-- Question 11: Respect (Conflict Resolution) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya mendengarkan alasan teman sebelum menentukan siapa yang salah dalam suatu masalah.', 11);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('9fe7cf39-8592-4849-b784-64fb9e078d8e', '50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'A', 'Sangat tidak seperti saya', 1),
  ('d70add39-b85a-4681-a8d2-f22bb55ca435', '50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'B', 'Tidak seperti saya', 2),
  ('9afb1c45-97c1-45ad-9d74-9de4654ef7ab', '50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'C', 'Kadang seperti saya', 3),
  ('065f917b-d1a5-4b5e-8a72-cd4956171778', '50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'D', 'Seperti Saya', 4),
  ('0bbad17f-064c-4ece-9268-6ee4dc579caa', '50688d3a-e12b-4eb5-9ea1-749af0b90c14', 'E', 'Sangat seperti saya', 5);

-- Question 12: Respect (Conflict Resolution) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Setelah terjadi perselisihan, saya masih berusaha mencari cara agar kami bisa bermain bersama dengan baik.', 12);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('5f982b00-bfed-4732-8326-e265054c2541', '7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'A', 'Sangat tidak seperti saya', 1),
  ('057e8540-57da-4c55-9a30-fa9eac2dba03', '7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'B', 'Tidak seperti saya', 2),
  ('6df20b6a-7e5d-4580-b2b6-78fb5a014a27', '7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'C', 'Kadang seperti saya', 3),
  ('51158f8e-ab63-4f19-98b6-800fa165523c', '7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'D', 'Seperti Saya', 4),
  ('60be3760-d04c-45ea-a76a-6fe353385e6c', '7ac18a1b-7c92-49ae-9b8d-e85c2fa6d219', 'E', 'Sangat seperti saya', 5);

-- Question 13: Respect (Empathy) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya sering menganggap teman hanya kurang berusaha ketika permainannya tidak berjalan dengan baik.', 13);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('090104f1-1abf-4585-8f9c-8c04f121f8a4', '28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'A', 'Sangat tidak seperti saya', 5),
  ('e45b9876-0bac-47d3-82f3-55aee3c70269', '28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'B', 'Tidak seperti saya', 4),
  ('5b3fae0d-9a82-435d-95ce-818459d19f67', '28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'C', 'Kadang seperti saya', 3),
  ('084d5c6f-0548-4e7e-9590-fdfe3b3c607e', '28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'D', 'Seperti Saya', 2),
  ('421ef39c-1223-4550-b447-cd0395c9fae9', '28c9f0c1-6710-48de-aa70-9e0210d44cd5', 'E', 'Sangat seperti saya', 1);

-- Question 14: Respect (Empathy) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('e9aab271-d587-44d6-869c-6412d838ac1a', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Ketika teman terlihat kesal setelah melakukan kesalahan, saya biasanya membiarkannya sendiri.', 14);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('925cc421-b81a-4b58-85a0-773c8b2664ca', 'e9aab271-d587-44d6-869c-6412d838ac1a', 'A', 'Sangat tidak seperti saya', 5),
  ('0b0738b1-fd84-4da4-8acd-561be6ea29ca', 'e9aab271-d587-44d6-869c-6412d838ac1a', 'B', 'Tidak seperti saya', 4),
  ('3a298d84-6a92-41e2-91c0-4b68e2b3e11d', 'e9aab271-d587-44d6-869c-6412d838ac1a', 'C', 'Kadang seperti saya', 3),
  ('e83ab377-c636-411e-851e-6f3a826889e5', 'e9aab271-d587-44d6-869c-6412d838ac1a', 'D', 'Seperti Saya', 2),
  ('991e3f2a-a8e3-46ae-a2d6-eb09ff708a47', 'e9aab271-d587-44d6-869c-6412d838ac1a', 'E', 'Sangat seperti saya', 1);

-- Question 15: Respect (Empathy) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('7bd38d48-309b-40fb-84b4-4449a6f794be', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya memperhatikan perubahan sikap teman ketika sesuatu terjadi dalam permainan.', 15);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('f3dde3d9-6d9e-4bc8-8a82-7356123dea3a', '7bd38d48-309b-40fb-84b4-4449a6f794be', 'A', 'Sangat tidak seperti saya', 1),
  ('2f9d2251-23e4-4272-b2f8-b3ab7710b83d', '7bd38d48-309b-40fb-84b4-4449a6f794be', 'B', 'Tidak seperti saya', 2),
  ('828bdbaf-1e49-4d19-915b-fe898e832d64', '7bd38d48-309b-40fb-84b4-4449a6f794be', 'C', 'Kadang seperti saya', 3),
  ('aa2f0150-8bf9-4b01-8222-4d163a89d72c', '7bd38d48-309b-40fb-84b4-4449a6f794be', 'D', 'Seperti Saya', 4),
  ('5e9779bc-c912-444f-960c-26736955e819', '7bd38d48-309b-40fb-84b4-4449a6f794be', 'E', 'Sangat seperti saya', 5);

-- Question 16: Equity (Advantage & Disadvantage) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya menyadari bahwa kesempatan seseorang untuk berkembang dalam olahraga bisa berbeda karena pengalaman atau dukungan yang mereka dapatkan.', 16);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('3199b3a5-3a5d-4f1b-93ce-b6a735972a11', 'b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'A', 'Sangat tidak seperti saya', 1),
  ('5c5acc8f-fe3f-4ca3-bcb7-f37010505a45', 'b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'B', 'Tidak seperti saya', 2),
  ('1ded7119-c6ef-4008-8171-df1de41003f9', 'b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'C', 'Kadang seperti saya', 3),
  ('e340bbc3-67f1-4960-89ad-f0414eb38cc0', 'b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'D', 'Seperti Saya', 4),
  ('74b740af-81d3-49b3-b716-86253e40e61c', 'b929c0f9-1374-4748-a111-1fbd55e0b8fd', 'E', 'Sangat seperti saya', 5);

-- Question 17: Equity (Advantage & Disadvantage) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('d42df326-a452-425f-b57a-d92afc18314a', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Menurut saya, teman yang memiliki perlengkapan lebih lengkap lebih pantas mendapat kesempatan bermain lebih banyak.', 17);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('535113ac-9be8-4109-b7dd-e68e24955e7e', 'd42df326-a452-425f-b57a-d92afc18314a', 'A', 'Sangat tidak seperti saya', 5),
  ('eefa6760-6b62-4b8b-8f95-6fe2069591ea', 'd42df326-a452-425f-b57a-d92afc18314a', 'B', 'Tidak seperti saya', 4),
  ('7ea99e25-8dd0-4389-9130-93ea80c6d0f5', 'd42df326-a452-425f-b57a-d92afc18314a', 'C', 'Kadang seperti saya', 3),
  ('105ac629-b903-4c50-b3fc-739f8cc56724', 'd42df326-a452-425f-b57a-d92afc18314a', 'D', 'Seperti Saya', 2),
  ('64c0e961-7844-4889-aa77-d57f4654e3ca', 'd42df326-a452-425f-b57a-d92afc18314a', 'E', 'Sangat seperti saya', 1);

-- Question 18: Equity (Advantage & Disadvantage) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('ee1c0197-05c7-458f-a427-c4e4653bf63d', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya menganggap semua orang memiliki kesempatan yang sama untuk berkembang dalam olahraga.', 18);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('4540959c-edde-43e9-946e-931c9d3ff7b5', 'ee1c0197-05c7-458f-a427-c4e4653bf63d', 'A', 'Sangat tidak seperti saya', 5),
  ('4aad9ac0-1ba1-41f8-9d13-e5629a63bc4e', 'ee1c0197-05c7-458f-a427-c4e4653bf63d', 'B', 'Tidak seperti saya', 4),
  ('6fded4e1-8edb-42f9-8e13-5a58f363bca0', 'ee1c0197-05c7-458f-a427-c4e4653bf63d', 'C', 'Kadang seperti saya', 3),
  ('374b8ca0-8ecd-48b1-a0f4-8fdb421eb479', 'ee1c0197-05c7-458f-a427-c4e4653bf63d', 'D', 'Seperti Saya', 2),
  ('e97defd3-fbb3-4e73-98f7-c5df9badc89e', 'ee1c0197-05c7-458f-a427-c4e4653bf63d', 'E', 'Sangat seperti saya', 1);

-- Question 19: Equity (Equity vs Equality) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('aac22a64-ef0c-40af-85e1-4b8eeb461097', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa semua pemain harus mendapat bantuan yang sama agar pembagiannya adil.', 19);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('fa6cb3c4-5c98-4b5b-8456-91127df21cbd', 'aac22a64-ef0c-40af-85e1-4b8eeb461097', 'A', 'Sangat tidak seperti saya', 5),
  ('93438e86-9ea1-41ab-8502-bf4dd14d677a', 'aac22a64-ef0c-40af-85e1-4b8eeb461097', 'B', 'Tidak seperti saya', 4),
  ('7b987415-640e-4e1c-b9c8-10b03b7e63b3', 'aac22a64-ef0c-40af-85e1-4b8eeb461097', 'C', 'Kadang seperti saya', 3),
  ('b36130c1-7616-4a29-a125-76740924a1d9', 'aac22a64-ef0c-40af-85e1-4b8eeb461097', 'D', 'Seperti Saya', 2),
  ('4747fc64-90a3-446d-befb-da50f96e0b4e', 'aac22a64-ef0c-40af-85e1-4b8eeb461097', 'E', 'Sangat seperti saya', 1);

-- Question 20: Equity (Equity vs Equality) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('11ffe336-11ed-4553-91f3-be2257644847', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tidak keberatan jika seorang teman mendapat dukungan khusus agar dapat mengikuti permainan bersama yang lain.', 20);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('0cd26bda-ab9d-4f51-b143-23cec793f79e', '11ffe336-11ed-4553-91f3-be2257644847', 'A', 'Sangat tidak seperti saya', 1),
  ('bd5be63a-58f0-4a6e-9642-e9f633cda6b8', '11ffe336-11ed-4553-91f3-be2257644847', 'B', 'Tidak seperti saya', 2),
  ('4964066a-33ed-4778-b512-1ff002350231', '11ffe336-11ed-4553-91f3-be2257644847', 'C', 'Kadang seperti saya', 3),
  ('1d248f4e-113e-4869-b352-3a117126d9c5', '11ffe336-11ed-4553-91f3-be2257644847', 'D', 'Seperti Saya', 4),
  ('03bb1c9a-8638-47c2-96ce-a4ba693bf4c3', '11ffe336-11ed-4553-91f3-be2257644847', 'E', 'Sangat seperti saya', 5);

-- Question 21: Equity (Equity vs Equality) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa pembagian yang adil tidak selalu berarti semua orang mendapat hal yang sama.', 21);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('2fc31a25-fd68-4dd5-af0c-6eaebbac8756', 'dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'A', 'Sangat tidak seperti saya', 1),
  ('39ed3404-3ce3-46a0-af77-964ceb1dec12', 'dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'B', 'Tidak seperti saya', 2),
  ('ac61cc30-3d63-43ff-b769-dca3661b7ec0', 'dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'C', 'Kadang seperti saya', 3),
  ('5e0bc138-a983-4de7-836c-0142d8cbe8aa', 'dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'D', 'Seperti Saya', 4),
  ('23012b80-ec38-427d-84bd-54f8103b09a9', 'dc7055d1-4d11-4d4a-8f73-ef436ecaf9e0', 'E', 'Sangat seperti saya', 5);

-- Question 22: Equity (Fairness in Sport) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya lebih memilih teman yang mahir banyak bermain agar tim memiliki peluang lebih besar untuk menang.', 22);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('68270534-b097-4ad6-afa2-2c7c73788954', '91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'A', 'Sangat tidak seperti saya', 5),
  ('1aa37226-98e0-4627-80d8-f130ef020330', '91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'B', 'Tidak seperti saya', 4),
  ('3f42f69c-311e-493c-aa61-342a35ebbee1', '91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'C', 'Kadang seperti saya', 3),
  ('2aedc2aa-dc71-4771-91d0-35ac8a135258', '91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'D', 'Seperti Saya', 2),
  ('c4b4d2b6-69ff-4aae-b4a0-71a7c6a443b8', '91ad82b3-df9e-419d-a885-54d69b6ea4ce', 'E', 'Sangat seperti saya', 1);

-- Question 23: Equity (Fairness in Sport) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('72b54b84-af05-41a5-aec7-2c3286294277', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya memikirkan siapa yang belum mendapat kesempatan bermain ketika memilih pemain untuk permainan berikutnya.', 23);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('7dc4e397-53c0-45b9-80fe-34a9f54d5e1e', '72b54b84-af05-41a5-aec7-2c3286294277', 'A', 'Sangat tidak seperti saya', 1),
  ('4a0e18f3-faed-4f51-9fcf-9b6e6473ca14', '72b54b84-af05-41a5-aec7-2c3286294277', 'B', 'Tidak seperti saya', 2),
  ('e004318d-db24-4351-a15d-7decd376285d', '72b54b84-af05-41a5-aec7-2c3286294277', 'C', 'Kadang seperti saya', 3),
  ('6bf49e7d-6051-4ce2-bea3-4e4809296bb8', '72b54b84-af05-41a5-aec7-2c3286294277', 'D', 'Seperti Saya', 4),
  ('9580a216-faef-45ef-b5f5-2538219e4235', '72b54b84-af05-41a5-aec7-2c3286294277', 'E', 'Sangat seperti saya', 5);

-- Question 24: Equity (Fairness in Sport) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tidak keberatan jika teman yang belum banyak bermain mendapat giliran lebih dulu.', 24);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('efe6a498-c711-4cf1-9c14-d51f08e73719', '8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'A', 'Sangat tidak seperti saya', 1),
  ('708f171d-ff25-4fe3-893f-ba29f6afcc34', '8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'B', 'Tidak seperti saya', 2),
  ('9ef97efb-b5e3-4e34-8a54-32c99fa05474', '8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'C', 'Kadang seperti saya', 3),
  ('a344c4d4-1017-4a2b-b976-a82902f6c4b8', '8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'D', 'Seperti Saya', 4),
  ('3b86acdc-508b-467a-af06-3f35de37acb2', '8a362d52-326e-44d0-b7cc-b6e2e36ee938', 'E', 'Sangat seperti saya', 5);

-- Question 25: Equity (Gender Equality) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saat bermain, saya lebih nyaman satu tim dengan teman yang berjenis kelamin sama dengan saya.', 25);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('2216df48-d585-4374-a965-cf4f6b1a7eff', 'e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'A', 'Sangat tidak seperti saya', 5),
  ('7e99bf56-1176-4c71-8038-8afbfab6cb36', 'e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'B', 'Tidak seperti saya', 4),
  ('af520263-ee09-4c3a-a0b7-29ae7044934c', 'e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'C', 'Kadang seperti saya', 3),
  ('3282e57a-c610-4224-a863-7e2148d357a0', 'e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'D', 'Seperti Saya', 2),
  ('7f462d36-6ae9-4612-ab76-276bfd9c0558', 'e867587e-9dc3-4b0e-859e-9f37bd6016b7', 'E', 'Sangat seperti saya', 1);

-- Question 26: Equity (Gender Equality) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('08fabedf-071b-4c95-bd2a-a682b97ed031', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tetap mau bermain satu tim dengan teman laki-laki maupun perempuan.', 26);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('09362cb3-b617-48c2-a550-3b8913b4f835', '08fabedf-071b-4c95-bd2a-a682b97ed031', 'A', 'Sangat tidak seperti saya', 1),
  ('f42130e3-9476-40d3-89db-2caba8e6e6ec', '08fabedf-071b-4c95-bd2a-a682b97ed031', 'B', 'Tidak seperti saya', 2),
  ('ab6ac98f-dbb8-4b9c-b6ae-1b3187c239f1', '08fabedf-071b-4c95-bd2a-a682b97ed031', 'C', 'Kadang seperti saya', 3),
  ('54304054-70c5-490f-9c51-cc0d3f913914', '08fabedf-071b-4c95-bd2a-a682b97ed031', 'D', 'Seperti Saya', 4),
  ('ecec196d-d97f-4ff8-99a5-5add8fde4516', '08fabedf-071b-4c95-bd2a-a682b97ed031', 'E', 'Sangat seperti saya', 5);

-- Question 27: Equity (Gender Equality) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Dalam memilih pemain, jenis kelamin bukan pertimbangan utama bagi saya.', 27);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('b80ef045-5170-4424-9da2-8fc197c442c4', 'dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'A', 'Sangat tidak seperti saya', 1),
  ('a006510c-ff1b-406d-9613-22cdb54e8694', 'dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'B', 'Tidak seperti saya', 2),
  ('187974fa-004e-467d-8ec3-73b0adb27190', 'dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'C', 'Kadang seperti saya', 3),
  ('1dfd5a3b-95ec-48fd-9d5b-02256c23dd4f', 'dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'D', 'Seperti Saya', 4),
  ('224b3445-70ab-4bbb-98eb-39a7ed7f72c9', 'dbb07b25-ac7c-4e1a-8f65-1cea85e7d43f', 'E', 'Sangat seperti saya', 5);

-- Question 28: Equity (Sharing Responsibility) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('cb980bf5-758b-48c6-9741-9323399f72fb', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Selama tugas saya sendiri sudah selesai, saya merasa tidak perlu ikut mengerjakan bagian teman.', 28);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('6e3b7f9d-7454-4d5b-aa68-70794640a5bd', 'cb980bf5-758b-48c6-9741-9323399f72fb', 'A', 'Sangat tidak seperti saya', 5),
  ('ce4c68b1-93b8-4221-878e-898e4c53a411', 'cb980bf5-758b-48c6-9741-9323399f72fb', 'B', 'Tidak seperti saya', 4),
  ('d67b2c51-c79c-4304-9498-9244fdfaaa36', 'cb980bf5-758b-48c6-9741-9323399f72fb', 'C', 'Kadang seperti saya', 3),
  ('a7717115-e65f-4fef-89fa-393e2c664dae', 'cb980bf5-758b-48c6-9741-9323399f72fb', 'D', 'Seperti Saya', 2),
  ('77bcffd7-0e39-4fb9-a71f-1d387def4535', 'cb980bf5-758b-48c6-9741-9323399f72fb', 'E', 'Sangat seperti saya', 1);

-- Question 29: Equity (Sharing Responsibility) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Jika ada bagian yang belum dikerjakan dalam tim, saya bersedia membantu meskipun bukan saya yang ditugaskan.', 29);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('fc7eb96d-1164-40b0-bf44-d231f7c218a4', 'f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'A', 'Sangat tidak seperti saya', 1),
  ('ddfbc601-c884-4add-9ab0-4efa31a7f0b0', 'f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'B', 'Tidak seperti saya', 2),
  ('a8df194b-4d35-4c8b-bdf1-bc7263e2ee43', 'f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'C', 'Kadang seperti saya', 3),
  ('e32e3ca0-db60-48b7-83f4-d9d953fa8c70', 'f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'D', 'Seperti Saya', 4),
  ('b1ddd91f-1cab-4c15-bfec-923f74e3780f', 'f8bb1dcf-b916-4e50-abee-2691b15e2ac3', 'E', 'Sangat seperti saya', 5);

-- Question 30: Equity (Sharing Responsibility) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('c2c168d0-c6d6-4e76-9606-91f94538871f', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya lebih suka mengambil tugas yang paling mudah bagi saya', 30);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('9a3831a9-7dec-4887-b186-bea962393388', 'c2c168d0-c6d6-4e76-9606-91f94538871f', 'A', 'Sangat tidak seperti saya', 5),
  ('5c6383e0-7d4b-41ac-98f9-aee13a19818d', 'c2c168d0-c6d6-4e76-9606-91f94538871f', 'B', 'Tidak seperti saya', 4),
  ('e0276bc7-1ec0-47e0-8b79-8f3f75df6593', 'c2c168d0-c6d6-4e76-9606-91f94538871f', 'C', 'Kadang seperti saya', 3),
  ('ff345e19-b4be-449c-89a1-234ec651e403', 'c2c168d0-c6d6-4e76-9606-91f94538871f', 'D', 'Seperti Saya', 2),
  ('fc8087ea-03b2-4483-a6e7-ae332bbc026d', 'c2c168d0-c6d6-4e76-9606-91f94538871f', 'E', 'Sangat seperti saya', 1);

-- Question 31: Inclusion (Removing Barriers) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('dd357233-6aa1-4ca3-984d-a652e3a13805', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Ketika seorang teman kesulitan mengikuti permainan, saya mencari cara agar ia tetap dapat ikut.', 31);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('d5a6c4dd-1e94-40a2-9a31-f9b361316f58', 'dd357233-6aa1-4ca3-984d-a652e3a13805', 'A', 'Sangat tidak seperti saya', 1),
  ('57331c3f-a410-46ea-b94c-67e07844e5b5', 'dd357233-6aa1-4ca3-984d-a652e3a13805', 'B', 'Tidak seperti saya', 2),
  ('8e3c864a-4997-4dd7-9568-d74564a62e87', 'dd357233-6aa1-4ca3-984d-a652e3a13805', 'C', 'Kadang seperti saya', 3),
  ('a54a7bdc-fe9f-495b-b5ba-6f3a7d2f61b1', 'dd357233-6aa1-4ca3-984d-a652e3a13805', 'D', 'Seperti Saya', 4),
  ('3c9ab55c-21ad-4fb8-8d4e-6e047dd0ff5c', 'dd357233-6aa1-4ca3-984d-a652e3a13805', 'E', 'Sangat seperti saya', 5);

-- Question 32: Inclusion (Removing Barriers) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa permainan tidak perlu diubah hanya karena ada satu orang yang kesulitan mengikutinya.', 32);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('adb17153-c727-4da1-80b6-9ac79cbe7706', '280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'A', 'Sangat tidak seperti saya', 5),
  ('692eeeec-9368-40e6-96cb-dadb94040eab', '280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'B', 'Tidak seperti saya', 4),
  ('7403d935-06c2-40c8-af06-f436b2acf824', '280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'C', 'Kadang seperti saya', 3),
  ('f16d9438-7bad-461e-92ac-0f293ed6098a', '280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'D', 'Seperti Saya', 2),
  ('d7ffc8cb-1098-46a0-afd3-f8ce307c18f0', '280eaafb-f8d9-4627-8a25-67e8eaaf66f2', 'E', 'Sangat seperti saya', 1);

-- Question 33: Inclusion (Removing Barriers) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('703293f6-6aae-46ed-9864-9575395bd12c', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Tidak masalah jika hanya 1 orang yang tidak bisa mengikuti permainan', 33);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('15ce7a68-7fec-4487-a9e3-dd12f0aebae4', '703293f6-6aae-46ed-9864-9575395bd12c', 'A', 'Sangat tidak seperti saya', 5),
  ('191039af-970d-44e9-97bb-babb7ac18bb3', '703293f6-6aae-46ed-9864-9575395bd12c', 'B', 'Tidak seperti saya', 4),
  ('434e51b2-58cc-43ed-a699-041d9087c1b2', '703293f6-6aae-46ed-9864-9575395bd12c', 'C', 'Kadang seperti saya', 3),
  ('cc2ff14a-dea4-43b2-9ffc-c0f0a713d240', '703293f6-6aae-46ed-9864-9575395bd12c', 'D', 'Seperti Saya', 2),
  ('81fc522f-f3ee-4384-b474-d2e2adaac986', '703293f6-6aae-46ed-9864-9575395bd12c', 'E', 'Sangat seperti saya', 1);

-- Question 34: Inclusion (Challenging Stereotypes) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tidak langsung menilai kemampuan seseorang dari penampilannya.', 34);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('a40bc5c6-c524-49bb-8042-963d149a897e', 'f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'A', 'Sangat tidak seperti saya', 1),
  ('d903206d-15a8-45b0-9100-7f7e9e21d887', 'f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'B', 'Tidak seperti saya', 2),
  ('3b224bff-14a6-42aa-9fc1-d84061c4b70a', 'f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'C', 'Kadang seperti saya', 3),
  ('a56d0cfb-cb92-455d-a521-311a4684916c', 'f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'D', 'Seperti Saya', 4),
  ('986af132-ac6b-4fee-bdbf-631f1a26e160', 'f5c5fbd1-4079-4eef-ae1b-63755d385fb8', 'E', 'Sangat seperti saya', 5);

-- Question 35: Inclusion (Challenging Stereotypes) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('17a67373-5230-4f52-b03f-50995ec9cc6c', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tetap mau bermain dengan teman yang dianggap tidak mahir oleh teman-teman lain.', 35);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('21806d39-a13f-4c69-b4bd-ddeea5a4dae3', '17a67373-5230-4f52-b03f-50995ec9cc6c', 'A', 'Sangat tidak seperti saya', 1),
  ('d965cb42-7fbb-4fc9-847c-bb4848a3c853', '17a67373-5230-4f52-b03f-50995ec9cc6c', 'B', 'Tidak seperti saya', 2),
  ('50ff5593-07c6-4808-a00b-6edbcf7c2f23', '17a67373-5230-4f52-b03f-50995ec9cc6c', 'C', 'Kadang seperti saya', 3),
  ('620c8b0a-ec29-4e1b-b1e9-a1bfdc104889', '17a67373-5230-4f52-b03f-50995ec9cc6c', 'D', 'Seperti Saya', 4),
  ('d72776af-1169-4d54-a91b-ce620bdb184c', '17a67373-5230-4f52-b03f-50995ec9cc6c', 'E', 'Sangat seperti saya', 5);

-- Question 36: Inclusion (Challenging Stereotypes) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('244810cd-7c37-44bf-81bb-f6cfe1290edd', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa teman yang terlihat kurang mampu memang biasanya tidak akan bisa bermain dengan baik.', 36);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('20fd8e08-c3d9-47ff-b8ee-51683bc84edd', '244810cd-7c37-44bf-81bb-f6cfe1290edd', 'A', 'Sangat tidak seperti saya', 5),
  ('85ae9b74-d09d-4aef-9f4a-53d2f06d86f4', '244810cd-7c37-44bf-81bb-f6cfe1290edd', 'B', 'Tidak seperti saya', 4),
  ('f24edcc8-072a-4623-9779-977abcba32d8', '244810cd-7c37-44bf-81bb-f6cfe1290edd', 'C', 'Kadang seperti saya', 3),
  ('7f242cd8-ec67-404d-81bf-a771aa8c77da', '244810cd-7c37-44bf-81bb-f6cfe1290edd', 'D', 'Seperti Saya', 2),
  ('ca2e3772-1e31-4215-af43-417e1cb47c9c', '244810cd-7c37-44bf-81bb-f6cfe1290edd', 'E', 'Sangat seperti saya', 1);

-- Question 37: Inclusion (Accessibility) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa semua teman seharusnya punya kesempatan untuk menggunakan fasilitas olahraga yang tersedia.', 37);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('77a5d31a-d300-4caa-9b83-db34b1297741', '6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'A', 'Sangat tidak seperti saya', 1),
  ('adf53846-57eb-43c4-b828-3f8c25b38fe9', '6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'B', 'Tidak seperti saya', 2),
  ('b0a41338-9b10-4906-957f-1f30acd37a20', '6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'C', 'Kadang seperti saya', 3),
  ('343d5c7a-13d7-487c-bb4e-7ec3be458144', '6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'D', 'Seperti Saya', 4),
  ('f09f6f0c-bf60-4a62-b78e-5f412aea8718', '6e45ee7e-a284-4646-bef8-6e31a6b0b674', 'E', 'Sangat seperti saya', 5);

-- Question 38: Inclusion (Accessibility) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('e916aec2-267c-44e0-a740-61c438f2c0a7', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Menurut saya, tidak perlu memikirkan apakah semua pemain bisa menggunakan alat olahraga yang tersedia.', 38);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('6407e3c0-28cf-4fa6-b042-6003ddb233fc', 'e916aec2-267c-44e0-a740-61c438f2c0a7', 'A', 'Sangat tidak seperti saya', 5),
  ('de2841fc-9039-42c4-8cd2-692e1f3c2988', 'e916aec2-267c-44e0-a740-61c438f2c0a7', 'B', 'Tidak seperti saya', 4),
  ('33f1e228-fa1e-4e47-a288-a52b493e0829', 'e916aec2-267c-44e0-a740-61c438f2c0a7', 'C', 'Kadang seperti saya', 3),
  ('8c06df68-45b5-41d0-9445-6478986b1966', 'e916aec2-267c-44e0-a740-61c438f2c0a7', 'D', 'Seperti Saya', 2),
  ('8b88a4a8-9fd9-46f7-ad74-069dada054f2', 'e916aec2-267c-44e0-a740-61c438f2c0a7', 'E', 'Sangat seperti saya', 1);

-- Question 39: Inclusion (Accessibility) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya merasa tempat bermain sebaiknya dapat digunakan oleh teman dengan kondisi yang berbeda-beda.', 39);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('bc1f9625-5fff-426c-9eef-6a29b14874d7', '6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'A', 'Sangat tidak seperti saya', 1),
  ('79885dd9-47d3-4d5f-bf34-4486e21264c8', '6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'B', 'Tidak seperti saya', 2),
  ('fff8239f-2445-4947-a059-c2fd26ec5fb3', '6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'C', 'Kadang seperti saya', 3),
  ('ddb19686-fada-4953-a6e0-019d98d51531', '6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'D', 'Seperti Saya', 4),
  ('1051be71-d0b9-420a-9117-bd01023a0559', '6a27ae4d-632d-431c-9f58-f413f1aa74ce', 'E', 'Sangat seperti saya', 5);

-- Question 40: Inclusion (Inclusive Communication) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('ad62ebd9-b234-4254-84be-99aa501063bd', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya menggunakan cara lain untuk menjelaskan sesuatu ketika teman sulit memahami penjelasan saya.', 40);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('113b86f4-0a09-4134-8565-0fd3bb8ede86', 'ad62ebd9-b234-4254-84be-99aa501063bd', 'A', 'Sangat tidak seperti saya', 1),
  ('c8bc00d6-58bc-450b-ab49-3b81e7ca9d4b', 'ad62ebd9-b234-4254-84be-99aa501063bd', 'B', 'Tidak seperti saya', 2),
  ('04c0fd40-af92-4295-8e91-98ae8cb143f8', 'ad62ebd9-b234-4254-84be-99aa501063bd', 'C', 'Kadang seperti saya', 3),
  ('6c3661ca-e838-49e7-8bac-6474d4d70792', 'ad62ebd9-b234-4254-84be-99aa501063bd', 'D', 'Seperti Saya', 4),
  ('c9972549-4c6d-4b3e-a38e-bb64e41d9df7', 'ad62ebd9-b234-4254-84be-99aa501063bd', 'E', 'Sangat seperti saya', 5);

-- Question 41: Inclusion (Inclusive Communication) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya biasanya langsung melanjutkan permainan meskipun teman belum memahami apa yang saya maksud.', 41);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('c8aa4f95-c13a-4495-b844-41811b904ef4', '3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'A', 'Sangat tidak seperti saya', 5),
  ('94751aee-b07f-4b1f-834b-b0ee5c19ba9c', '3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'B', 'Tidak seperti saya', 4),
  ('df4b7090-58eb-4c0a-ad05-18133263ce64', '3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'C', 'Kadang seperti saya', 3),
  ('92db8d81-1dd6-409b-a3ae-3b5cd4701be3', '3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'D', 'Seperti Saya', 2),
  ('087cb6a8-3e9e-4fd1-8de8-4fadbb4b020b', '3ca80445-c02a-4dec-b2b6-9adaa64f3772', 'E', 'Sangat seperti saya', 1);

-- Question 42: Inclusion (Inclusive Communication) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('94bebd5d-f69b-44d4-bc91-d16cac59e657', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya memastikan teman memahami apa yang saya maksud sebelum kami melanjutkan permainan.', 42);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('36226a4c-e0a3-4ad9-90f1-1576675c2681', '94bebd5d-f69b-44d4-bc91-d16cac59e657', 'A', 'Sangat tidak seperti saya', 1),
  ('58249712-a8ae-4de3-963d-cd6a8fa0c6ea', '94bebd5d-f69b-44d4-bc91-d16cac59e657', 'B', 'Tidak seperti saya', 2),
  ('55549086-3d94-4cdb-b89b-092bca72d349', '94bebd5d-f69b-44d4-bc91-d16cac59e657', 'C', 'Kadang seperti saya', 3),
  ('5eb805ae-7bdf-48e7-968a-8b0f6e93de1b', '94bebd5d-f69b-44d4-bc91-d16cac59e657', 'D', 'Seperti Saya', 4),
  ('84dcaf44-00a2-43fa-9162-64265a5a977a', '94bebd5d-f69b-44d4-bc91-d16cac59e657', 'E', 'Sangat seperti saya', 5);

-- Question 43: Inclusion (Appreciation of Diversity) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('7434e182-14b4-4519-ba23-80aa9eaac39e', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tetap nyaman bermain dengan teman yang memiliki kebiasaan atau latar belakang berbeda dengan saya.', 43);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('69de819a-e819-4bbe-b3b0-cd3f39489159', '7434e182-14b4-4519-ba23-80aa9eaac39e', 'A', 'Sangat tidak seperti saya', 1),
  ('469b61cd-d1ef-487b-81e6-1a89f48a18fc', '7434e182-14b4-4519-ba23-80aa9eaac39e', 'B', 'Tidak seperti saya', 2),
  ('4df95f70-1811-41f7-b263-4c8b36f38f30', '7434e182-14b4-4519-ba23-80aa9eaac39e', 'C', 'Kadang seperti saya', 3),
  ('4007f9c4-f0f7-4dbc-9776-d367444df5fe', '7434e182-14b4-4519-ba23-80aa9eaac39e', 'D', 'Seperti Saya', 4),
  ('a5664916-2295-41a8-be24-2364f37f49aa', '7434e182-14b4-4519-ba23-80aa9eaac39e', 'E', 'Sangat seperti saya', 5);

-- Question 44: Inclusion (Appreciation of Diversity) [-]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya lebih nyaman berada dalam kelompok yang memiliki kebiasaan yang sama dengan saya.', 44);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('51a4822d-1b26-4c3a-9277-7d42babc056c', 'f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'A', 'Sangat tidak seperti saya', 5),
  ('a9cab7ce-c4a0-4ea4-af81-131c43745395', 'f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'B', 'Tidak seperti saya', 4),
  ('4933d058-ff67-4d08-b30c-f9171e94b196', 'f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'C', 'Kadang seperti saya', 3),
  ('630a6431-6d82-4d4b-97ac-7270d68e27ba', 'f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'D', 'Seperti Saya', 2),
  ('6b89c118-6da5-49ee-a1d0-9ace70ac8e5d', 'f6d95bc8-5b3f-4876-8132-6cac0f15dd7a', 'E', 'Sangat seperti saya', 1);

-- Question 45: Inclusion (Appreciation of Diversity) [+]
INSERT INTO questions (id, challenge_id, question_text, question_number) VALUES ('40d04111-3f31-4984-bf1b-dcde45f2e889', 'a1b2c3d4-e5f6-7890-abcd-131313131313', 'Saya tertarik mengetahui cara bermain atau pengalaman olahraga yang berbeda dari yang biasa saya lakukan.', 45);
INSERT INTO options (id, question_id, option_label, option_text, score_option) VALUES
  ('668faf2f-2915-4b46-bb1d-bfd1078818f0', '40d04111-3f31-4984-bf1b-dcde45f2e889', 'A', 'Sangat tidak seperti saya', 1),
  ('6f78ab2c-5705-4fa5-8375-8dbbcb2cc516', '40d04111-3f31-4984-bf1b-dcde45f2e889', 'B', 'Tidak seperti saya', 2),
  ('878c290a-5702-470d-b113-58bf3e30cd7f', '40d04111-3f31-4984-bf1b-dcde45f2e889', 'C', 'Kadang seperti saya', 3),
  ('0e21385d-90dc-4357-96e7-56a2427dd6a9', '40d04111-3f31-4984-bf1b-dcde45f2e889', 'D', 'Seperti Saya', 4),
  ('4df17786-3237-471f-99c0-4cfa5354ceeb', '40d04111-3f31-4984-bf1b-dcde45f2e889', 'E', 'Sangat seperti saya', 5);
