-- ============================================
-- SEED ASSISTANT - 24 Étapes (VERSION CORRIGÉE)
-- ============================================
-- Navigation Rules: Les clés DOIVENT être en MAJUSCULES
-- pour correspondre à answer.toUpperCase() dans le code Flutter
-- ============================================

-- Suppression des données existantes
DELETE FROM conversation_sessions;
DELETE FROM user_conversation_progress;
DELETE FROM conversation_steps;

-- ============================================
-- INSERTION DES 24 ÉTAPES
-- ============================================

INSERT INTO conversation_steps (step_code, step_order, question, question_en, question_ar, answer_type, answer_options_json, navigation_rules_json, next_step_code, is_critical, reminder_after_hours) VALUES

-- 1. Introduction
('HAJJ_INTRO', 1, 
 'Salam Alaykoum ! 👋 Je suis votre assistant personnel pour le Hajj. Es-tu prêt à commencer ton apprentissage ?',
 'Salam Alaykoum! I am your personal Hajj assistant. Are you ready to start your learning?',
 'السلام عليكم! أنا مساعدك الشخصي للحج. هل أنت مستعد لبدء التعلم؟',
 'YES_NO', 
 NULL,
 '{"OUI": "HAJJ_PREPARATION", "NON": "HAJJ_MOTIVATION"}'::jsonb,
 'HAJJ_PREPARATION', true, 24),

-- 2. Préparation
('HAJJ_PREPARATION', 2,
 'As-tu déjà commencé à te préparer spirituellement pour le Hajj ?',
 'Have you already started preparing spiritually for Hajj?',
 'هل بدأت بالفعل في الاستعداد الروحي للحج؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_KNOWLEDGE", "NON": "SPIRITUAL_PREP_TIPS"}'::jsonb,
 'IHRAM_KNOWLEDGE', true, 48),

-- 3. Motivation
('HAJJ_MOTIVATION', 3,
 'Qu''est-ce qui te retient de commencer ton apprentissage maintenant ?',
 'What is holding you back from starting your learning now?',
 'ما الذي يمنعك من بدء التعلم الآن؟',
 'TEXT',
 NULL,
 '{"default": "HAJJ_PREPARATION"}'::jsonb,
 'HAJJ_PREPARATION', false, 12),

-- 4. Connaissance Ihram
('IHRAM_KNOWLEDGE', 4,
 'Connais-tu les obligations de l''Ihram (état de sacralisation) ?',
 'Do you know the obligations of Ihram (state of consecration)?',
 'هل تعرف واجبات الإحرام (حالة التقديس)؟',
 'MULTIPLE_CHOICE',
 '["Oui, je connais bien", "J''en ai une idée", "Non, pas du tout"]'::jsonb,
 '{"OUI, JE CONNAIS BIEN": "TAWAF_INTRO", "J''EN AI UNE IDÉE": "IHRAM_DETAILS", "NON, PAS DU TOUT": "IHRAM_BASICS"}'::jsonb,
 'TAWAF_INTRO', true, 24),

-- 5. Conseils de préparation spirituelle
('SPIRITUAL_PREP_TIPS', 5,
 'Je te recommande de commencer par la prière et la lecture du Coran. Es-tu d''accord pour débuter ?',
 'I recommend starting with prayer and reading the Quran. Do you agree to start?',
 'أوصي بالبدء بالصلاة وقراءة القرآن. هل توافق على البدء؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_KNOWLEDGE", "NON": "SPIRITUAL_RESOURCES"}'::jsonb,
 'IHRAM_KNOWLEDGE', false, 12),

-- 6. Bases de l'Ihram
('IHRAM_BASICS', 6,
 'L''Ihram est l''état de pureté rituelle. Veux-tu en apprendre les règles ?',
 'Ihram is the state of ritual purity. Do you want to learn its rules?',
 'الإحرام هو حالة الطهارة الطقسية. هل تريد أن تتعلم قواعده؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_DETAILS", "NON": "TAWAF_INTRO"}'::jsonb,
 'IHRAM_DETAILS', true, 24),

-- 7. Détails de l'Ihram
('IHRAM_DETAILS', 7,
 'Les principales interdictions en Ihram : se parfumer, se couper les ongles/cheveux, avoir des relations. As-tu compris ?',
 'The main prohibitions in Ihram: perfume, cutting nails/hair, relations. Have you understood?',
 'المحظورات الرئيسية في الإحرام: العطر، قص الأظافر/الشعر، العلاقات. هل فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "IHRAM_FAQ"}'::jsonb,
 'TAWAF_INTRO', true, 48),

