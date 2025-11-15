-- ============================================
-- SEED SAHABIGUIDE - VERSION SPIRITUELLE ET INTERACTIVE V2
-- ============================================

DELETE FROM conversation_sessions;
DELETE FROM user_conversation_progress;
DELETE FROM conversation_steps;

-- ============================================
-- ÉTAPES DU HAJJ - VERSION ENRICHIE ET GUIDÉE
-- ============================================

INSERT INTO conversation_steps (
  step_code, step_order, question, question_en, question_ar,
  answer_type, answer_options_json, navigation_rules_json,
  next_step_code, is_critical, reminder_after_hours
) VALUES

-- ========================================
-- ACCUEIL & MOTIVATION
-- ========================================

('WELCOME', 1,
 '👋 Assalam Alaykoum, cher pèlerin ! Je suis ton compagnon SahabiGuide, ici pour t’aider à vivre ton Hajj dans la sérénité. Comment te sens-tu aujourd’hui ?',
 'Assalam Alaykum dear pilgrim! I am your SahabiGuide companion, here to help you live your Hajj with serenity. How do you feel today?',
 'السلام عليكم أيها الحاج العزيز! أنا رفيقك سحابي جايد، هنا لأساعدك على أداء حجك بطمأنينة. كيف تشعر اليوم؟',
 'MULTIPLE_CHOICE',
 '["Heureux et motivé 🤩", "Un peu stressé 😰", "Curieux d’apprendre 🤔", "Prêt à commencer 💪"]'::jsonb,
 '{"HEUREUX ET MOTIVE": "MOTIVATION_POSITIVE", "UN PEU STRESSE": "REASSURANCE", "CURIEUX D APPRENDRE": "MOTIVATION_POSITIVE", "PRET A COMMENCER": "MOTIVATION_POSITIVE"}'::jsonb,
 'MOTIVATION_POSITIVE', false, NULL),

('MOTIVATION_POSITIVE', 2,
 '✨ MachaAllah ! Le Hajj est une école du cœur. Sais-tu qu’il est l’un des cinq piliers de l’Islam ?',
 'MashAllah! Hajj is a school of the heart. Did you know it is one of the five pillars of Islam?',
 'ما شاء الله! الحج مدرسة للقلب. هل تعلم أنه أحد أركان الإسلام الخمسة؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "HAJJ_PILLARS_EXPLANATION"}'::jsonb,
 'HAJJ_BASICS', true, 24,
 'Le Prophète ﷺ a dit : "L’Islam est bâti sur cinq piliers", et le Hajj en fait partie.'),
 
('REASSURANCE', 3,
 '🤗 C’est normal d’avoir un peu de stress. Le Hajj est un grand voyage, mais tu n’es pas seul. On va avancer doucement ensemble. Prêt à commencer ?',
 'It is normal to feel a bit stressed. Hajj is a great journey, but you are not alone. Shall we begin together?',
 'من الطبيعي أن تشعر ببعض التوتر. الحج رحلة عظيمة، لكنك لست وحدك. هل نبدأ معًا؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "HAJJ_BASICS"}'::jsonb,
 'HAJJ_BASICS', false, NULL,
 'Chaque pas vers le Hajj est une purification du cœur. Respire, et avance avec confiance.'),

-- ========================================
-- BASES DU HAJJ
-- ========================================

('HAJJ_PILLARS_EXPLANATION', 4,
 '📚 Les 5 piliers de l’Islam : la Chahada, la Salat, la Zakat, le Jeûne, et le Hajj. Le Hajj, c’est le voyage du cœur vers Allah. Tu veux que je t’explique pourquoi il est si spécial ?',
 'The 5 pillars of Islam: Shahada, Prayer, Charity, Fasting, and Hajj. Hajj is the journey of the heart to Allah. Shall I explain why it is so special?',
 'أركان الإسلام الخمسة: الشهادة، الصلاة، الزكاة، الصيام، والحج. الحج هو رحلة القلب إلى الله. هل أشرح لك لماذا هو مميز؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_MEANING", "NON": "HAJJ_BASICS"}'::jsonb,
 'HAJJ_MEANING', false, 12,
 'Le Hajj n’est pas qu’un rite : c’est une renaissance spirituelle.'),
 
