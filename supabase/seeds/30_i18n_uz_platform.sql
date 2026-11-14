-- Oʻzbekcha tarjima: platforma (kategoriyalar, muallif, yutuqlar, tariflar).
-- Uzbek Latin orthography: oʻ/gʻ use U+02BB (ʻ), the tutuq belgisi uses U+02BC (ʼ).
-- Translations only UPDATE existing rows (see seed.tr) — no IDs are created or changed.

-- Top-level categories ------------------------------------------------------------------
select seed.tr_category('information-technology', 'uz', 'Axborot texnologiyalari',
  'Kompyuterlar, tarmoqlar va bulut aslida qanday ishlaydi',
  'Har bir raqamli mutaxassis tayanadigan asoslar: apparat taʼminoti, operatsion tizimlar, tarmoqlar, xavfsizlik, bulutli texnologiyalar va maʼlumotlar.');
select seed.tr_category('programming', 'uz', 'Dasturlash va dasturiy taʼminot',
  'Haqiqiy muammolarni hal qiladigan kod yozing',
  'Tillar, freymvorklar va muhandislik amaliyotlari — HTMLdagi birinchi qatoringizdan real loyihalardagi dasturiy taʼminot arxitekturasigacha.');
select seed.tr_category('video-production', 'uz', 'Video montaj va ishlab chiqarish',
  'Harakatlanuvchi tasvir orqali hikoya qiling',
  'Montaj, rang bilan ishlash, harakatli grafika va ovoz — xom tasvirdan tayyor filmgacha boʻlgan toʻliq jarayon.');
select seed.tr_category('blender-3d', 'uz', 'Blender va 3D dizayn',
  'Uch oʻlchamda modellashtiring, yoriting va render qiling',
  '“3D nima?” degan savoldan tortib Blenderda professional modellashtirish, skulpting, materiallar, animatsiya va VFXgacha.');
select seed.tr_category('game-development', 'uz', 'Unreal Engine va oʻyinlar',
  'Interaktiv olamlar yarating',
  'Oʻyin dvigatellari, Blueprints, C++, muhitlar, personajlar, VFX hamda Unreal Engine yordamida optimallashtirish.');
select seed.tr_category('graphic-design', 'uz', 'Grafik dizayn va ijod',
  'Maqsadli dizayn yarating',
  'Dizayn tamoyillari, tipografiya, brending, UI/UX hamda mutaxassislar foydalanadigan vositalar — Photoshop, Illustrator va Figma.');
select seed.tr_category('ai-emerging', 'uz', 'Sunʼiy intellekt va yangi texnologiyalar',
  'Sunʼiy intellektni tushuning va qoʻllang',
  'Zamonaviy sunʼiy intellekt qanday ishlashi va undan masʼuliyat bilan foydalanish: generativ modellar, promptlar, avtomatlashtirish va agentlar.');

-- Topics (proper names such as HTML, Python or Figma stay as they are) -----------------
select seed.tr_category(t.slug, 'uz', t.title)
from (values
  ('computer-fundamentals', 'Kompyuter asoslari'),
  ('operating-systems', 'Operatsion tizimlar'),
  ('windows-macos', 'Windows va macOS'),
  ('computer-hardware', 'Kompyuter qurilmalari'),
  ('networking', 'Kompyuter tarmoqlari'),
  ('cybersecurity-fundamentals', 'Kiberxavfsizlik asoslari'),
  ('linux', 'Linux'),
  ('cloud-computing', 'Bulutli hisoblash'),
  ('data-science', 'Maʼlumotlar fani'),
  ('databases', 'Maʼlumotlar bazalari'),
  ('it-support', 'IT qoʻllab-quvvatlash'),
  ('system-administration', 'Tizim maʼmuriyati'),
  ('backend-development', 'Backend dasturlash'),
  ('frontend-development', 'Frontend dasturlash'),
  ('full-stack-development', 'Full-stack dasturlash'),
  ('mobile-development', 'Mobil ilovalar yaratish'),
  ('git-github', 'Git va GitHub'),
  ('software-architecture', 'Dasturiy taʼminot arxitekturasi'),
  ('api-development', 'API ishlab chiqish'),
  ('video-editing-fundamentals', 'Video montaj asoslari'),
  ('color-grading', 'Professional rang korreksiyasi'),
  ('cinematic-editing', 'Kinematografik montaj'),
  ('motion-graphics', 'Harakatli grafika'),
  ('visual-storytelling', 'Vizual hikoyachilik'),
  ('sound-design', 'Ovoz dizayni'),
  ('transitions', 'Professional oʻtishlar'),
  ('production-workflow', 'Video ishlab chiqarish jarayoni'),
  ('documentary', 'Hujjatli film suratga olish'),
  ('commercial-production', 'Reklama videolari ishlab chiqarish'),
  ('blender-interface', 'Blender interfeysi'),
  ('3d-fundamentals', '3D asoslari'),
  ('modeling', 'Modellashtirish'),
  ('sculpting', 'Skulpting'),
  ('materials', 'Materiallar'),
  ('texturing', 'Teksturalash'),
  ('lighting', 'Yoritish'),
  ('rendering', 'Rendering'),
  ('character-creation', 'Personaj yaratish'),
  ('environment-design', 'Muhit dizayni'),
  ('product-visualization', 'Mahsulot vizualizatsiyasi'),
  ('animation', 'Animatsiya'),
  ('rigging', 'Riglash'),
  ('professional-3d-workflows', 'Professional 3D jarayonlari'),
  ('unreal-fundamentals', 'Unreal Engine asoslari'),
  ('unreal-editor', 'Muharrir interfeysi'),
  ('blueprints', 'Blueprint vizual dasturlash'),
  ('unreal-cpp', 'Unreal uchun C++'),
  ('unreal-materials', 'Materiallar'),
  ('unreal-lighting', 'Yoritish'),
  ('landscapes', 'Landshaft yaratish'),
  ('unreal-environments', 'Muhit dizayni'),
  ('character-systems', 'Personaj tizimlari'),
  ('unreal-animation', 'Animatsiya'),
  ('gameplay-mechanics', 'Oʻyin mexanikalari'),
  ('game-ai', 'Sunʼiy intellekt tizimlari'),
  ('level-design', 'Daraja dizayni'),
  ('game-optimization', 'Oʻyinni optimallashtirish'),
  ('multiplayer', 'Koʻp oʻyinchili rejim asoslari'),
  ('game-production', 'Oʻyinni toʻliq ishlab chiqish'),
  ('design-principles', 'Dizayn tamoyillari'),
  ('ui-ux', 'UI/UX dizayn'),
  ('typography', 'Tipografiya'),
  ('branding', 'Brending'),
  ('logo-design', 'Logotip dizayni'),
  ('digital-illustration', 'Raqamli illyustratsiya'),
  ('product-design', 'Mahsulot dizayni'),
  ('design-systems', 'Dizayn tizimlari'),
  ('ai-fundamentals', 'Sunʼiy intellekt asoslari'),
  ('generative-ai', 'Generativ sunʼiy intellekt'),
  ('prompt-engineering', 'Prompt muhandisligi'),
  ('ai-image-generation', 'Sunʼiy intellekt bilan tasvir yaratish'),
  ('ai-video-generation', 'Sunʼiy intellekt bilan video yaratish'),
  ('ai-automation', 'Sunʼiy intellekt yordamida avtomatlashtirish'),
  ('ai-agents', 'Sunʼiy intellekt agentlari'),
  ('machine-learning', 'Mashinali oʻqitish'),
  ('practical-ai', 'Sunʼiy intellektning amaliy qoʻllanilishi')
) as t(slug, title);