-- 8. FAQ Ihram
('IHRAM_FAQ', 8,
 'Pose-moi ta question sur l''Ihram (ou écris "Continuer" pour passer)',
 'Ask me your question about Ihram (or write "Continue" to skip)',
 'اسألني سؤالك عن الإحرام (أو اكتب "متابعة" للتخطي)',
 'TEXT',
 NULL,
 '{"default": "TAWAF_INTRO"}'::jsonb,
 'TAWAF_INTRO', false, NULL),

-- 9. Introduction au Tawaf
('TAWAF_INTRO', 9,
 '🕋 Le Tawaf est la circumambulation autour de la Kaaba. Connais-tu le nombre de tours ?',
 'Tawaf is the circumambulation around the Kaaba. Do you know the number of rounds?',
 'الطواف هو الدوران حول الكعبة. هل تعرف عدد الأشواط؟',
 'MULTIPLE_CHOICE',
 '["7 tours", "5 tours", "Je ne sais pas"]'::jsonb,
 '{"7 TOURS": "TAWAF_DIRECTION", "5 TOURS": "TAWAF_CORRECTION", "JE NE SAIS PAS": "TAWAF_EXPLAIN"}'::jsonb,
 'TAWAF_DIRECTION', true, 24),

-- 10. Explication Tawaf
('TAWAF_EXPLAIN', 10,
 'Le Tawaf se fait en 7 tours autour de la Kaaba. C''est un pilier du Hajj. Prêt à continuer ?',
 'Tawaf is done in 7 rounds around the Kaaba. It is a pillar of Hajj. Ready to continue?',
 'يتم الطواف في 7 أشواط حول الكعبة. إنه ركن من أركان الحج. مستعد للمتابعة؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_DIRECTION", "NON": "TAWAF_DETAILS_LATER"}'::jsonb,
 'TAWAF_DIRECTION', false, 12),

-- 11. Correction Tawaf
('TAWAF_CORRECTION', 11,
 'Pas tout à fait ! Le Tawaf est de 7 tours, pas 5. Veux-tu en savoir plus ?',
 'Not quite! Tawaf is 7 rounds, not 5. Do you want to know more?',
 'ليس تمامًا! الطواف 7 أشواط، وليس 5. هل تريد معرفة المزيد؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_EXPLAIN", "NON": "TAWAF_DIRECTION"}'::jsonb,
 'TAWAF_DIRECTION', false, 12),

-- 12. Direction Tawaf
('TAWAF_DIRECTION', 12,
 'Dans quel sens tourne-t-on autour de la Kaaba ?',
 'In which direction do we circle around the Kaaba?',
 'في أي اتجاه ندور حول الكعبة؟',
 'MULTIPLE_CHOICE',
 '["Antihoraire", "Horaire", "Peu importe"]'::jsonb,
 '{"ANTIHORAIRE": "SAI_INTRO", "HORAIRE": "TAWAF_DIRECTION_CORRECTION", "PEU IMPORTE": "TAWAF_DIRECTION_CORRECTION"}'::jsonb,
 'SAI_INTRO', true, 24),

-- 13. Correction Direction
('TAWAF_DIRECTION_CORRECTION', 13,
 'Correction : on tourne dans le sens inverse des aiguilles d''une montre (antihoraire), en gardant la Kaaba à gauche. Compris ?',
 'Correction: we turn counterclockwise, keeping the Kaaba on the left. Understood?',
 'تصحيح: ندور عكس اتجاه عقارب الساعة، مع إبقاء الكعبة على اليسار. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_INTRO", "NON": "TAWAF_DIRECTION"}'::jsonb,
 'SAI_INTRO', false, 12),

-- 14. Introduction Sa'i
('SAI_INTRO', 14,
 '🚶‍♂️ Le Sa''i est le parcours entre Safa et Marwa. Connais-tu le nombre d''allers-retours ?',
 'Sa''i is the walk between Safa and Marwa. Do you know the number of trips?',
 'السعي هو المسار بين الصفا والمروة. هل تعرف عدد الرحلات؟',
 'MULTIPLE_CHOICE',
 '["7 trajets", "5 trajets", "Je ne sais pas"]'::jsonb,
 '{"7 TRAJETS": "SAI_DETAILS", "5 TRAJETS": "SAI_CORRECTION", "JE NE SAIS PAS": "SAI_EXPLAIN"}'::jsonb,
 'SAI_DETAILS', true, 24),

