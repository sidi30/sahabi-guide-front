-- ============================================
-- SEED ASSISTANT HAJJ - VERSION CONVERSATIONNELLE
-- ============================================
-- Style apprentissage naturel avec interactions variées
-- Navigation Rules : Clés NORMALISÉES (sans accents, sans apostrophes)
-- ============================================

-- Suppression des données existantes
DELETE FROM conversation_sessions;
DELETE FROM user_conversation_progress;
DELETE FROM conversation_steps;

-- ============================================
-- ÉTAPES DU HAJJ - VERSION CONVERSATIONNELLE
-- ============================================

INSERT INTO conversation_steps (step_code, step_order, question, question_en, question_ar, answer_type, answer_options_json, navigation_rules_json, next_step_code, is_critical, reminder_after_hours) VALUES

-- ========================================
-- INTRODUCTION & ACCUEIL (Étapes 1-3)
-- ========================================

-- 1. Accueil chaleureux
('WELCOME', 1, 
 '👋 Assalam Alaykoum ! Bienvenue dans ton compagnon de Hajj personnel. Je suis là pour t''accompagner dans ton apprentissage. Comment te sens-tu aujourd''hui ?',
 'Assalam Alaykoum! Welcome to your personal Hajj companion. I am here to guide you. How do you feel today?',
 'السلام عليكم! مرحبًا بك في رفيقك الشخصي للحج. أنا هنا لإرشادك. كيف تشعر اليوم؟',
 'MULTIPLE_CHOICE',
 '["Excité ! 🤩", "Un peu stressé 😰", "Curieux d''apprendre 🤔", "Prêt à commencer 💪"]'::jsonb,
 '{"EXCITE": "MOTIVATION_POSITIVE", "UN PEU STRESSE": "REASSURANCE", "CURIEUX D APPRENDRE": "MOTIVATION_POSITIVE", "PRET A COMMENCER": "MOTIVATION_POSITIVE"}'::jsonb,
 'MOTIVATION_POSITIVE', false, NULL),

-- 2. Motivation positive
('MOTIVATION_POSITIVE', 2,
 '✨ Excellente attitude ! Le Hajj est un voyage spirituel extraordinaire. Sais-tu que c''est l''un des 5 piliers de l''Islam ?',
 'Excellent attitude! Hajj is an extraordinary spiritual journey. Did you know it is one of the 5 pillars of Islam?',
 'موقف ممتاز! الحج رحلة روحية استثنائية. هل تعلم أنه أحد أركان الإسلام الخمسة؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "HAJJ_PILLARS_EXPLANATION"}'::jsonb,
 'HAJJ_BASICS', true, 24),

-- 3. Réassurance
('REASSURANCE', 3,
 '🤗 C''est tout à fait normal d''être un peu stressé. Je suis là pour rendre ton apprentissage facile et agréable. On y va étape par étape, d''accord ?',
 'It is completely normal to feel a bit stressed. I am here to make your learning easy and pleasant. Let us go step by step, okay?',
 'من الطبيعي تمامًا أن تشعر ببعض التوتر. أنا هنا لجعل تعلمك سهلاً وممتعًا. هيا نمضي خطوة بخطوة، حسنًا؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "WHAT_CONCERNS_YOU"}'::jsonb,
 'HAJJ_BASICS', false, 12),

-- 4. Préoccupations
('WHAT_CONCERNS_YOU', 4,
 'Qu''est-ce qui te préoccupe le plus concernant le Hajj ? Dis-moi tout, je suis là pour t''aider 😊',
 'What concerns you most about Hajj? Tell me everything, I am here to help you',
 'ما الذي يقلقك أكثر بشأن الحج؟ أخبرني بكل شيء، أنا هنا لمساعدتك',
 'TEXT',
 NULL,
 '{"DEFAULT": "HAJJ_BASICS"}'::jsonb,
 'HAJJ_BASICS', false, NULL),

-- ========================================
-- BASES DU HAJJ (Étapes 5-8)
-- ========================================