('HAJJ_MEANING', 5,
 '🌍 Le Hajj rassemble des millions de croyants du monde entier. C’est un moment où l’on oublie les différences, et où l’on se rappelle qu’on est tous égaux devant Allah. C’est clair ?',
 'Hajj gathers millions of believers from all around the world. We forget our differences and remember that we are all equal before Allah. Is that clear?',
 'يجمع الحج ملايين المؤمنين من جميع أنحاء العالم. ننسى اختلافاتنا ونتذكر أننا جميعًا متساوون أمام الله. هل هذا واضح؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "HAJJ_BASICS"}'::jsonb,
 'HAJJ_BASICS', false, NULL,
 'Quand ton cœur comprend cette égalité, ton Hajj commence déjà à l’intérieur.'),

('HAJJ_BASICS', 6,
 '🕋 Le Hajj a lieu chaque année pendant Dhul Hijjah, le 12ᵉ mois du calendrier islamique. Tu te rappelles de ce mois ?',
 'Hajj takes place in Dhul Hijjah, the 12th month of the Islamic calendar. Do you remember it?',
 'يحدث الحج في شهر ذو الحجة، الشهر الثاني عشر من التقويم الإسلامي. هل تتذكره؟',
 'MULTIPLE_CHOICE',
 '["Oui, le 12e 🌙", "Non, je ne sais plus 🤔", "Je croyais que c’était Ramadan"]'::jsonb,
 '{"OUI LE 12E": "HAJJ_DATES", "JE CROYAIS QUE C ETAIT RAMADAN": "HAJJ_MONTH_CORRECTION", "NON JE NE SAIS PLUS": "HAJJ_MONTH_EXPLANATION"}'::jsonb,
 'HAJJ_DATES', false, NULL,
 'Savoir quand le Hajj a lieu, c’est déjà te préparer à y penser chaque année.'),

('HAJJ_MONTH_CORRECTION', 7,
 '🌙 Presque ! Ramadan, c’est le 9e mois. Le Hajj se déroule pendant **Dhul Hijjah**, le 12ᵉ et dernier mois. Prêt à découvrir ce qui s’y passe ?',
 'Almost! Ramadan is the 9th month. Hajj takes place during Dhul Hijjah, the 12th and last month. Ready to discover what happens then?',
 'تقريبًا! رمضان هو الشهر التاسع. يحدث الحج في ذو الحجة، الشهر الثاني عشر والأخير. هل أنت مستعد لتكتشف ما يحدث فيه؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_DATES", "NON": "HAJJ_DATES"}'::jsonb,
 'HAJJ_DATES', false, NULL,
 'Chaque mois a sa bénédiction, mais Dhul Hijjah est celui du pardon et du retour à Allah.'),

-- ========================================
-- DATES & ARAFAT
-- ========================================

('HAJJ_DATES', 8,
 '📅 Le Hajj dure 5 à 6 jours, du 8 au 13 Dhul Hijjah. Le 9 Dhul Hijjah est le jour d’Arafat, le plus sacré. Tu sais ce qu’on y fait ?',
 'Hajj lasts 5 to 6 days, from 8th to 13th Dhul Hijjah. The 9th is the day of Arafat, the most sacred. Do you know what happens there?',
 'يستمر الحج 5 إلى 6 أيام من 8 إلى 13 ذو الحجة. اليوم التاسع هو يوم عرفة، الأكثر قداسة. هل تعرف ماذا يحدث هناك؟',
 'MULTIPLE_CHOICE',
 '["Invocation et prière 🤲", "Tawaf 🕋", "Sacrifice 🐑", "Je ne sais pas 🤔"]'::jsonb,
 '{"INVOCATION ET PRIERE": "ARAFAT_IMPORTANCE", "TAWAF": "ARAFAT_CORRECTION", "SACRIFICE": "ARAFAT_CORRECTION", "JE NE SAIS PAS": "ARAFAT_EXPLANATION"}'::jsonb,
 'ARAFAT_IMPORTANCE', true, 48,
 'Le Prophète ﷺ a dit : “Le Hajj, c’est Arafat.” C’est le sommet du voyage spirituel.'),

