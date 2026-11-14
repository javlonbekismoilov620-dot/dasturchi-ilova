-- Русский перевод: платформенные строки (категории, автор, достижения, тарифы, треки).
-- Course content itself is not yet translated into Russian; the app shows the original
-- with a “translation is being prepared” notice until it is.

select seed.tr_category('information-technology', 'ru', 'Информационные технологии',
  'Как на самом деле работают компьютеры, сети и облако',
  'Основы, на которые опирается каждый цифровой специалист: оборудование, операционные системы, сети, безопасность, облачные технологии и данные.');
select seed.tr_category('programming', 'ru', 'Программирование и разработка ПО',
  'Пишите код, который решает реальные задачи',
  'Языки, фреймворки и инженерные практики — от первой строки HTML до архитектуры реальных программных систем.');
select seed.tr_category('video-production', 'ru', 'Видеомонтаж и производство видео',
  'Рассказывайте истории с помощью видео',
  'Монтаж, цвет, моушн-графика и звук — весь путь от исходного материала до готового фильма.');
select seed.tr_category('blender-3d', 'ru', 'Blender и 3D-дизайн',
  'Моделируйте, освещайте и рендерите в трёх измерениях',
  'От вопроса «что такое 3D?» до профессионального моделирования, скульптинга, материалов, анимации и VFX в Blender.');
select seed.tr_category('game-development', 'ru', 'Unreal Engine и игры',
  'Создавайте интерактивные миры',
  'Игровые движки, Blueprints, C++, окружение, персонажи, VFX и оптимизация в Unreal Engine.');
select seed.tr_category('graphic-design', 'ru', 'Графический дизайн и творчество',
  'Дизайн, у которого есть цель',
  'Принципы дизайна, типографика, брендинг, UI/UX и инструменты профессионалов — Photoshop, Illustrator и Figma.');
select seed.tr_category('ai-emerging', 'ru', 'ИИ и новые технологии',
  'Понимайте и применяйте искусственный интеллект',
  'Как работает современный ИИ и как использовать его ответственно: генеративные модели, промпты, автоматизация и агенты.');

select seed.tr_category(t.slug, 'ru', t.title)
from (values
  ('computer-fundamentals', 'Основы компьютера'), ('operating-systems', 'Операционные системы'),
  ('windows-macos', 'Windows и macOS'), ('computer-hardware', 'Компьютерное оборудование'),
  ('networking', 'Компьютерные сети'), ('cybersecurity-fundamentals', 'Основы кибербезопасности'),
  ('cloud-computing', 'Облачные вычисления'), ('data-science', 'Наука о данных'), ('databases', 'Базы данных'),
  ('it-support', 'IT-поддержка'), ('system-administration', 'Системное администрирование'),
  ('backend-development', 'Backend-разработка'), ('frontend-development', 'Frontend-разработка'),
  ('full-stack-development', 'Full-stack-разработка'), ('mobile-development', 'Разработка мобильных приложений'),
  ('git-github', 'Git и GitHub'), ('software-architecture', 'Архитектура ПО'), ('api-development', 'Разработка API'),
  ('video-editing-fundamentals', 'Основы видеомонтажа'), ('color-grading', 'Профессиональная цветокоррекция'),
  ('cinematic-editing', 'Кинематографичный монтаж'), ('motion-graphics', 'Моушн-графика'),
  ('visual-storytelling', 'Визуальный сторителлинг'), ('sound-design', 'Саунд-дизайн'),
  ('transitions', 'Профессиональные переходы'), ('production-workflow', 'Процесс производства видео'),
  ('documentary', 'Документальное кино'), ('commercial-production', 'Производство рекламных роликов'),
  ('blender-interface', 'Интерфейс Blender'), ('3d-fundamentals', 'Основы 3D'), ('modeling', 'Моделирование'),
  ('sculpting', 'Скульптинг'), ('materials', 'Материалы'), ('texturing', 'Текстурирование'),
  ('lighting', 'Освещение'), ('rendering', 'Рендеринг'), ('character-creation', 'Создание персонажей'),
  ('environment-design', 'Дизайн окружения'), ('product-visualization', 'Предметная визуализация'),
  ('animation', 'Анимация'), ('rigging', 'Риггинг'), ('professional-3d-workflows', 'Профессиональные 3D-процессы'),
  ('unreal-fundamentals', 'Основы Unreal Engine'), ('unreal-editor', 'Интерфейс редактора'),
  ('blueprints', 'Визуальное программирование Blueprint'), ('unreal-cpp', 'C++ для Unreal'),
  ('unreal-materials', 'Материалы'), ('unreal-lighting', 'Освещение'), ('landscapes', 'Создание ландшафтов'),
  ('unreal-environments', 'Дизайн окружения'), ('character-systems', 'Системы персонажей'),
  ('unreal-animation', 'Анимация'), ('gameplay-mechanics', 'Игровые механики'), ('game-ai', 'Системы ИИ'),
  ('level-design', 'Дизайн уровней'), ('game-optimization', 'Оптимизация игр'),
  ('multiplayer', 'Основы мультиплеера'), ('game-production', 'Полный цикл разработки игры'),
  ('design-principles', 'Принципы дизайна'), ('ui-ux', 'UI/UX-дизайн'), ('typography', 'Типографика'),
  ('branding', 'Брендинг'), ('logo-design', 'Дизайн логотипов'), ('digital-illustration', 'Цифровая иллюстрация'),
  ('product-design', 'Продуктовый дизайн'), ('design-systems', 'Дизайн-системы'),
  ('ai-fundamentals', 'Основы ИИ'), ('generative-ai', 'Генеративный ИИ'), ('prompt-engineering', 'Промпт-инжиниринг'),
  ('ai-image-generation', 'Генерация изображений с ИИ'), ('ai-video-generation', 'Генерация видео с ИИ'),
  ('ai-automation', 'Автоматизация с ИИ'), ('ai-agents', 'ИИ-агенты'), ('machine-learning', 'Машинное обучение'),
  ('practical-ai', 'Практическое применение ИИ')
) as t(slug, title);