-- 5. Explication des 5 piliers
('HAJJ_PILLARS_EXPLANATION', 5,
 '📚 Les 5 piliers de l''Islam sont : la Chahada, la Salat (prière), la Zakat (aumône), le Jeûne du Ramadan, et le Hajj. Le Hajj est obligatoire une fois dans la vie pour ceux qui en ont les moyens. C''est clair ?',
 'The 5 pillars of Islam are: Shahada, Salat (prayer), Zakat (charity), Ramadan Fasting, and Hajj. Hajj is obligatory once in a lifetime for those who can afford it. Is that clear?',
 'أركان الإسلام الخمسة هي: الشهادة، الصلاة، الزكاة، صيام رمضان، والحج. الحج واجب مرة واحدة في العمر لمن استطاع إليه سبيلاً. هل هذا واضح؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_BASICS", "NON": "HAJJ_PILLARS_EXPLANATION"}'::jsonb,
 'HAJJ_BASICS', false, 12),

-- 6. Bases du Hajj
('HAJJ_BASICS', 6,
 '🕋 Maintenant, parlons du Hajj ! Il se déroule chaque année pendant le mois de Dhul Hijjah. Tu te souviens de quel mois du calendrier islamique c''est ?',
 'Now, let us talk about Hajj! It takes place every year during the month of Dhul Hijjah. Do you remember which month of the Islamic calendar it is?',
 'الآن، لنتحدث عن الحج! يحدث كل عام خلال شهر ذو الحجة. هل تتذكر أي شهر من التقويم الإسلامي هو؟',
 'MULTIPLE_CHOICE',
 '["Le 12ème mois 🌙", "Le 9ème mois 🌙", "Le dernier mois 🌙", "Je ne sais pas 🤔"]'::jsonb,
 '{"LE 12EME MOIS": "HAJJ_DATES", "LE 9EME MOIS": "HAJJ_MONTH_CORRECTION", "LE DERNIER MOIS": "HAJJ_DATES", "JE NE SAIS PAS": "HAJJ_MONTH_EXPLANATION"}'::jsonb,
 'HAJJ_DATES', true, 24),

-- 7. Correction mois
('HAJJ_MONTH_CORRECTION', 7,
 '🌙 Le 9ème mois c''est Ramadan ! Dhul Hijjah est le 12ème et dernier mois du calendrier islamique. C''est durant ce mois sacré que se déroule le Hajj. Compris ?',
 'The 9th month is Ramadan! Dhul Hijjah is the 12th and last month of the Islamic calendar. It is during this sacred month that Hajj takes place. Understood?',
 'الشهر التاسع هو رمضان! ذو الحجة هو الشهر الثاني عشر والأخير من التقويم الإسلامي. خلال هذا الشهر المقدس يحدث الحج. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_DATES", "NON": "HAJJ_MONTH_EXPLANATION"}'::jsonb,
 'HAJJ_DATES', false, 12),

-- 8. Explication mois
('HAJJ_MONTH_EXPLANATION', 8,
 'Pas de souci ! Dhul Hijjah = 12ème mois islamique = mois du Hajj. C''est simple à retenir : Dhul **Hijjah** = mois du **Hajj** 😊 On continue ?',
 'No worries! Dhul Hijjah = 12th Islamic month = month of Hajj. Easy to remember: Dhul Hijjah = Hajj month 😊 Shall we continue?',
 'لا تقلق! ذو الحجة = الشهر الإسلامي الثاني عشر = شهر الحج. من السهل تذكره: ذو الحجة = شهر الحج 😊 هل نستمر؟',
 'YES_NO',
 NULL,
 '{"OUI": "HAJJ_DATES", "NON": "HAJJ_DATES"}'::jsonb,
 'HAJJ_DATES', false, NULL),

-- ========================================
-- DATES & DURÉE (Étapes 9-10)
-- ========================================