-- 15. Explication Sa'i
('SAI_EXPLAIN', 15,
 'Le Sa''i comporte 7 trajets entre Safa et Marwa, en mémoire de Hajar. Compris ?',
 'Sa''i consists of 7 trips between Safa and Marwa, in memory of Hajar. Understood?',
 'يتكون السعي من 7 رحلات بين الصفا والمروة، تذكيرًا بهاجر. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_HISTORY"}'::jsonb,
 'SAI_DETAILS', false, 12),

-- 16. Correction Sa'i
('SAI_CORRECTION', 16,
 'Correction : c''est 7 trajets, pas 5 ! Veux-tu connaître l''histoire ?',
 'Correction: it''s 7 trips, not 5! Do you want to know the history?',
 'تصحيح: إنها 7 رحلات، وليس 5! هل تريد معرفة التاريخ؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_HISTORY", "NON": "SAI_DETAILS"}'::jsonb,
 'SAI_DETAILS', false, 12),

-- 17. Histoire Sa'i
('SAI_HISTORY', 17,
 'Le Sa''i rappelle la course de Hajar entre Safa et Marwa cherchant de l''eau pour Ismaël. Allah fit jaillir Zamzam. Émouvant, n''est-ce pas ?',
 'Sa''i recalls Hajar''s run between Safa and Marwa seeking water for Ishmael. Allah made Zamzam spring. Moving, isn''t it?',
 'يذكّر السعي بركض هاجر بين الصفا والمروة بحثًا عن الماء لإسماعيل. فجّر الله زمزم. مؤثر، أليس كذلك؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_DETAILS"}'::jsonb,
 'SAI_DETAILS', false, NULL),

-- 18. Détails Sa'i
('SAI_DETAILS', 18,
 'Pendant le Sa''i, on marche normalement sauf entre les deux lumières vertes où l''on court (hommes). Tu savais ?',
 'During Sa''i, we walk normally except between the two green lights where we run (men). Did you know?',
 'خلال السعي، نمشي بشكل طبيعي إلا بين الضوءين الأخضرين حيث نركض (الرجال). هل كنت تعلم؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_INTRO", "NON": "ARAFAT_INTRO"}'::jsonb,
 'ARAFAT_INTRO', false, 12),

-- 19. Introduction Arafat
('ARAFAT_INTRO', 19,
 '⛰️ Le jour d''Arafat est le jour le plus important du Hajj. Sais-tu ce qu''on y fait principalement ?',
 'The Day of Arafat is the most important day of Hajj. Do you know what we mainly do there?',
 'يوم عرفة هو أهم يوم في الحج. هل تعرف ماذا نفعل هناك بشكل رئيسي؟',
 'MULTIPLE_CHOICE',
 '["Prier et invoquer", "Faire le Tawaf", "Je ne sais pas"]'::jsonb,
 '{"PRIER ET INVOQUER": "ARAFAT_IMPORTANCE", "FAIRE LE TAWAF": "ARAFAT_CORRECTION", "JE NE SAIS PAS": "ARAFAT_EXPLAIN"}'::jsonb,
 'ARAFAT_IMPORTANCE', true, 48),

-- 20. Explication Arafat
('ARAFAT_EXPLAIN', 20,
 'À Arafat, on passe la journée en prières et invocations. Le Prophète ﷺ a dit : "Le Hajj, c''est Arafat". Compris ?',
 'At Arafat, we spend the day in prayers and supplications. The Prophet ﷺ said: "Hajj is Arafat". Understood?',
 'في عرفة، نقضي اليوم في الصلاة والدعاء. قال النبي ﷺ: "الحج عرفة". فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_IMPORTANCE", "NON": "ARAFAT_DETAILS"}'::jsonb,
 'ARAFAT_IMPORTANCE', false, 24),

-- 21. Correction Arafat
('ARAFAT_CORRECTION', 21,
 'Non, le Tawaf n''est pas fait à Arafat. À Arafat, on prie et invoque Allah toute la journée. Compris ?',
 'No, Tawaf is not done at Arafat. At Arafat, we pray and invoke Allah all day. Understood?',
 'لا، الطواف لا يتم في عرفة. في عرفة، نصلّي وندعو الله طوال اليوم. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_IMPORTANCE", "NON": "ARAFAT_EXPLAIN"}'::jsonb,
 'ARAFAT_IMPORTANCE', false, 12),