('ARAFAT_EXPLANATION', 9,
 '⛰️ À Arafat, les pèlerins passent l’après-midi à invoquer Allah, les mains levées, le cœur pur. C’est un moment d’émotion et de retour vers Lui. Tu te sens prêt à le vivre, toi aussi un jour ?',
 'At Arafat, pilgrims spend the afternoon invoking Allah with raised hands and pure hearts. It is emotional and deeply spiritual. Do you feel ready to live it one day?',
 'في عرفة، يقضي الحجاج فترة بعد الظهر يدعون الله بأيدٍ مرفوعة وقلوبٍ طاهرة. إنه لحظة مؤثرة. هل تشعر أنك مستعد لتعيشها يومًا ما؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_INTRO", "NON": "IHRAM_INTRO"}'::jsonb,
 'IHRAM_INTRO', false, NULL,
 'Arafat est le jour où le croyant renaît. Chaque prière y est entendue.'),

-- ========================================
-- IHRAM
-- ========================================

('IHRAM_INTRO', 10,
 '🕊️ Avant de partir au Hajj, on entre dans un état appelé **Ihram**. C’est une pureté du corps et du cœur. Tu veux savoir comment le vivre correctement ?',
 'Before starting Hajj, we enter the state of **Ihram** – purity of body and soul. Do you want to know how to live it properly?',
 'قبل بدء الحج، ندخل في حالة **الإحرام**، وهي طهارة للجسد والروح. هل تريد أن تعرف كيف تعيشها بشكل صحيح؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_DETAILS", "NON": "IHRAM_DETAILS"}'::jsonb,
 'IHRAM_DETAILS', true, 24,
 'L’Ihram, c’est comme dire à ton âme : “Je laisse derrière moi le monde pour me tourner vers Toi, Ya Allah.”'),

('IHRAM_DETAILS', 11,
 '👕 L’Ihram, c’est deux tissus blancs pour les hommes, et des habits modestes pour les femmes. Mais plus important encore : c’est l’intention pure dans ton cœur. Tu veux connaître les interdits de cet état ?',
 'Ihram means two white cloths for men and modest clothing for women. But above all, it is pure intention. Want to know the prohibitions?',
 'الإحرام يعني ثوبين أبيضين للرجال وملابس محتشمة للنساء. ولكن الأهم هو النية الصافية. هل تريد معرفة المحظورات؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_PROHIBITIONS", "NON": "IHRAM_PROHIBITIONS"}'::jsonb,
 'IHRAM_PROHIBITIONS', false, NULL,
 'L’habit blanc rappelle que nous reviendrons tous à Allah, égaux et sans richesse.'),

('IHRAM_PROHIBITIONS', 12,
 '🚫 En état d’Ihram, certaines actions sont interdites : à ton avis, lesquelles ?',
 'In Ihram, some actions are forbidden. Which ones do you think?',
 'في الإحرام، بعض الأفعال محرمة. أيها تعتقد؟',
 'MULTIPLE_CHOICE',
 '["Se parfumer 💐", "Manger 🍽️", "Marcher 🚶", "Dormir 😴"]'::jsonb,
 '{"SE PARFUMER": "IHRAM_CORRECT", "MANGER": "IHRAM_EXPLAIN", "MARCHER": "IHRAM_EXPLAIN", "DORMIR": "IHRAM_EXPLAIN"}'::jsonb,
 'IHRAM_CORRECT', true, 24,
 'Pendant l’Ihram, tu apprends à te contrôler, à vivre dans la patience et la pureté.'),