-- 9. Dates importantes
('HAJJ_DATES', 9,
 '📅 Le Hajj dure environ 5-6 jours, du 8 au 13 Dhul Hijjah. La journée la plus importante est le 9 Dhul Hijjah. Tu sais ce qui se passe ce jour-là ?',
 'Hajj lasts about 5-6 days, from the 8th to the 13th of Dhul Hijjah. The most important day is the 9th of Dhul Hijjah. Do you know what happens on that day?',
 'يستمر الحج حوالي 5-6 أيام، من 8 إلى 13 ذو الحجة. اليوم الأهم هو 9 ذو الحجة. هل تعرف ما يحدث في ذلك اليوم؟',
 'MULTIPLE_CHOICE',
 '["Le jour d''Arafat ⛰️", "Le jour du Tawaf 🕋", "Le jour du sacrifice 🐑", "Je ne sais pas encore 🤔"]'::jsonb,
 '{"LE JOUR D ARAFAT": "ARAFAT_IMPORTANCE", "LE JOUR DU TAWAF": "ARAFAT_CORRECTION", "LE JOUR DU SACRIFICE": "ARAFAT_CORRECTION", "JE NE SAIS PAS ENCORE": "ARAFAT_EXPLANATION"}'::jsonb,
 'ARAFAT_IMPORTANCE', true, 48),

-- 10. Correction Arafat
('ARAFAT_CORRECTION', 10,
 '❌ Pas tout à fait ! Le 9 Dhul Hijjah c''est le jour d''**Arafat**, pas le Tawaf ou le sacrifice. C''est LE jour le plus important du Hajj. Le Prophète ﷺ a dit : "Le Hajj, c''est Arafat". Maintenant tu sais ?',
 'Not quite! The 9th of Dhul Hijjah is the day of **Arafat**, not Tawaf or sacrifice. It is THE most important day of Hajj. The Prophet ﷺ said: "Hajj is Arafat". Now you know?',
 'ليس تمامًا! 9 ذو الحجة هو يوم **عرفة**، وليس الطواف أو الذبح. إنه اليوم الأكثر أهمية في الحج. قال النبي ﷺ: "الحج عرفة". هل تعلم الآن؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_EXPLANATION", "NON": "ARAFAT_EXPLANATION"}'::jsonb,
 'ARAFAT_EXPLANATION', false, 12),

-- 11. Explication Arafat
('ARAFAT_EXPLANATION', 12,
 '⛰️ C''est le jour d''Arafat ! C''est le moment le plus sacré du Hajj. Le Prophète ﷺ a dit : "Le Hajj, c''est Arafat". Ce jour-là, les pèlerins se tiennent en prière de midi jusqu''au coucher du soleil. Impressionnant, non ?',
 'It is the Day of Arafat! It is the most sacred moment of Hajj. The Prophet ﷺ said: "Hajj is Arafat". On that day, pilgrims stand in prayer from noon until sunset. Impressive, right?',
 'إنه يوم عرفة! إنه اللحظة الأكثر قدسية في الحج. قال النبي ﷺ: "الحج عرفة". في ذلك اليوم، يقف الحجاج في الصلاة من الظهر حتى غروب الشمس. مثير للإعجاب، أليس كذلك؟',
 'YES_NO',
 NULL,
 '{"OUI": "ARAFAT_IMPORTANCE", "NON": "ARAFAT_IMPORTANCE"}'::jsonb,
 'ARAFAT_IMPORTANCE', false, 24),

-- ========================================
-- IHRAM (Étapes 12-16)
-- ========================================

-- 12. Importance Arafat  
('ARAFAT_IMPORTANCE', 13,
 '💫 Excellent ! Maintenant, avant de partir au Hajj, il faut d''abord se mettre en état d''Ihram. C''est un état de pureté spirituelle. Tu en as déjà entendu parler ?',
 'Excellent! Now, before going to Hajj, you must first enter the state of Ihram. It is a state of spiritual purity. Have you heard of it?',
 'ممتاز! الآن، قبل الذهاب إلى الحج، يجب أن تدخل أولاً في حالة الإحرام. إنها حالة من الطهارة الروحية. هل سمعت عنها؟',
 'MULTIPLE_CHOICE',
 '["Oui, je connais bien 👍", "J''en ai une idée 🤏", "Non, explique-moi 🙏", "C''est un vêtement blanc ? 👕"]'::jsonb,
 '{"OUI JE CONNAIS BIEN": "IHRAM_PROHIBITIONS", "J EN AI UNE IDEE": "IHRAM_BASICS", "NON EXPLIQUE MOI": "IHRAM_BASICS", "C EST UN VETEMENT BLANC": "IHRAM_CLOTHING_CLARIFICATION"}'::jsonb,
 'IHRAM_BASICS', true, 24),