select seed.tr_category(slug, 'ru', title)
from public.categories
where slug in ('linux', 'html', 'css', 'javascript', 'typescript', 'python', 'c', 'cpp', 'csharp', 'java', 'swift',
  'kotlin', 'react', 'nextjs', 'nodejs', 'premiere-pro', 'davinci-resolve', 'after-effects', 'capcut',
  'geometry-nodes', 'vfx', 'niagara-vfx', 'photoshop', 'illustrator', 'figma');

select seed.tr_simple('instructors', 'mahorat-editorial', 'ru', jsonb_build_object(
  'name', 'Редакция Mahorat',
  'headline', 'Авторы и редакторы учебных программ',
  'bio', 'Стартовые уроки написаны контент-командой Mahorat. Каждый урок проходит редакционную проверку, а курсы постепенно расширяются по мере подготовки новых материалов и их одобрения экспертами.'));

select seed.tr_simple('achievements', t.slug, 'ru', jsonb_build_object('title', t.title, 'description', t.description))
from (values
  ('first-step', 'Первый шаг', 'Завершите первый урок.'),
  ('curious-mind', 'Любознательность', 'Запишитесь на первый курс.'),
  ('steady-learner', 'Упорство', 'Завершите 10 уроков.'),
  ('deep-diver', 'Глубокое погружение', 'Завершите 50 уроков.'),
  ('streak-3', 'Разогрев', 'Учитесь три дня подряд.'),
  ('streak-7', 'Целая неделя', 'Учитесь семь дней подряд.'),
  ('streak-30', 'Несгибаемость', 'Учитесь тридцать дней подряд.'),
  ('quiz-pass', 'Доказано', 'Сдайте первый тест.'),
  ('quiz-perfect', 'Безупречно', 'Наберите 100% в тесте.'),
  ('course-complete', 'До финиша', 'Полностью пройдите один курс.'),
  ('certified', 'Сертификат', 'Получите первый сертификат.'),
  ('hour-of-focus', 'Час концентрации', 'Посвятите учёбе 60 минут.'),
  ('xp-1000', 'На подъёме', 'Наберите 1 000 XP.')
) as t(slug, title, description);

select seed.tr_simple('subscription_plans', 'premium-monthly', 'ru', jsonb_build_object(
  'title', 'Premium на месяц', 'description', 'Полный доступ, оплата ежемесячно.',
  'features', jsonb_build_array('Вся библиотека курсов', 'Профессиональные учебные треки', 'Продвинутые проекты', 'Сертификаты', 'Материалы для скачивания')));
select seed.tr_simple('subscription_plans', 'premium-yearly', 'ru', jsonb_build_object(
  'title', 'Premium на год', 'description', 'Полный доступ, оплата раз в год.',
  'features', jsonb_build_array('Всё, что входит в месячный тариф', 'Самый выгодный вариант')));

select seed.tr_simple('learning_paths', t.slug, 'ru', jsonb_build_object('title', t.title, 'subtitle', t.subtitle, 'description', t.description))
from (values
  ('web-developer', 'Веб-разработчик', 'От первого тега до full-stack-приложений',
   'Последовательный путь через основы компьютера, HTML, CSS, JavaScript и дальше. Новые курсы добавляются в трек по мере публикации.'),
  ('3d-artist', '3D-художник', 'Мыслите в трёх измерениях, рендерьте как студия',
   'Начните с того, что такое 3D, освойте интерфейс Blender, затем переходите к моделированию, материалам, освещению и анимации.'),
  ('game-developer', 'Разработчик игр', 'Проектируйте и создавайте интерактивные миры',
   'Основы программирования, основы 3D и Unreal Engine — навыки, которые нужны разработчику игр, в правильном порядке.'),
  ('creator', 'Цифровой автор', 'Уверенно создавайте дизайн, монтируйте и публикуйте',
   'Принципы дизайна, видеомонтаж и практическое применение ИИ для тех, кто создаёт контент.')
) as t(slug, title, subtitle, description);
