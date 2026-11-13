-- Course: Blender — Your First Steps in 3D (free)
do $seed$
declare
  c uuid; m1 uuid; m2 uuid; m3 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('blender-first-steps-in-3d', 'Blender: Your First Steps in 3D',
    'From “what is 3D?” to confidently moving around your first scene',
    $d$Blender is a free, open-source application used for 3D modeling, animation, visual effects and rendering — by hobbyists and professional studios alike.

This course begins before Blender: you will first understand **what 3D actually is**. Then you will install Blender, learn its interface and move, rotate and scale objects with the same shortcuts professionals use.$d$,
    seed.cat('blender-3d'), seed.cat('blender-interface'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 75,
    array['Explain vertices, edges, faces and the X/Y/Z axes',
          'Install Blender and identify the main areas of the interface',
          'Navigate the 3D viewport with mouse, keyboard and gizmo',
          'Add, move, rotate and scale objects precisely'],
    array['A computer with a dedicated or recent integrated graphics chip', 'A three-button mouse is recommended'],
    array['blender', '3d', 'modeling', 'beginner'], true,
    '{"pattern": "isometric", "hue": 28}')
  returning id into c;

  m1 := seed.module(c, 0, 'Understanding 3D', 'The ideas behind every 3D image and film.');

  perform seed.lesson(m1, 0, 'What is 3D?', 'article', 8,
    'Space, axes and the building blocks of every 3D object.',
$md$## Three directions

A drawing on paper is **2D**: it has width and height. The real world is **3D**: it also has depth. To describe any position in 3D space we need three numbers, one for each direction, called **axes**:

- **X** — left ↔ right
- **Y** — forward ↔ back
- **Z** — up ↔ down

> [!NOTE]
> In Blender, **Z points up**. Some other programs use Y as “up”, which matters when you move models between applications.

## What a 3D object is made of

Most 3D objects are **meshes** — surfaces built from three simple parts:

- **Vertex** (plural *vertices*) — a single point in space.
- **Edge** — a straight line between two vertices.
- **Face** — a flat surface enclosed by edges, usually with three or four sides.

A cube has 8 vertices, 12 edges and 6 faces. Even a detailed character is “just” many thousands of these.

## From model to image

Making a 3D image follows a pipeline that you will learn step by step in Mahorat courses:

1. **Modeling** — building the shape.
2. **Materials and texturing** — deciding what surfaces look like: metal, wood, skin.
3. **Lighting** — placing lights, just like on a film set.
4. **Camera** — choosing what the viewer sees.
5. **Rendering** — the computer calculates the final image from all of the above.

Add **animation** — changing things over time — and you can make films and games.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 1, 'What is Blender?', 'article', 6,
    'A complete 3D studio that anyone can download for free.',
$md$## A complete 3D studio

**Blender** is a free and open-source 3D creation suite developed by the Blender Foundation and a worldwide community. “Open source” means its code is public and anyone may use it — for personal or commercial work — without paying.

Blender covers the whole pipeline in one application:

- modeling and sculpting
- materials, texturing and UV unwrapping
- lighting and rendering with two engines: **EEVEE** (fast, real-time) and **Cycles** (physically accurate)
- animation and rigging
- simulations such as smoke, fluids and cloth
- video editing and compositing

## Who uses it?

Independent artists, game developers, product designers, architects and animation studios. Skills you learn in Blender — such as topology, lighting and composition — transfer to every other 3D application.

> [!TIP]
> Blender is updated often and menus move between versions. When instructions do not match your screen, check the version number on the splash screen and the official manual at docs.blender.org.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 2, 'Installing Blender and the interface', 'article', 10,
    'Get Blender from the official source and learn the five main areas.',
$md$## Install

1. Go to **blender.org** and open the **Download** page.
2. Download the version for your system (Windows, macOS — choose Apple Silicon or Intel — or Linux).
3. Run the installer, then open Blender.

> [!WARNING]
> Download Blender only from blender.org (or official stores such as Steam and the Microsoft Store). It is free — any site asking for payment is not official.

## The default scene

Blender opens with a **cube**, a **camera** and a **light**. This is the default scene, ready for you to experiment.

## The five main areas

1. **3D Viewport** — the large central area where you see and edit your scene.
2. **Outliner** (top right) — a list of every object in the scene, like a table of contents.
3. **Properties Editor** (bottom right) — settings for the selected object, its material, the render and more, organised in tabs.
4. **Timeline** (bottom) — controls for animation over time.
5. **Toolbar** (left of the viewport) — tools such as Select, Move, Rotate and Scale.

Across the top are **workspaces** (Layout, Modeling, Sculpting, Shading…). Each is a pre-arranged set of areas for a particular job.

> [!TIP]
> Hover over almost any button and wait — Blender shows a tooltip explaining what it does.$md$,
    'published', false, 10);

  m2 := seed.module(c, 1, 'Moving around and basic objects', 'Navigation and transformations — the skills you will use every minute.');

  perform seed.lesson(m2, 0, 'Navigating the 3D viewport', 'article', 9,
    'Orbit, pan and zoom with confidence.',
$md$## The three moves

| Action | Mouse | What it does |
| --- | --- | --- |
| **Orbit** | Hold **middle mouse button** and drag | Rotates your view around the scene |
| **Pan** | **Shift** + middle mouse drag | Slides your view sideways |
| **Zoom** | Scroll the wheel | Moves closer or further away |

## Useful views (numeric keypad)

- **1** — front, **3** — right side, **7** — top
- **Ctrl** + the same key — the opposite side
- **0** — look through the camera
- **.** (period) on the keypad — frame the selected object

No keypad? Press the **` (backtick)** key for a pie menu of views, or click the axes in the **navigation gizmo** at the top right of the viewport.

> [!TIP]
> Using a laptop without a middle mouse button? Open **Edit → Preferences → Input** and enable **Emulate 3 Button Mouse**. Then **Alt + left-drag** orbits.

## Lost?

Press **Home** to fit everything in view.$md$,
    'published', false, 10);

  perform seed.lesson(m2, 1, 'Basic objects: add, move, rotate, scale', 'exercise', 12,
    'The G, R, S shortcuts and axis constraints.',
$md$## Adding objects

Press **Shift + A** in the viewport to open the **Add** menu. Choose **Mesh → UV Sphere**. New objects appear at the **3D cursor** (the red-and-white ring).

## Transforming

Select an object by left-clicking it, then:

| Key | Action |
| --- | --- |
| **G** | Grab (move) |
| **R** | Rotate |
| **S** | Scale |

Move the mouse, then **left-click** to confirm or **right-click** (or Esc) to cancel.

## Constraining to an axis

After pressing G, R or S, press **X**, **Y** or **Z** to limit the change to that axis. You can also type a number:

- **G Z 2** → move 2 metres up
- **R X 90** → rotate 90° around the X axis
- **S 0.5** → scale to half size

## Undo and the sidebar

- **Ctrl + Z** undoes, **Ctrl + Shift + Z** redoes.
- Press **N** to open the **sidebar**, where you can type exact Location, Rotation and Scale values.

## Practice

Delete the default cube (**X → Delete**), then build a simple snowman: three UV spheres of decreasing size stacked along Z, plus a cone for the nose rotated 90° around X.$md$,
    'published', false, 20);

  l := seed.lesson(m2, 2, 'Module quiz', 'quiz', 5, 'Check your 3D and navigation basics.', null, 'published', false, 15);
  q := seed.quiz(c, m2, l, 'Blender basics quiz', 'module_exam', 70, 25);
  qq := seed.question(q, 0, 'single_choice', 'Which axis points **up** in Blender?', 'Blender is Z-up.');
  perform seed.answer(qq, 0, 'X', false);
  perform seed.answer(qq, 1, 'Y', false, 'Some other applications use Y-up — Blender does not.');
  perform seed.answer(qq, 2, 'Z', true);
  qq := seed.question(q, 1, 'single_choice', 'How many faces does a cube have?', 'A cube has 6 faces, 12 edges and 8 vertices.');
  perform seed.answer(qq, 0, '6', true);
  perform seed.answer(qq, 1, '8', false, '8 is the number of vertices.');
  perform seed.answer(qq, 2, '12', false, '12 is the number of edges.');
  qq := seed.question(q, 2, 'single_choice', 'You want to rotate an object exactly 90° around X. What do you type?', 'R starts rotation, X constrains the axis, 90 is the angle.');
  perform seed.answer(qq, 0, 'G X 90', false, 'G moves the object.');
  perform seed.answer(qq, 1, 'R X 90', true);
  perform seed.answer(qq, 2, 'S X 90', false, 'S scales the object.');
  qq := seed.question(q, 3, 'single_choice', 'Which shortcut opens the Add menu?', '**Shift + A** opens the Add menu in the viewport.');
  perform seed.answer(qq, 0, 'Shift + A', true);
  perform seed.answer(qq, 1, 'Ctrl + A', false, 'Ctrl + A opens the Apply menu.');
  perform seed.answer(qq, 2, 'N', false, 'N toggles the sidebar.');

  m3 := seed.module(c, 2, 'Your first render', 'Materials, a light and a camera.', 'draft');
  perform seed.lesson(m3, 0, 'Giving objects a material', 'article', 10, 'Base colour, roughness and metallic.', null, 'draft');
  perform seed.lesson(m3, 1, 'Lighting and rendering your first image', 'article', 12, 'EEVEE vs Cycles and saving a PNG.', null, 'draft');
end $seed$;

-- Course: Video Editing Fundamentals (free)
do $seed$
declare
  c uuid; m1 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('video-editing-fundamentals', 'Video Editing Fundamentals',
    'The universal language of editing — in any app',
    $d$Before learning any particular editor, learn **editing itself**. The concepts in this course — clips, timelines, cuts, frame rates and workflow — apply equally to Premiere Pro, DaVinci Resolve, Final Cut Pro and CapCut.$d$,
    seed.cat('video-production'), seed.cat('video-editing-fundamentals'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 40,
    array['Describe what an editor does and why cuts work',
          'Read a timeline with video and audio tracks',
          'Choose resolution, frame rate and aspect ratio for a project',
          'Follow a professional editing workflow from import to export'],
    array['None'],
    array['video', 'editing', 'filmmaking', 'beginner'], false,
    '{"pattern": "frames", "hue": 345}')
  returning id into c;

  m1 := seed.module(c, 0, 'The craft of editing', 'Ideas that every editor uses.');

  perform seed.lesson(m1, 0, 'What video editing really is', 'article', 7,
    'Choosing, ordering and timing shots to tell a story.',
$md$## Editing is storytelling

**Video editing** is selecting the best moments from recorded footage, putting them in an order and timing them so they tell a story or deliver a message. Editors decide what the audience sees, for how long, and in what sequence.

A finished two-minute video might come from an hour of footage. Most of editing is **choosing what to leave out**.

## Key vocabulary

- **Footage** — the raw recorded video.
- **Clip** — one piece of footage placed in your project.
- **Shot** — a continuous recording from one camera angle.
- **Cut** — the point where one shot ends and the next begins.
- **Sequence** — clips arranged together in order.

## Why cuts work

Our brains accept cuts naturally because we already “cut” our attention many times a minute when we look around. A good cut is often invisible: the viewer follows the story and never notices the edit.

> [!TIP]
> Watch a scene from a favourite film with the sound off and count the cuts. You will notice far more than you expected — and that most of them felt invisible.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 1, 'The timeline, clips and cuts', 'article', 9,
    'Tracks, frame rates, resolution and the most useful types of cut.',
$md$## The timeline

Every editor has a **timeline**: time runs left to right, and clips sit on horizontal **tracks**.

- **Video tracks** are stacked: higher tracks appear *on top* of lower ones (useful for titles and overlays).
- **Audio tracks** sit below and play together.

The **playhead** is the vertical line that marks the current frame.

## Project settings

| Setting | Common values | Meaning |
| --- | --- | --- |
| **Resolution** | 1920×1080 (Full HD), 3840×2160 (4K) | Number of pixels in each frame |
| **Frame rate** | 24, 25, 30, 60 fps | Images shown per second |
| **Aspect ratio** | 16:9 (landscape), 9:16 (vertical), 1:1 | Shape of the frame |

> [!NOTE]
> Choose the frame rate before you start and keep it consistent. 24 fps feels cinematic, 25 is common for broadcast in many countries, and 60 is smooth for sports and games.

## Types of cut

- **Hard cut** — a straight switch from one shot to the next. The most common edit.
- **Jump cut** — a cut within the same shot that skips time; popular in vlogs.
- **J-cut** — the *audio* of the next shot starts before its video.
- **L-cut** — the audio of the current shot continues over the next shot’s video.
- **Cutaway** — briefly showing something else (a detail, a reaction) before returning.

## A professional workflow

1. **Organise** — import and name your footage in folders (bins).
2. **Assembly** — place the usable shots roughly in order.
3. **Rough cut** — shape the story; get the structure right.
4. **Fine cut** — perfect the timing of every cut.
5. **Colour and sound** — correct, grade and mix.
6. **Export** — render the final file for its destination.$md$,
    'published', false, 10);

  l := seed.lesson(m1, 2, 'Check your understanding', 'quiz', 4, 'Editing vocabulary and settings.', null, 'published', false, 15);
  q := seed.quiz(c, m1, l, 'Editing fundamentals quiz', 'knowledge_check', 70, 20);
  qq := seed.question(q, 0, 'single_choice', 'The audio of the next shot begins **before** its picture appears. What is this?', 'A J-cut: on the timeline the audio and video form the shape of the letter J.');
  perform seed.answer(qq, 0, 'L-cut', false, 'In an L-cut the audio of the *current* shot continues over the next picture.');
  perform seed.answer(qq, 1, 'J-cut', true);
  perform seed.answer(qq, 2, 'Jump cut', false, 'A jump cut skips time within one shot.');
  qq := seed.question(q, 1, 'single_choice', 'Which aspect ratio is standard for vertical phone videos?', '9:16 is vertical; 16:9 is landscape.');
  perform seed.answer(qq, 0, '16:9', false);
  perform seed.answer(qq, 1, '9:16', true);
  perform seed.answer(qq, 2, '4:3', false);
  qq := seed.question(q, 2, 'true_false', 'True or false: on most editors, a clip on a higher video track appears on top of clips below it.', 'Higher video tracks are layered over lower ones.');
  perform seed.answer(qq, 0, 'True', true);
  perform seed.answer(qq, 1, 'False', false);
end $seed$;

-- Course: Unreal Engine Fundamentals (premium, first lesson previewable)
do $seed$
declare
  c uuid; m1 uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('unreal-engine-fundamentals', 'Unreal Engine Fundamentals',
    'Understand game engines and find your way around Unreal Editor',
    $d$Unreal Engine is a professional real-time 3D engine used for games, films, architecture and simulation. This course explains what a game engine is, how to install Unreal Engine safely, and how the editor is organised — the foundation for every later Unreal course.$d$,
    seed.cat('game-development'), seed.cat('unreal-fundamentals'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'beginner', 'premium', 'published', 60,
    array['Explain what a game engine provides', 'Install Unreal Engine through the Epic Games Launcher',
          'Navigate the editor: Viewport, Outliner, Details and Content Drawer'],
    array['Computer Fundamentals from Zero', 'A reasonably powerful computer (see lesson 2)'],
    array['unreal', 'game development', 'real-time 3d'], true,
    '{"pattern": "hex", "hue": 175}')
  returning id into c;

  m1 := seed.module(c, 0, 'Getting started', 'Engines, installation and the editor.');

  perform seed.lesson(m1, 0, 'What is a game engine?', 'article', 7,
    'The shared foundation that saves teams years of work.',
$md$## Not starting from nothing

Every game needs to draw images, play sounds, read the controller, simulate physics and load levels. Writing all of that from scratch would take years. A **game engine** is a ready-made foundation that provides these systems so creators can focus on *their* game.

## What an engine typically provides

- **Rendering** — drawing 3D worlds in real time, many times per second.
- **Physics** — gravity, collisions and objects that fall and bounce.
- **Input** — keyboard, mouse, gamepad and touch.
- **Audio** — positional sound and music.
- **Scripting** — ways to describe game rules and behaviour.
- **Tools** — an editor to build levels and manage assets.

## Unreal Engine in particular

Unreal Engine is developed by Epic Games. Version 5 introduced systems such as **Nanite** (very detailed geometry) and **Lumen** (dynamic global illumination). Behaviour can be built with **Blueprints**, a visual node-based system, or written in **C++**.

> [!NOTE]
> Unreal Engine is free to download and learn. Commercial releases are subject to Epic’s licence terms — always read the current EULA on unrealengine.com before publishing a product.$md$,
    'published', true, 10);

  perform seed.lesson(m1, 1, 'Installing Unreal Engine', 'article', 10,
    'System requirements, the Epic Games Launcher and your first project.', null, 'in_review');
  perform seed.lesson(m1, 2, 'A tour of the editor', 'article', 12,
    'Viewport, Outliner, Details panel and Content Drawer.', null, 'draft');
end $seed$;

-- Course: Design Principles (free)
do $seed$
declare
  c uuid; m1 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('design-principles-from-zero', 'Design Principles from Zero',
    'Why some designs feel effortless — and how to make yours feel that way',
    $d$Good design is not decoration; it is communication. This course teaches the principles behind clear, beautiful work — hierarchy, contrast, alignment, proximity, repetition and white space — so you can judge and improve any poster, slide, website or app.$d$,
    seed.cat('graphic-design'), seed.cat('design-principles'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 35,
    array['Create a clear visual hierarchy', 'Use contrast, alignment and proximity deliberately', 'Critique a layout using precise vocabulary'],
    array['None'],
    array['design', 'layout', 'typography', 'ui'], false,
    '{"pattern": "circles", "hue": 295}')
  returning id into c;

  m1 := seed.module(c, 0, 'Seeing like a designer', 'The principles behind every strong layout.');

  perform seed.lesson(m1, 0, 'Visual hierarchy', 'article', 8,
    'Guiding the eye from the most important element to the least.',
$md$## Order of importance

**Visual hierarchy** is the arrangement of elements so that people notice them in order of importance. In a well-designed poster you see the title first, then the key detail (date, price), and only then the small print — without trying.

## Tools that create hierarchy

- **Size** — bigger elements are seen first.
- **Weight** — bold text stands out from regular text.
- **Colour and contrast** — a bright accent on a calm background draws attention.
- **Position** — people in left-to-right languages tend to start at the top left.
- **Space** — an element surrounded by empty space feels important.

> [!TIP]
> **The squint test:** squint at your design until it blurs. Whatever still stands out is what people will notice first. If that is not the most important thing, adjust the hierarchy.

## One focal point

If everything is bold, nothing is. Choose **one** primary element per screen or page, support it with one or two secondary elements, and keep everything else quiet.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 1, 'Contrast, alignment and proximity', 'article', 9,
    'Three principles that instantly make layouts look intentional.',
$md$## Contrast

**Contrast** is difference: large vs small, dark vs light, bold vs thin. Contrast creates interest and tells people which things are different. Make differences **obvious** — two font sizes that are almost the same look like a mistake.

> [!WARNING]
> Text must contrast strongly with its background to be readable. Accessibility guidelines (WCAG) recommend a contrast ratio of at least **4.5 : 1** for normal body text.

## Alignment

**Alignment** means placing elements along shared invisible lines. Aligned elements look connected and organised; randomly placed elements look careless. Pick one alignment (for example, everything left-aligned to the same edge) and stick to it.

## Proximity

**Proximity** means related items belong close together, and unrelated items are separated by space. A caption sits right under its photo; a new section starts after a larger gap.

## Repetition and white space

- **Repetition** — reuse the same colours, fonts and spacing so the design feels like one system.
- **White space** — empty space is not wasted space. It gives content room to breathe and makes everything easier to read.$md$,
    'published', false, 10);

  l := seed.lesson(m1, 2, 'Check your understanding', 'quiz', 4, 'Design vocabulary in practice.', null, 'published', false, 15);
  q := seed.quiz(c, m1, l, 'Design principles quiz', 'knowledge_check', 70, 20);
  qq := seed.question(q, 0, 'single_choice', 'A caption is placed far from its photo and close to an unrelated paragraph. Which principle is broken?', 'Proximity: related items should be grouped closely.');
  perform seed.answer(qq, 0, 'Proximity', true);
  perform seed.answer(qq, 1, 'Repetition', false);
  perform seed.answer(qq, 2, 'Contrast', false);
  qq := seed.question(q, 1, 'single_choice', 'What does the squint test reveal?', 'Blurring removes detail so you see only the strongest elements — your real hierarchy.');
  perform seed.answer(qq, 0, 'Spelling mistakes', false);
  perform seed.answer(qq, 1, 'Which elements dominate the hierarchy', true);
  perform seed.answer(qq, 2, 'Whether the colours are printable', false);
  qq := seed.question(q, 2, 'true_false', 'True or false: white space is wasted space and should be filled.', 'False — white space improves readability and focus.');
  perform seed.answer(qq, 0, 'True', false, 'Empty space helps people focus.');
  perform seed.answer(qq, 1, 'False', true);
end $seed$;

-- Courses in production (not visible to learners yet) --------------------------------
insert into public.courses (slug, title, subtitle, category_id, subcategory_id, instructor_id, level, access_tier, status, cover_style)
values
  ('css-from-zero', 'CSS from Zero', 'Colours, layout and responsive design', seed.cat('programming'), seed.cat('css'),
   (select id from public.instructors where slug = 'mahorat-editorial'), 'zero', 'free', 'draft', '{"pattern":"brackets","hue":220}'),
  ('javascript-from-zero', 'JavaScript from Zero', 'Make web pages interactive', seed.cat('programming'), seed.cat('javascript'),
   (select id from public.instructors where slug = 'mahorat-editorial'), 'zero', 'premium', 'draft', '{"pattern":"brackets","hue":50}'),
  ('davinci-resolve-essentials', 'DaVinci Resolve Essentials', 'Edit, colour and deliver', seed.cat('video-production'), seed.cat('davinci-resolve'),
   (select id from public.instructors where slug = 'mahorat-editorial'), 'beginner', 'premium', 'in_review', '{"pattern":"frames","hue":10}'),
  ('blender-modeling-foundations', 'Blender Modeling Foundations', 'Topology, modifiers and hard-surface basics', seed.cat('blender-3d'), seed.cat('modeling'),
   (select id from public.instructors where slug = 'mahorat-editorial'), 'beginner', 'premium', 'draft', '{"pattern":"isometric","hue":20}');

-- Learning paths ------------------------------------------------------------------------
insert into public.learning_paths (slug, title, subtitle, description, category_id, level_from, level_to, access_tier, status, cover_style, position, is_featured)
values
  ('web-developer', 'Web Developer', 'From your first tag to full-stack applications',
   'A structured route through computer basics, HTML, CSS, JavaScript and beyond. New courses are added to the path as they are published.',
   seed.cat('programming'), 'zero', 'professional', 'free', 'published', '{"pattern":"brackets","hue":255}', 0, true),
  ('3d-artist', '3D Artist', 'Think in three dimensions, render like a studio',
   'Start with what 3D is, master Blender’s interface, then progress into modeling, materials, lighting and animation.',
   seed.cat('blender-3d'), 'zero', 'professional', 'free', 'published', '{"pattern":"isometric","hue":28}', 1, true),
  ('game-developer', 'Game Developer', 'Design and build interactive worlds',
   'Programming fundamentals, 3D basics and Unreal Engine — the skills a game developer needs, in order.',
   seed.cat('game-development'), 'zero', 'professional', 'premium', 'published', '{"pattern":"hex","hue":175}', 2, true),
  ('creator', 'Digital Creator', 'Design, edit and publish with confidence',
   'Design principles, video editing and practical AI for people who create content.',
   seed.cat('graphic-design'), 'zero', 'intermediate', 'free', 'published', '{"pattern":"circles","hue":295}', 3, false);

insert into public.learning_path_courses (path_id, course_id, position)
select p.id, seed.course(x.course), x.pos
from (values
  ('web-developer', 'computer-fundamentals-from-zero', 0),
  ('web-developer', 'html-from-absolute-zero', 1),
  ('web-developer', 'css-from-zero', 2),
  ('web-developer', 'javascript-from-zero', 3),
  ('3d-artist', 'blender-first-steps-in-3d', 0),
  ('3d-artist', 'blender-modeling-foundations', 1),
  ('game-developer', 'computer-fundamentals-from-zero', 0),
  ('game-developer', 'python-for-complete-beginners', 1),
  ('game-developer', 'blender-first-steps-in-3d', 2),
  ('game-developer', 'unreal-engine-fundamentals', 3),
  ('creator', 'design-principles-from-zero', 0),
  ('creator', 'video-editing-fundamentals', 1),
  ('creator', 'ai-fundamentals-and-prompting', 2)
) as x(path, course, pos)
join public.learning_paths p on p.slug = x.path
where seed.course(x.course) is not null;