-- 12. Bases Ihram
('IHRAM_BASICS', 12,
 '🤍 L''Ihram, c''est à la fois un état spirituel ET un vêtement. Pour les hommes : 2 pièces de tissu blanc non cousu. Pour les femmes : vêtements modestes. Mais surtout, c''est une intention pure dans le cœur. Tu saisis la différence ?',
 'Ihram is both a spiritual state AND a garment. For men: 2 pieces of white unstitched cloth. For women: modest clothing. But above all, it is a pure intention in the heart. Do you grasp the difference?',
 'الإحرام هو حالة روحية وملابس معًا. للرجال: قطعتان من القماش الأبيض غير المخيط. للنساء: ملابس محتشمة. ولكن قبل كل شيء، إنها نية نقية في القلب. هل تفهم الفرق؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_PROHIBITIONS", "NON": "IHRAM_BASICS"}'::jsonb,
 'IHRAM_PROHIBITIONS', true, 24),

-- 13. Clarification vêtement
('IHRAM_CLOTHING_CLARIFICATION', 13,
 '👕 Oui ET non ! Le vêtement blanc est UNE partie de l''Ihram, mais l''Ihram c''est SURTOUT un état spirituel de pureté. C''est comme si tu mettais ton cœur en mode "sacré". Ça te parle mieux maintenant ?',
 'Yes AND no! The white garment is ONE part of Ihram, but Ihram is ESPECIALLY a spiritual state of purity. It is like putting your heart in "sacred" mode. Does that make more sense now?',
 'نعم ولا! الثوب الأبيض هو جزء واحد من الإحرام، لكن الإحرام هو بشكل خاص حالة روحية من الطهارة. إنه مثل وضع قلبك في وضع "المقدس". هل يبدو ذلك أكثر منطقية الآن؟',
 'YES_NO',
 NULL,
 '{"OUI": "IHRAM_PROHIBITIONS", "NON": "IHRAM_BASICS"}'::jsonb,
 'IHRAM_PROHIBITIONS', false, 12),

-- 14. Interdictions Ihram
('IHRAM_PROHIBITIONS', 14,
 '🚫 En état d''Ihram, certaines choses deviennent interdites. Selon toi, laquelle de ces actions est INTERDITE en Ihram ?',
 'In the state of Ihram, certain things become forbidden. In your opinion, which of these actions is FORBIDDEN in Ihram?',
 'في حالة الإحرام، تصبح بعض الأشياء محرمة. في رأيك، أي من هذه الأفعال محرم في الإحرام؟',
 'MULTIPLE_CHOICE',
 '["Se parfumer 💐", "Manger 🍽️", "Dormir 😴", "Marcher 🚶"]'::jsonb,
 '{"SE PARFUMER": "IHRAM_PROHIBITIONS_CORRECT", "MANGER": "IHRAM_PROHIBITIONS_WRONG", "DORMIR": "IHRAM_PROHIBITIONS_WRONG", "MARCHER": "IHRAM_PROHIBITIONS_WRONG"}'::jsonb,
 'IHRAM_PROHIBITIONS_CORRECT', true, 24),

-- 15. Bonne réponse
('IHRAM_PROHIBITIONS_CORRECT', 15,
 '✅ Bravo ! Se parfumer est bien interdit en Ihram. Les autres interdictions incluent : se couper les cheveux/ongles, chasser, avoir des relations intimes. On garde un corps et un esprit purs. Prêt pour la suite ?',
 'Bravo! Perfume is indeed forbidden in Ihram. Other prohibitions include: cutting hair/nails, hunting, having intimate relations. We keep a pure body and mind. Ready for more?',
 'برافو! العطر محرم بالفعل في الإحرام. تشمل المحظورات الأخرى: قص الشعر/الأظافر، الصيد، العلاقات الحميمة. نحافظ على جسم وعقل نقيين. مستعد للمزيد؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "IHRAM_RECAP"}'::jsonb,
 'TAWAF_INTRO', false, NULL),