-- 22. Importance Arafat
('ARAFAT_IMPORTANCE', 22,
 'Sais-tu que manquer Arafat signifie rater le Hajj complet ?',
 'Do you know that missing Arafat means missing the complete Hajj?',
 'هل تعلم أن تفويت عرفة يعني تفويت الحج الكامل؟',
 'YES_NO',
 NULL,
 '{"OUI": "MUZDALIFAH_INTRO", "NON": "MUZDALIFAH_INTRO"}'::jsonb,
 'MUZDALIFAH_INTRO', true, 24),

-- 23. Introduction Muzdalifah
('MUZDALIFAH_INTRO', 23,
 '🌙 Après Arafat, on passe la nuit à Muzdalifah. On y ramasse aussi quelque chose... Quoi ?',
 'After Arafat, we spend the night in Muzdalifah. We also collect something there... What?',
 'بعد عرفة، نقضي الليل في مزدلفة. نجمع أيضًا شيئًا هناك... ماذا؟',
 'MULTIPLE_CHOICE',
 '["Des cailloux", "Du sable", "De l''eau"]'::jsonb,
 '{"DES CAILLOUX": "CONGRATULATIONS", "DU SABLE": "MUZDALIFAH_CORRECTION", "DE L''EAU": "MUZDALIFAH_CORRECTION"}'::jsonb,
 'CONGRATULATIONS', true, 24),

-- 24. Félicitations
('CONGRATULATIONS', 24,
 '🎉 Mabrouk ! Tu as terminé l''apprentissage des bases du Hajj ! Continue à apprendre et qu''Allah accepte ton Hajj. Amine !',
 'Congratulations! You have completed learning the basics of Hajj! Keep learning and may Allah accept your Hajj. Ameen!',
 'مبروك! لقد أكملت تعلم أساسيات الحج! استمر في التعلم وتقبل الله حجك. آمين!',
 'TEXT',
 NULL,
 NULL,
 NULL, false, NULL),

-- Étapes manquantes référencées
('SPIRITUAL_RESOURCES', 25,
 '📚 Je te recommande : lectures du Coran, livres sur le Hajj, vidéos éducatives. Prêt maintenant ?',
 'I recommend: Quran readings, Hajj books, educational videos. Ready now?',
 'أوصي بـ: قراءة القرآن، كتب عن الحج، مقاطع فيديو تعليمية. مستعد الآن؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_KNOWLEDGE", "NON": "IHRAM_KNOWLEDGE"}'::jsonb,
 'IHRAM_KNOWLEDGE', false, 12),

('TAWAF_DETAILS_LATER', 26,
 'Pas de problème. Reviens quand tu seras prêt ! Pour l''instant, continuons.',
 'No problem. Come back when you''re ready! For now, let''s continue.',
 'لا مشكلة. عد عندما تكون مستعدًا! في الوقت الحالي، لنتابع.',
 'TEXT',
 NULL,
 '{"default": "SAI_INTRO"}'::jsonb,
 'SAI_INTRO', false, NULL),

('ARAFAT_DETAILS', 27,
 'À Arafat, les pèlerins se tiennent en prière continue de midi jusqu''au coucher du soleil. C''est le cœur du Hajj.',
 'At Arafat, pilgrims stand in continuous prayer from noon until sunset. It is the heart of Hajj.',
 'في عرفة، يقف الحجاج في صلاة مستمرة من الظهر حتى غروب الشمس. إنه قلب الحج.',
 'TEXT',
 NULL,
 '{"default": "ARAFAT_IMPORTANCE"}'::jsonb,
 'ARAFAT_IMPORTANCE', false, 12),

('MUZDALIFAH_CORRECTION', 28,
 'Presque ! On ramasse des cailloux à Muzdalifah pour le rituel de la lapidation. Compris ?',
 'Almost! We collect pebbles at Muzdalifah for the stoning ritual. Understood?',
 'تقريبًا! نجمع الحصى في مزدلفة لطقوس الرجم. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "CONGRATULATIONS", "NON": "CONGRATULATIONS"}'::jsonb,
 'CONGRATULATIONS', false, 12);

-- ============================================
-- VÉRIFICATION
-- ============================================

SELECT COUNT(*) as "Nombre d'étapes" FROM conversation_steps;

-- Résultat attendu : 28 (24 principales + 4 étapes supplémentaires)

-- ============================================
-- FIN DU SCRIPT
-- ============================================