('IHRAM_EXPLAIN', 13,
 '🍃 Manger et marcher sont permis. Ce qui est interdit, c’est tout ce qui brise la pureté : parfum, coupe de cheveux, chasse, intimité. Le secret, c’est de rester concentré sur Allah. On continue ?',
 'Eating and walking are allowed. Forbidden acts break purity: perfume, hair cutting, intimacy. The secret is staying focused on Allah. Continue?',
 'الأكل والمشي مسموحان. المحظورات هي كل ما يكسر الطهارة: العطر، قص الشعر، العلاقة الزوجية. السر هو البقاء مركزًا على الله. نكمل؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "TAWAF_INTRO"}'::jsonb,
 'TAWAF_INTRO', false, NULL,
 'Chaque interdiction est un apprentissage : moins de confort, plus de spiritualité.'),

('IHRAM_CORRECT', 14,
 '✅ Bravo ! Tu as raison : se parfumer est interdit. L’Ihram t’apprend la simplicité et l’humilité. Prêt à passer au Tawaf ?',
 'Correct! Perfume is forbidden. Ihram teaches simplicity and humility. Ready for Tawaf?',
 'صحيح! العطر محرم. الإحرام يعلم البساطة والتواضع. هل أنت مستعد للطواف؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "TAWAF_INTRO"}'::jsonb,
 'TAWAF_INTRO', false, NULL,
 'Quand tu enlèves le parfum, c’est ton ego que tu purifies.'),

-- ========================================
-- TAWAF
-- ========================================

('TAWAF_INTRO', 15,
 '🕋 Le **Tawaf**, c’est tourner 7 fois autour de la Kaaba, le cœur du monde musulman. Tu veux que je t’explique comment bien le vivre ?',
 'Tawaf means circling 7 times around the Kaaba, the heart of the Muslim world. Shall I explain how to live it well?',
 'الطواف هو الدوران سبع مرات حول الكعبة، قلب العالم الإسلامي. هل أشرح لك كيف تعيشه جيدًا؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_DETAILS", "NON": "TAWAF_DETAILS"}'::jsonb,
 'TAWAF_DETAILS', true, 24,
 'Tourner autour de la Kaaba, c’est tourner autour du souvenir d’Allah dans ton cœur.'),

('TAWAF_DETAILS', 16,
 '🌙 Tu fais 7 tours, en gardant la Kaaba sur ta gauche. À chaque tour, tu peux réciter des invocations ou simplement penser à Allah. Tu veux un exemple de douâ ?',
 'You make 7 rounds, keeping the Kaaba on your left. Each time, you may pray or reflect. Want an example of a du’a?',
 'تدور 7 مرات، مع إبقاء الكعبة على يسارك. في كل مرة يمكنك الدعاء أو التفكير بالله. هل تريد مثالاً على دعاء؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_DUA", "NON": "SAI_INTRO"}'::jsonb,
 'TAWAF_DUA', false, NULL,
 'Le Tawaf t’enseigne la constance : chaque tour est un rappel que la foi se construit par la répétition.'),

('TAWAF_DUA', 17,
 '🤲 Par exemple : "SubhanAllah, wal hamdulillah, wa la ilaha illa Allah, wa Allahu akbar." Simple, mais puissant. Prêt à passer au Sa’i ?',
 'For example: "SubhanAllah, wal hamdulillah, wa la ilaha illa Allah, wa Allahu akbar." Simple but powerful. Ready for Sa’i?',
 'على سبيل المثال: "سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر." بسيط لكنه قوي. هل أنت مستعد للسعي؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_INTRO", "NON": "SAI_INTRO"}'::jsonb,
 'SAI_INTRO', false, NULL,
 'Les mots simples faits avec sincérité valent plus que les discours vides.'),

-- ========================================
-- SA’I & ARAFAT FINAL
-- ========================================