-- 16. Mauvaise réponse
('IHRAM_PROHIBITIONS_WRONG', 16,
 '❌ Pas tout à fait ! Manger, dormir et marcher sont autorisés en Ihram. Ce qui est interdit : se parfumer, se couper les cheveux/ongles, chasser, relations intimes. L''idée c''est de rester pur spirituellement et physiquement. Compris ?',
 'Not quite! Eating, sleeping and walking are allowed in Ihram. What is forbidden: perfume, cutting hair/nails, hunting, intimate relations. The idea is to remain spiritually and physically pure. Understood?',
 'ليس تمامًا! الأكل والنوم والمشي مسموح بها في الإحرام. ما هو محرم: العطر، قص الشعر/الأظافر، الصيد، العلاقات الحميمة. الفكرة هي أن تبقى نقيًا روحيًا وجسديًا. فهمت؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "IHRAM_PROHIBITIONS"}'::jsonb,
 'TAWAF_INTRO', false, 12),

-- 17. Récap Ihram
('IHRAM_RECAP', 17,
 '📝 Récapitulons l''Ihram : C''est un état spirituel + un vêtement blanc (hommes). Interdictions : parfum, coupe cheveux/ongles, chasse, relations. Tout ça pour rester pur devant Allah. Maintenant tu es prêt ?',
 'Let us recap Ihram: It is a spiritual state + white clothing (men). Prohibitions: perfume, hair/nail cutting, hunting, relations. All this to remain pure before Allah. Now are you ready?',
 'دعنا نلخص الإحرام: إنها حالة روحية + ملابس بيضاء (للرجال). المحظورات: العطر، قص الشعر/الأظافر، الصيد، العلاقات. كل هذا للبقاء نقيًا أمام الله. هل أنت مستعد الآن؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_INTRO", "NON": "TAWAF_INTRO"}'::jsonb,
 'TAWAF_INTRO', false, NULL),

-- ========================================
-- TAWAF (Étapes 18-22)
-- ========================================

-- 18. Introduction Tawaf
('TAWAF_INTRO', 18,
 '🕋 Maintenant, parlons du Tawaf ! C''est le moment magique où tu vas tourner autour de la Kaaba. Tu imagines déjà le moment ?',
 'Now, let us talk about Tawaf! It is the magical moment when you will circle around the Kaaba. Can you already imagine the moment?',
 'الآن، لنتحدث عن الطواف! إنها اللحظة السحرية عندما تدور حول الكعبة. هل يمكنك أن تتخيل اللحظة بالفعل؟',
 'MULTIPLE_CHOICE',
 '["Oui, j''ai tellement hâte ! 😍", "J''imagine que c''est émouvant 🥺", "Je ne sais pas trop comment ça se passe 🤷", "C''est comme courir autour ? 🏃"]'::jsonb,
 '{"OUI J AI TELLEMENT HATE": "TAWAF_DETAILS", "J IMAGINE QUE C EST EMOUVANT": "TAWAF_DETAILS", "JE NE SAIS PAS TROP COMMENT CA SE PASSE": "TAWAF_EXPLANATION", "C EST COMME COURIR AUTOUR": "TAWAF_EXPLANATION"}'::jsonb,
 'TAWAF_DETAILS', false, NULL),

-- 19. Explication Tawaf
('TAWAF_EXPLANATION', 19,
 '🕋 Le Tawaf, c''est marcher (pas courir !) autour de la Kaaba avec respect et dévotion. Imagine des milliers de personnes tournant ensemble en priant... C''est un moment puissant et émouvant. Tu visualises ?',
 'Tawaf is walking (not running!) around the Kaaba with respect and devotion. Imagine thousands of people turning together while praying... It is a powerful and moving moment. Can you visualize it?',
 'الطواف هو المشي (ليس الركض!) حول الكعبة باحترام وتفان. تخيل آلاف الأشخاص يدورون معًا وهم يصلون... إنها لحظة قوية ومؤثرة. هل يمكنك تصورها؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_DETAILS", "NON": "TAWAF_DETAILS"}'::jsonb,
 'TAWAF_DETAILS', false, NULL),

-- 20. Détails Tawaf
('TAWAF_DETAILS', 20,
 '7️⃣ Question importante : combien de tours fais-tu autour de la Kaaba pendant le Tawaf ?',
 'Important question: how many times do you circle around the Kaaba during Tawaf?',
 'سؤال مهم: كم مرة تدور حول الكعبة خلال الطواف؟',
 'MULTIPLE_CHOICE',
 '["3 tours", "5 tours", "7 tours", "10 tours"]'::jsonb,
 '{"3 TOURS": "TAWAF_WRONG_NUMBER", "5 TOURS": "TAWAF_WRONG_NUMBER", "7 TOURS": "TAWAF_DIRECTION", "10 TOURS": "TAWAF_WRONG_NUMBER"}'::jsonb,
 'TAWAF_DIRECTION', true, 24),