-- Product and language names are the same in Uzbek; recording them explicitly marks the
-- topic as reviewed, so the app never flags it as untranslated.
select seed.tr_category(slug, 'uz', title)
from public.categories
where slug in ('html', 'css', 'javascript', 'typescript', 'python', 'c', 'cpp', 'csharp', 'java', 'swift',
  'kotlin', 'react', 'nextjs', 'nodejs', 'premiere-pro', 'davinci-resolve', 'after-effects', 'capcut',
  'geometry-nodes', 'vfx', 'niagara-vfx', 'photoshop', 'illustrator', 'figma');

-- Authorship ---------------------------------------------------------------------------
select seed.tr_simple('instructors', 'mahorat-editorial', 'uz', jsonb_build_object(
  'name', 'Mahorat tahririyati',
  'headline', 'Oʻquv dasturi mualliflari va muharrirlari',
  'bio', 'Boshlangʻich darslarni Mahorat kontent jamoasi yozgan. Har bir dars tahririy tekshiruvdan oʻtadi, kurslar esa yangi materiallar tayyorlanib, soha mutaxassislari tomonidan tasdiqlangani sari bosqichma-bosqich kengaytiriladi.'));

-- Achievements -------------------------------------------------------------------------
select seed.tr_simple('achievements', t.slug, 'uz', jsonb_build_object('title', t.title, 'description', t.description))
from (values
  ('first-step', 'Birinchi qadam', 'Birinchi darsingizni yakunlang.'),
  ('curious-mind', 'Qiziquvchan', 'Birinchi kursingizga yoziling.'),
  ('steady-learner', 'Izchil oʻquvchi', '10 ta darsni yakunlang.'),
  ('deep-diver', 'Chuqur oʻrganuvchi', '50 ta darsni yakunlang.'),
  ('streak-3', 'Qizib olish', 'Ketma-ket uch kun oʻqing.'),
  ('streak-7', 'Toʻliq hafta', 'Ketma-ket yetti kun oʻqing.'),
  ('streak-30', 'Sobitqadam', 'Ketma-ket oʻttiz kun oʻqing.'),
  ('quiz-pass', 'Isbotlandi', 'Birinchi testingizdan oʻting.'),
  ('quiz-perfect', 'Benuqson', 'Testda 100% natija qayd eting.'),
  ('course-complete', 'Marraga yetdi', 'Bitta kursni toʻliq yakunlang.'),
  ('certified', 'Sertifikatlangan', 'Birinchi sertifikatingizni oling.'),
  ('hour-of-focus', 'Diqqat soati', 'Oʻqishga 60 daqiqa vaqt ajrating.'),
  ('xp-1000', 'Yuksalish', '1 000 XP toʻplang.')
) as t(slug, title, description);

-- Subscription plans -------------------------------------------------------------------
select seed.tr_simple('subscription_plans', 'premium-monthly', 'uz', jsonb_build_object(
  'title', 'Premium oylik',
  'description', 'Toʻliq kirish, toʻlov har oy.',
  'features', jsonb_build_array('Toʻliq kurslar kutubxonasi', 'Professional oʻquv yoʻnalishlari', 'Murakkab loyihalar', 'Sertifikatlar', 'Yuklab olinadigan materiallar')));
select seed.tr_simple('subscription_plans', 'premium-yearly', 'uz', jsonb_build_object(
  'title', 'Premium yillik',
  'description', 'Toʻliq kirish, toʻlov har yili.',
  'features', jsonb_build_array('Oylik tarifdagi barcha imkoniyatlar', 'Eng tejamkor tanlov')));