('SAI_INTRO', 18,
 '🚶‍♂️ Le **Sa’i** : c’est aller-retour entre Safâ et Marwah, en souvenir de Hajar, la mère d’Ismaël. Tu connais son histoire ?',
 'Sa’i: walking between Safa and Marwah, in memory of Hajar. Do you know her story?',
 'السعي: المشي بين الصفا والمروة، تذكيرًا بهاجر. هل تعرف قصتها؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_STORY"}'::jsonb,
 'SAI_DETAILS', true, 24,
 'Chaque pas dans le Sa’i est une prière silencieuse pour la confiance en Allah.'),

('SAI_STORY', 19,
 '💧 Hajar courait entre les collines pour chercher de l’eau pour son fils Ismaël. Par sa patience, Allah a fait jaillir Zamzam. Tu vois la beauté de cette foi ?',
 'Hajar ran between the hills seeking water for Ismail. Through her patience, Allah made Zamzam flow. Do you see the beauty of this faith?',
 'هاجر ركضت بين الجبلين بحثًا عن الماء لإسماعيل. بصبرها، فجّر الله زمزم. هل ترى جمال هذا الإيمان؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_DETAILS"}'::jsonb,
 'SAI_DETAILS', false, NULL,
 'La foi, c’est avancer même quand tout semble sec. Allah ne déçoit jamais.'),

('SAI_DETAILS', 20,
 '🏃 Les hommes accélèrent entre les deux lumières vertes, comme Hajar. Les femmes marchent normalement. Le secret, c’est l’intention. Prêt pour la dernière étape : Arafat ?',
 'Men accelerate between the green lights, like Hajar. Women walk normally. Ready for Arafat?',
 'يسرع الرجال بين الضوءين الأخضرين مثل هاجر. تمشي النساء عادة. هل أنت مستعد لعرفة؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_RECAP", "NON": "ARAFAT_RECAP"}'::jsonb,
 'ARAFAT_RECAP', false, NULL,
 'Chaque effort dans le Sa’i te rapproche d’Allah, même les petites courses du cœur.'),

('ARAFAT_RECAP', 21,
 '⛰️ À **Arafat**, on passe l’après-midi à prier, à demander pardon et à pleurer son retour à Allah. C’est le sommet du Hajj. Te sens-tu prêt à vivre un tel moment ?',
 'At **Arafat**, we pray, we ask forgiveness, we cry our return to Allah. It is the peak of Hajj. Do you feel ready to live it?',
 'في **عرفة**، نصلي، نستغفر، ونبكي عودتنا إلى الله. إنها قمة الحج. هل تشعر أنك مستعد لتعيشها؟',
 'YES_NO',
 NULL,
 '{"OUI": "CONGRATULATIONS", "NON": "CONGRATULATIONS"}'::jsonb,
 'CONGRATULATIONS', true, 48,
 'Arafat, c’est la journée où Allah se vante de Ses serviteurs auprès des anges : “Regardez Mes serviteurs, venus vers Moi, couverts de poussière et d’humilité.”'),

('CONGRATULATIONS', 22,
 '🎉 **Mabrouk !** Tu as terminé l’apprentissage spirituel du Hajj. Qu’Allah t’accorde d’y aller et d’en revenir purifié. 🌙 Tu veux que je t’envoie un résumé de ton parcours ?',
 'Mabrouk! You completed the spiritual Hajj training. May Allah grant you the chance to go and return purified. Do you want a summary?',
 'مبروك! لقد أكملت التعلم الروحي للحج. نسأل الله أن يرزقك الحج والعودة طاهرًا. هل تريد ملخصًا لمسارك؟',
 'YES_NO',
 NULL,
 '{"OUI": "SUMMARY_SEND", "NON": "SUMMARY_SEND"}'::jsonb,
 NULL, false, NULL,
 'Qu’Allah accepte ton intention, même si ton corps n’a pas encore foulé la terre sainte. Le Hajj commence dans ton cœur. 🙏');