-- 21. Mauvais nombre
('TAWAF_WRONG_NUMBER', 21,
 '🔢 Presque ! En réalité, c''est **7 tours** autour de la Kaaba. Le chiffre 7 est sacré dans l''Islam. Par exemple, il y a aussi 7 allers-retours dans le Sa''i. Facile à retenir maintenant ?',
 'Almost! In reality, it is **7 circles** around the Kaaba. The number 7 is sacred in Islam. For example, there are also 7 back-and-forths in Sa''i. Easy to remember now?',
 'تقريبًا! في الواقع، إنها **7 دورات** حول الكعبة. الرقم 7 مقدس في الإسلام. على سبيل المثال، هناك أيضًا 7 ذهاب وإياب في السعي. سهل التذكر الآن؟',
 'YES_NO',
 NULL,
 '{"OUI": "TAWAF_DIRECTION", "NON": "TAWAF_DETAILS"}'::jsonb,
 'TAWAF_DIRECTION', false, 12),

-- 22. Direction Tawaf
('TAWAF_DIRECTION', 22,
 '↪️ Dernière chose sur le Tawaf : dans quel sens tournes-tu autour de la Kaaba ?',
 'Last thing about Tawaf: in which direction do you turn around the Kaaba?',
 'آخر شيء عن الطواف: في أي اتجاه تدور حول الكعبة؟',
 'MULTIPLE_CHOICE',
 '["Sens horaire ⌚", "Sens antihoraire 🔄", "Peu importe 🤷", "Je ne sais pas 🤔"]'::jsonb,
 '{"SENS HORAIRE": "TAWAF_DIRECTION_CORRECTION", "SENS ANTIHORAIRE": "SAI_INTRO", "PEU IMPORTE": "TAWAF_DIRECTION_CORRECTION", "JE NE SAIS PAS": "TAWAF_DIRECTION_EXPLANATION"}'::jsonb,
 'SAI_INTRO', true, 24),

-- 23. Explication direction
('TAWAF_DIRECTION_EXPLANATION', 23,
 '🔄 C''est en sens **antihoraire** (inverse des aiguilles d''une montre). Tu gardes la Kaaba sur ta **gauche**. Comme ça, tous les pèlerins tournent dans le même sens, c''est plus fluide ! Logique, non ?',
 'It is **counterclockwise** (opposite to clock hands). You keep the Kaaba on your **left**. That way, all pilgrims turn in the same direction, it is smoother! Logical, right?',
 'إنه **عكس اتجاه عقارب الساعة**. تبقي الكعبة على **يسارك**. بهذه الطريقة، جميع الحجاج يدورون في نفس الاتجاه، إنه أكثر سلاسة! منطقي، أليس كذلك؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_INTRO", "NON": "TAWAF_DIRECTION"}'::jsonb,
 'SAI_INTRO', false, 12),

-- 24. Correction direction
('TAWAF_DIRECTION_CORRECTION', 24,
 '🔄 En fait, c''est en sens **antihoraire** ! Tu tournes dans le sens inverse des aiguilles d''une montre, en gardant la Kaaba sur ta gauche. Comme ça, tout le monde tourne dans le même sens. C''est clair ?',
 'Actually, it is **counterclockwise**! You turn in the opposite direction of clock hands, keeping the Kaaba on your left. That way, everyone turns in the same direction. Is that clear?',
 'في الواقع، إنه **عكس اتجاه عقارب الساعة**! تدور في الاتجاه المعاكس لعقارب الساعة، مع إبقاء الكعبة على يسارك. بهذه الطريقة، الجميع يدور في نفس الاتجاه. هل هذا واضح؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_INTRO", "NON": "TAWAF_DIRECTION_EXPLANATION"}'::jsonb,
 'SAI_INTRO', false, 12),

-- ========================================
-- SA'I (Étapes 25-27)
-- ========================================

-- 25. Introduction Sa'i
('SAI_INTRO', 25,
 '🚶‍♂️ Après le Tawaf vient le Sa''i. C''est un aller-retour entre deux collines : Safâ et Marwah. Tu sais pourquoi on fait ça ?',
 'After Tawaf comes Sa''i. It is a back-and-forth between two hills: Safa and Marwah. Do you know why we do this?',
 'بعد الطواف يأتي السعي. إنه ذهاب وإياب بين جبلين: الصفا والمروة. هل تعرف لماذا نفعل هذا؟',
 'MULTIPLE_CHOICE',
 '["En mémoire de Hajar 🤱", "Pour faire de l''exercice 🏃", "C''est une tradition 🤷", "Je ne sais pas 🤔"]'::jsonb,
 '{"EN MEMOIRE DE HAJAR": "SAI_STORY", "POUR FAIRE DE L EXERCICE": "SAI_STORY_CORRECTION", "C EST UNE TRADITION": "SAI_STORY_CORRECTION", "JE NE SAIS PAS": "SAI_STORY"}'::jsonb,
 'SAI_STORY', true, 24),

-- 26. Histoire de Hajar
('SAI_STORY', 26,
 '💧 Exactement ! C''est en mémoire de Hajar (que la paix soit sur elle), la femme d''Ibrahim. Quand elle cherchait désespérément de l''eau pour son fils Ismaël dans le désert, elle a couru 7 fois entre Safâ et Marwah. Allah a fait jaillir la source Zamzam. Émouvant, n''est-ce pas ?',
 'Exactly! It is in memory of Hajar (peace be upon her), the wife of Ibrahim. When she desperately searched for water for her son Ishmael in the desert, she ran 7 times between Safa and Marwah. Allah made the Zamzam spring gush forth. Moving, isn''t it?',
 'بالضبط! إنه تذكيرًا بهاجر (عليها السلام)، زوجة إبراهيم. عندما كانت تبحث بشكل يائس عن الماء لابنها إسماعيل في الصحراء، ركضت 7 مرات بين الصفا والمروة. فجّر الله نبع زمزم. مؤثر، أليس كذلك؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_DETAILS"}'::jsonb,
 'SAI_DETAILS', false, NULL),

-- 27. Correction histoire
('SAI_STORY_CORRECTION', 27,
 '💧 En réalité, le Sa''i commémore l''histoire de **Hajar** ! Elle a couru 7 fois entre Safâ et Marwah en cherchant de l''eau pour Ismaël. Allah a fait jaillir Zamzam. C''est un rappel de foi, de patience et de confiance en Allah. Maintenant tu comprends mieux ?',
 'In reality, Sa''i commemorates the story of **Hajar**! She ran 7 times between Safa and Marwah looking for water for Ishmael. Allah made Zamzam gush forth. It is a reminder of faith, patience and trust in Allah. Now do you understand better?',
 'في الواقع، السعي يخلد ذكرى قصة **هاجر**! ركضت 7 مرات بين الصفا والمروة بحثًا عن الماء لإسماعيل. فجّر الله زمزم. إنه تذكير بالإيمان والصبر والثقة بالله. هل تفهم الآن بشكل أفضل؟',
 'YES_NO',
 NULL,
 '{"OUI": "SAI_DETAILS", "NON": "SAI_STORY"}'::jsonb,
 'SAI_DETAILS', false, 12),

-- 28. Détails Sa'i
('SAI_DETAILS', 28,
 '🏃 Pendant le Sa''i, entre les deux lumières vertes, les hommes accélèrent le pas (Ramal) pour rappeler la course de Hajar. Les femmes marchent normalement. As-tu d''autres questions sur le Sa''i ?',
 'During Sa''i, between the two green lights, men accelerate their pace (Ramal) to recall Hajar''s run. Women walk normally. Do you have any other questions about Sa''i?',
 'خلال السعي، بين الضوءين الأخضرين، يسرع الرجال خطاهم (الرمل) لتذكر ركض هاجر. تمشي النساء بشكل طبيعي. هل لديك أي أسئلة أخرى عن السعي؟',
 'MULTIPLE_CHOICE',
 '["Non, c''est clair ! ✅", "Oui, j''ai une question 🙋", "Je voudrais réviser 📝", "Passons à la suite 👉"]'::jsonb,
 '{"NON C EST CLAIR": "ARAFAT_RECAP", "OUI J AI UNE QUESTION": "SAI_QUESTIONS", "JE VOUDRAIS REVISER": "SAI_INTRO", "PASSONS A LA SUITE": "ARAFAT_RECAP"}'::jsonb,
 'ARAFAT_RECAP', false, NULL),

-- 29. Questions Sa'i
('SAI_QUESTIONS', 29,
 'Super ! Pose-moi ta question sur le Sa''i, je suis là pour t''aider 😊',
 'Great! Ask me your question about Sa''i, I am here to help you',
 'رائع! اسألني سؤالك عن السعي، أنا هنا لمساعدتك',
 'TEXT',
 NULL,
 '{"DEFAULT": "ARAFAT_RECAP"}'::jsonb,
 'ARAFAT_RECAP', false, NULL),

-- ========================================
-- ARAFAT & FÉLICITATIONS (Étapes 30-31)
-- ========================================

-- 30. Récap Arafat
('ARAFAT_RECAP', 30,
 '⛰️ On arrive au sommet : **Arafat** ! Tu te souviens ? C''est le 9 Dhul Hijjah, le cœur du Hajj. Si tu rates Arafat, tu rates ton Hajj ! Ce jour-là, tu passes l''après-midi en prières et invocations de midi au coucher du soleil. C''est le moment le plus important. Es-tu prêt à vivre ce moment quand ton heure viendra ?',
 'We reach the summit: **Arafat**! Do you remember? It is the 9th of Dhul Hijjah, the heart of Hajj. If you miss Arafat, you miss your Hajj! On that day, you spend the afternoon in prayers and supplications from noon to sunset. It is the most important moment. Are you ready to experience this moment when your time comes?',
 'نصل إلى القمة: **عرفة**! هل تتذكر؟ إنه 9 ذو الحجة، قلب الحج. إذا فاتتك عرفة، فاتك حجك! في ذلك اليوم، تقضي فترة بعد الظهر في الصلاة والدعاء من الظهر حتى غروب الشمس. إنها اللحظة الأكثر أهمية. هل أنت مستعد لتعيش هذه اللحظة عندما يحين وقتك؟',
 'MULTIPLE_CHOICE',
 '["Oui, inch''Allah ! 🤲", "J''espère être prêt 💫", "J''ai encore beaucoup à apprendre 📚", "Qu''Allah me facilite 🙏"]'::jsonb,
 '{"OUI INCH ALLAH": "CONGRATULATIONS", "J ESPERE ETRE PRET": "CONGRATULATIONS", "J AI ENCORE BEAUCOUP A APPRENDRE": "CONGRATULATIONS", "QU ALLAH ME FACILITE": "CONGRATULATIONS"}'::jsonb,
 'CONGRATULATIONS', true, 48),

-- 31. Félicitations
('CONGRATULATIONS', 31,
 '🎉 **Mabrouk !** Tu as terminé l''apprentissage des bases du Hajj ! Tu connais maintenant l''Ihram, le Tawaf, le Sa''i, et Arafat. Continue à apprendre, pose des questions, lis, regarde des vidéos. **Qu''Allah accepte ton Hajj quand ton heure viendra. Amine !** 🤲✨🕋',
 'Mabrouk! You have completed learning the basics of Hajj! You now know Ihram, Tawaf, Sa''i, and Arafat. Keep learning, ask questions, read, watch videos. May Allah accept your Hajj when your time comes. Ameen!',
 'مبروك! لقد أكملت تعلم أساسيات الحج! أنت تعرف الآن الإحرام والطواف والسعي وعرفة. استمر في التعلم، اسأل الأسئلة، اقرأ، شاهد مقاطع الفيديو. تقبل الله حجك عندما يحين وقتك. آمين!',
 'TEXT',
 NULL,
 NULL,
 NULL, false, NULL);

-- ============================================
-- VÉRIFICATION
-- ============================================

SELECT COUNT(*) as "Nombre d'étapes" FROM conversation_steps;

-- Résultat attendu : 32 étapes (31 originales + 1 correction Arafat)

-- ============================================
-- FIN DU SCRIPT
-- ============================================

