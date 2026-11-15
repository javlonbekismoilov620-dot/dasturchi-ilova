-- Sprint 1 · Unreal Engine Fundamentals: lessons 2–3, module check, project and final
-- assessment (English + Oʻzbekcha). Lessons 2 and 3 already exist as unpublished rows; they
-- are completed in place so their IDs never change. Idempotent: safe to re-run.
do $content$
declare
  c constant text := 'unreal-engine-fundamentals';
  q uuid; qq uuid;
begin
  -- Lesson 2 ---------------------------------------------------------------------------
  perform seed.ensure_lesson(c, 'Getting started', 'Installing Unreal Engine', 'article', 14,
    'Check your computer, install the engine through the Epic Games Launcher and create your first project.',
$md$## Before you install: is your computer ready?

Unreal Engine is professional software that renders detailed 3D worlds in real time, so it asks a lot of your computer. Requirements change between engine versions, so always open the official **Hardware and Software Specifications** page in the Unreal Engine documentation for the exact version you are installing. The table below is practical guidance for learning, not an official specification.

| Part | Workable for learning | Comfortable |
| --- | --- | --- |
| Operating system | 64-bit Windows 10/11 or a recent macOS | The same, fully updated |
| Processor (CPU) | Recent quad-core | 6–8 cores or more |
| Memory (RAM) | 16 GB | 32 GB or more |
| Graphics (GPU) | Dedicated graphics card with current drivers | More video memory (8 GB or more) |
| Storage | SSD with plenty of free space | Fast NVMe SSD |

> [!NOTE]
> The engine installation alone typically takes several tens of gigabytes, and projects grow as you add content. Install on an SSD rather than a hard drive: the editor opens and compiles far faster.

Laptops with only integrated graphics can usually open the editor, but advanced lighting features may be slow. You will learn to lower the quality settings at the end of this lesson. Linux is supported through separate downloads; this course shows Windows and macOS.

## Step 1: Create an Epic Games account

Unreal Engine is distributed by Epic Games. Create a free account at **epicgames.com** and turn on two-factor authentication for security.

## Step 2: Install the Epic Games Launcher

Download the **Epic Games Launcher** from the official Epic Games or Unreal Engine website, install it and sign in.

> [!WARNING]
> Download only from official Epic Games websites. Unofficial “free Unreal Engine” downloads are a common way to spread malware — the real engine is free from Epic.

## Step 3: Install an engine version

1. In the Launcher, open **Unreal Engine** in the left sidebar, then the **Library** tab.
2. Next to **Engine Versions**, click the **+** button and choose the latest 5.x release (this course states the version it was recorded with).
3. Click **Install**, then choose a folder on your SSD.
4. Open **Options** before confirming. **Starter Content** and **Templates and Feature Packs** are useful for learning. **Editor symbols for debugging** are large and only needed for C++ debugging, and extra **Target Platforms** (such as Android or iOS) can be added later.

The download is large. You can keep using your computer while it installs.

## Step 4: The first launch

Click **Launch**. The first start can take a long time because Unreal prepares its **shaders** — small programs that tell the graphics card how to draw materials. You may see a percentage counter. This is normal and happens mostly the first time you open a version or a project.

## Step 5: Create your first project

The **Unreal Project Browser** opens.

1. Choose the **Games** category, then the **Third Person** template. It gives you a playable character, so you can test things immediately.
2. Under the project defaults, choose **Blueprint** (you will learn C++ later), target **Desktop**, and quality preset **Maximum** — or **Scalable** on a modest computer.
3. Keep **Starter Content** enabled. It adds free props and materials to practise with.
4. Pick a location and a short name without spaces, such as `MyFirstProject`, and click **Create**.

When the editor opens, press **Alt + P** (or the **Play** button) to walk around with the character. Press **Esc** to stop playing.

## Licence awareness

Unreal Engine is free to download and learn. If you release a commercial product, Epic's licence terms apply, including possible royalties above certain revenue thresholds. These terms change, so read the current **EULA** on Epic's website before you publish anything.

## Common problems

| Problem | What to do |
| --- | --- |
| The download is stuck or very slow | Pause and resume it in the Launcher, and check that the drive has enough free space |
| The editor crashes on start | Update your graphics drivers from NVIDIA, AMD or Intel, then restart the computer |
| The editor is very slow | Open **Settings → Engine Scalability Settings** in the viewport toolbar and choose **Medium** or **Low** |
| “Not enough disk space” | Install the engine or the project on a drive with more free space |

## Try it

Install the engine, create `MyFirstProject` from the Third Person template, press **Play**, run around the level and then stop with **Esc**.

## Key terms

- **Epic Games Launcher** — the app that installs and updates Unreal Engine.
- **Engine version** — a numbered release such as 5.x; projects open in the version they were made with.
- **Template** — a ready-made starting project (Blank, First Person, Third Person and others).
- **Shaders** — programs the graphics card uses to draw surfaces; Unreal compiles them the first time.$md$,
    'published', false, 15);

  -- Lesson 3 ---------------------------------------------------------------------------
  perform seed.ensure_lesson(c, 'Getting started', 'A tour of the editor', 'article', 14,
    'Find your way around the Unreal Editor: viewport, Outliner, Details, Content Drawer, play controls and saving.',
$md$## The main areas of the editor

When your project opens, you see the **Level Editor**. Its default layout has six areas worth knowing by name:

1. **Main toolbar** (top) — saving, the editing mode selector, the **Quickly add to the project** button for placing actors, and the **Play** controls.
2. **Level Viewport** (centre) — your window into the level. Here you look around, select objects and move them.
3. **Outliner** (top right) — a list of every **actor** (object) in the level, like a table of contents.
4. **Details panel** (right, below the Outliner) — the properties of whatever is selected: its position, rotation and scale (the **Transform**), its components and its settings.
5. **Content Drawer** (bottom, or press **Ctrl + Space**) — all the **assets** in your project: meshes, materials, textures, sounds and Blueprints, organised in folders.
6. **Bottom toolbar** — the Output Log and a console for advanced commands.

> [!TIP]
> Every panel can be closed, moved and docked. If you lose one, open it again from the **Window** menu. **Window → Load Layout → Default Editor Layout** restores the original arrangement.

## Moving around the viewport

| Action | How |
| --- | --- |
| Fly through the level | Hold the **right mouse button** and use **W A S D** (Q and E move down and up) |
| Change flying speed | While holding the right mouse button, scroll the mouse wheel |
| Focus on the selected actor | Press **F** |
| Orbit around the focus point | **Alt + left mouse button** drag |
| Zoom | Scroll the mouse wheel |

If you know Blender, notice the difference: Blender orbits with the middle mouse button, while Unreal is built around flying like a game camera.

## Selecting and transforming actors

- **Click** an actor to select it; **Ctrl + click** adds or removes actors from the selection.
- **W** switches to Move, **E** to Rotate and **R** to Scale. Drag the coloured handles of the **gizmo**: red is X, green is Y and blue is Z. In Unreal, **Z points up**.
- **End** drops the selected actor onto the surface below it.
- **Ctrl + D** duplicates the selection, and **Delete** removes it.
- In the viewport toolbar you can switch between **world** and **local** axes and turn **grid snapping** on or off for movement, rotation and scale.

## Placing actors

There are two everyday ways to add something to the level:

- Click **Quickly add to the project** in the main toolbar and choose, for example, **Shapes → Cube**.
- Drag an asset from the **Content Drawer** into the viewport. Starter Content has chairs, tables, lamps and materials in its folders.

## Play and Simulate

- **Play** (**Alt + P**) starts the game in the viewport with you controlling the player. Press **Esc** to stop.
- **Simulate** (**Alt + S**) runs physics and logic while you keep the editor camera, which is useful for watching things happen.

> [!WARNING]
> Changes you make to the level **while playing** are thrown away when you stop. Always stop playing before you edit.

## Saving your work

- **Ctrl + S** saves the current level. **Ctrl + Shift + S** (**Save All**) saves every changed asset.
- Levels are saved as `.umap` files and other assets as `.uasset` files inside the project's `Content` folder.

> [!WARNING]
> Never move or rename asset files in Windows Explorer or Finder. Unreal keeps references between assets; moving files outside the editor breaks them. Always rename and move assets inside the Content Drawer.

## Keeping a project tidy

Professional teams name assets with short prefixes so they can find them quickly:

| Prefix | Asset type |
| --- | --- |
| `SM_` | Static mesh |
| `M_` | Material |
| `MI_` | Material instance |
| `T_` | Texture |
| `BP_` | Blueprint |

Create your own folder (for example `Content/MyFirstProject`) so your work never mixes with Starter Content.

## Try it: a ten-step tour

1. Open the Content Drawer with **Ctrl + Space**.
2. Find a chair in the Starter Content `Props` folder.
3. Drag it into the level.
4. Press **F** to focus on it.
5. Move it with **W** along the X axis only.
6. Rotate it 90° with **E** and grid snapping on.
7. Duplicate it with **Ctrl + D** and place the copy next to the table.
8. Find both chairs in the Outliner and rename one of them.
9. Press **Alt + P**, walk to the chairs, then stop with **Esc**.
10. Save everything with **Ctrl + Shift + S**.

## Common mistakes

- Editing while the game is playing — the changes disappear when you stop.
- Losing the view — select something and press **F**, or use the **Perspective** menu to reset the view.
- Moving files outside the editor — broken references and missing assets.

## Key terms

- **Actor** — anything placed in a level: a mesh, a light, a camera, a character.
- **Asset** — a file in the Content Drawer that actors can use, such as a mesh or a material.
- **Transform** — an actor's location, rotation and scale.
- **Level** — a map that contains actors; saved as a `.umap` file.$md$,
    'published', false, 15);

  -- Module knowledge check -------------------------------------------------------------
  perform seed.ensure_lesson(c, 'Getting started', 'Check your understanding', 'quiz', 5,
    'Five questions on engines, installation and the editor.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Check your understanding', 'Getting started check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice',
    'Why do game teams use an engine such as Unreal instead of writing everything themselves?',
    'An engine provides rendering, physics, input, audio, scripting and tools, so teams can focus on their own game.',
    array['It provides ready-made systems like rendering, physics and input', 'It designs the game automatically', 'It is required by app stores'],
    array[true, false, false],
    array[null, 'An engine is a foundation of systems and tools; people still design and build the game.', 'Stores do not require any particular engine.']);
  perform seed.ensure_question(q, 1, 'single_choice',
    'Where should you download Unreal Engine from?',
    'Only from Epic Games — through the official Epic Games Launcher.',
    array['The Epic Games Launcher from the official Epic website', 'Any site that offers a free download', 'A file shared in a chat group'],
    array[true, false, false],
    array[null, 'Unofficial downloads are a common way to spread malware.', 'Files from chats can be modified or infected.']);
  perform seed.ensure_question(q, 2, 'single_choice',
    'The first launch shows a long “preparing shaders” counter. What does that mean?',
    'Unreal compiles shaders the first time; it is normal and mostly happens once per version or project.',
    array['Unreal is compiling shaders, which is normal the first time', 'The installation is broken', 'Your licence is being checked'],
    array[true, false, false],
    array[null, 'Shader compilation is expected on first launch.', 'Shader compilation has nothing to do with licences.']);
  perform seed.ensure_question(q, 3, 'single_choice',
    'Which panel lists every actor in the current level?',
    'The Outliner lists the actors in the level; the Details panel shows the properties of the selected one.',
    array['Outliner', 'Details', 'Content Drawer'],
    array[true, false, false],
    array[null, 'The Details panel shows the properties of the selected actor.', 'The Content Drawer lists assets in the project, not actors in the level.']);
  perform seed.ensure_question(q, 4, 'true_false',
    'True or false: changes you make to the level while the game is playing are kept when you stop.',
    'False — changes made during Play are thrown away when you stop. Stop playing before editing.',
    array['True', 'False'], array[false, true],
    array['They are discarded when you stop playing.', null]);

  -- Project and final assessment ---------------------------------------------------------
  perform seed.ensure_module(c, 'Project and final assessment', 'Build your first scene and show what you have learned.');

  perform seed.ensure_lesson(c, 'Project and final assessment', 'Project: your first scene', 'project', 40,
    'Set up a project and build a small, tidy scene from Starter Content using the editor tools.',
$md$## Your first Unreal project

Use what you learned in this module to build a small room or outdoor corner from **Starter Content** props. The goal is not beautiful art yet — it is confident, tidy use of the editor.

### Requirements

1. A project created from a template that opens without errors.
2. At least **10 props** from Starter Content placed in the level.
3. Use all three transform tools (**W**, **E**, **R**) and grid snapping; props rest on surfaces (use **End**).
4. Every placed actor has a meaningful name in the Outliner (for example `Chair_Kitchen_01`).
5. Your own folder in the Content Drawer for anything you create or duplicate.
6. The level and all assets are saved.

### How to submit

Upload **three screenshots** — two from different viewpoints in the editor and one from **Play** mode — and write two or three sentences about what you built and which tools you used. You can also paste a link to a short screen recording.

> [!NOTE]
> A reviewer checks your work against the rubric and leaves feedback. You can improve your scene and resubmit.$md$,
    'published', false, 50);
  perform seed.ensure_assignment(c, 'Project: your first scene', 'Your first scene',
    'Build a small, tidy scene from Starter Content and submit three screenshots with a short description.',
$r$| Criterion | Points |
| --- | --- |
| Project created from a template, saved, opens without errors | 15 |
| At least 10 Starter Content props placed with move, rotate and scale | 25 |
| Deliberate arrangement: snapping and props resting on surfaces | 20 |
| Meaningful actor names in the Outliner and an own Content folder | 20 |
| Three screenshots (two viewpoints, one in Play mode) with a short description | 20 |$r$);

  perform seed.ensure_lesson(c, 'Project and final assessment', 'Final assessment', 'quiz', 8,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'Unreal Engine Fundamentals — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which template gives you a playable character so you can test your level immediately?',
    'The Third Person template includes a character you can control with Play.',
    array['Blank', 'Third Person', 'Film/Video & Live Events'], array[false, true, false],
    array['Blank starts with an empty project and no character.', null, 'That category is for film and virtual production, not a playable character.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'You have not learned C++ yet. Which project type should you choose?',
    'Blueprint projects need no C++; you can add C++ later.',
    array['Blueprint', 'C++'], array[true, false],
    array[null, 'C++ projects need a compiler and C++ knowledge; start with Blueprint.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'How do you fly through the level in the viewport?',
    'Hold the right mouse button and use W A S D, like a game camera.',
    array['Hold the right mouse button and use W A S D', 'Hold the middle mouse button and drag', 'Press the arrow keys only'], array[true, false, false],
    array[null, 'That is how Blender orbits; Unreal flies with the right mouse button.', 'Arrow keys alone do not give you full camera control.']);
  perform seed.ensure_question(q, 3, 'single_choice', 'Which key focuses the viewport on the selected actor?',
    '**F** frames the selected actor.',
    array['F', 'G', 'Home'], array[true, false, false],
    array[null, 'G toggles game view in the viewport.', 'Home does not frame the selection in Unreal.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'Which keys switch the gizmo between Move, Rotate and Scale?',
    '**W** moves, **E** rotates and **R** scales.',
    array['W, E, R', 'G, R, S', 'M, R, S'], array[true, false, false],
    array[null, 'G, R and S are Blender''s shortcuts.', 'These are not Unreal shortcuts.']);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which axis points up in Unreal Engine?',
    'Unreal is Z-up, like Blender.',
    array['X', 'Y', 'Z'], array[false, false, true], null);
  perform seed.ensure_question(q, 6, 'single_choice', 'You want to rename a texture asset. Where do you do it?',
    'Rename and move assets inside the Content Drawer so Unreal can keep references between assets intact.',
    array['In the Content Drawer', 'In Windows Explorer or Finder', 'Either — it makes no difference'], array[true, false, false],
    array[null, 'Renaming outside the editor breaks references between assets.', 'It matters: only the editor updates references.']);
  perform seed.ensure_question(q, 7, 'true_false', 'True or false: Unreal Engine is free to learn, but commercial releases are subject to Epic''s licence terms.',
    'True. Read the current EULA before publishing a commercial product.',
    array['True', 'False'], array[true, false],
    array[null, 'Commercial releases are covered by Epic''s licence, which can include royalties.']);

  perform seed.order_modules(c, array['Getting started', 'Project and final assessment']);
  perform seed.order_lessons(c, 'Getting started', array['What is a game engine?', 'Installing Unreal Engine', 'A tour of the editor', 'Check your understanding']);
  perform seed.order_lessons(c, 'Project and final assessment', array['Project: your first scene', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'unreal-engine-fundamentals';
begin
  perform seed.tr_module(c, 'Project and final assessment', 'uz', 'Loyiha va yakuniy imtihon',
    'Birinchi sahnangizni yarating va oʻrganganlaringizni koʻrsating.');

  perform seed.tr_lesson(c, 'Installing Unreal Engine', 'uz', 'Unreal Engine’ni oʻrnatish',
    'Kompyuteringizni tekshiring, dvigatelni Epic Games Launcher orqali oʻrnating va birinchi loyihangizni yarating.',
$md$## Oʻrnatishdan oldin: kompyuteringiz tayyormi?

Unreal Engine — batafsil 3D olamlarni real vaqtda chizadigan professional dastur, shuning uchun u kompyuterdan koʻp narsa talab qiladi. Talablar dvigatel versiyasiga qarab oʻzgaradi, shu bois oʻrnatayotgan versiyangiz uchun Unreal Engine hujjatlaridagi rasmiy **Hardware and Software Specifications** (apparat va dasturiy taʼminot talablari) sahifasini albatta oching. Quyidagi jadval rasmiy talab emas, balki oʻqish uchun amaliy tavsiya.

| Qism | Oʻqish uchun yetarli | Qulay ishlash uchun |
| --- | --- | --- |
| Operatsion tizim | 64 bitli Windows 10/11 yoki yangi macOS | Xuddi shunday, toʻliq yangilangan |
| Protsessor (CPU) | Yangi avlod toʻrt yadroli | 6–8 va undan ortiq yadro |
| Operativ xotira (RAM) | 16 GB | 32 GB va undan koʻp |
| Grafika (GPU) | Drayverlari yangilangan alohida videokarta | Koʻproq video xotira (8 GB va undan ortiq) |
| Doimiy xotira | Boʻsh joyi yetarli SSD | Tezkor NVMe SSD |

> [!NOTE]
> Dvigatelning oʻzi odatda bir necha oʻn gigabayt joy egallaydi, loyihalar esa kontent qoʻshilgani sari kattalashadi. Dvigatelni qattiq diskka emas, SSD ga oʻrnating: muharrir ancha tez ochiladi va kompilyatsiya qiladi.

Faqat integratsiyalashgan grafikaga ega noutbuklar odatda muharrirni ocha oladi, biroq murakkab yoritish imkoniyatlari sekin ishlashi mumkin. Dars oxirida sifat sozlamalarini qanday pasaytirishni oʻrganasiz. Linux alohida yuklab olinadigan versiyalar orqali qoʻllab-quvvatlanadi; bu kursda Windows va macOS koʻrsatiladi.

## 1-qadam: Epic Games hisobini yarating

Unreal Engine’ni Epic Games kompaniyasi tarqatadi. **epicgames.com** saytida bepul hisob yarating va xavfsizlik uchun ikki bosqichli autentifikatsiyani yoqing.

## 2-qadam: Epic Games Launcher dasturini oʻrnating

**Epic Games Launcher** dasturini Epic Games yoki Unreal Engine’ning rasmiy saytidan yuklab oling, oʻrnating va hisobingizga kiring.

> [!WARNING]
> Faqat Epic Games’ning rasmiy saytlaridan yuklab oling. Norasmiy “bepul Unreal Engine” yuklamalari zararli dasturlarni tarqatishning keng tarqalgan usuli — haqiqiy dvigatel Epic’da bepul.

## 3-qadam: Dvigatel versiyasini oʻrnating

1. Launcher’da chap paneldagi **Unreal Engine** boʻlimini, soʻngra **Library** yorligʻini oching.
2. **Engine Versions** yonidagi **+** tugmasini bosing va eng soʻnggi 5.x versiyani tanlang (kursda qaysi versiyada yozilgani koʻrsatiladi).
3. **Install** tugmasini bosing va SSD dagi papkani tanlang.
4. Tasdiqlashdan oldin **Options** ni oching. Oʻqish uchun **Starter Content** va **Templates and Feature Packs** foydali. **Editor symbols for debugging** katta hajmli va faqat C++ kodini tuzatish uchun kerak, qoʻshimcha **Target Platforms** (masalan, Android yoki iOS) esa keyinroq qoʻshilishi mumkin.

Yuklama katta hajmli. Oʻrnatilayotgan paytda kompyuterdan foydalanishda davom etishingiz mumkin.

## 4-qadam: Birinchi ishga tushirish

**Launch** tugmasini bosing. Birinchi ishga tushirish uzoq davom etishi mumkin, chunki Unreal **sheyderlar**ni (*shaders*) tayyorlaydi — bu videokartaga materiallarni qanday chizishni aytadigan kichik dasturlar. Foiz hisoblagichini koʻrishingiz mumkin. Bu odatiy hol va asosan versiya yoki loyiha birinchi marta ochilganda sodir boʻladi.

## 5-qadam: Birinchi loyihangizni yarating

**Unreal Project Browser** (loyihalar oynasi) ochiladi.

1. **Games** toifasini, soʻngra **Third Person** shablonini tanlang. U boshqariladigan personaj beradi, shuning uchun narsalarni darhol sinab koʻrishingiz mumkin.
2. Loyiha sozlamalarida **Blueprint** ni (C++ ni keyinroq oʻrganasiz), maqsadli platforma sifatida **Desktop** ni va sifat darajasi sifatida **Maximum** ni — oddiyroq kompyuterda esa **Scalable** ni tanlang.
3. **Starter Content** yoqilgan holda qolsin. U mashq qilish uchun bepul buyumlar va materiallar qoʻshadi.
4. Joylashuvni va boʻsh joysiz qisqa nomni, masalan, `MyFirstProject` ni tanlab, **Create** tugmasini bosing.

Muharrir ochilgach, personaj bilan yurib koʻrish uchun **Alt + P** ni (yoki **Play** tugmasini) bosing. Oʻyinni toʻxtatish uchun **Esc** ni bosing.

## Litsenziya haqida

Unreal Engine’ni yuklab olish va oʻrganish bepul. Agar tijoriy mahsulot chiqarsangiz, Epic litsenziya shartlari amal qiladi, jumladan, maʼlum daromad chegarasidan yuqorida royalti toʻlash talab qilinishi mumkin. Bu shartlar oʻzgarib turadi, shuning uchun biror narsani eʼlon qilishdan oldin Epic saytidagi amaldagi **EULA** (litsenziya kelishuvi) ni oʻqing.

## Keng tarqalgan muammolar

| Muammo | Nima qilish kerak |
| --- | --- |
| Yuklab olish toʻxtab qolgan yoki juda sekin | Launcher’da yuklamani pauza qilib, qayta davom ettiring va diskda boʻsh joy yetarliligini tekshiring |
| Muharrir ishga tushganda yopilib qoladi | Videokarta drayverlarini NVIDIA, AMD yoki Intel saytidan yangilang va kompyuterni qayta ishga tushiring |
| Muharrir juda sekin ishlaydi | Koʻrinish maydoni panelidagi **Settings → Engine Scalability Settings** ni oching va **Medium** yoki **Low** ni tanlang |
| “Diskda joy yetarli emas” | Dvigatel yoki loyihani boʻsh joyi koʻproq diskka oʻrnating |

## Oʻzingiz sinab koʻring

Dvigatelni oʻrnating, Third Person shablonidan `MyFirstProject` loyihasini yarating, **Play** ni bosing, daraja boʻylab yuguring va **Esc** bilan toʻxtating.

## Asosiy atamalar

- **Epic Games Launcher** — Unreal Engine’ni oʻrnatadigan va yangilaydigan dastur.
- **Dvigatel versiyasi** — 5.x kabi raqamlangan reliz; loyihalar ular yaratilgan versiyada ochiladi.
- **Shablon** (*template*) — tayyor boshlangʻich loyiha (Blank, First Person, Third Person va boshqalar).
- **Sheyderlar** (*shaders*) — videokarta sirtlarni chizish uchun foydalanadigan dasturlar; Unreal ularni birinchi marta kompilyatsiya qiladi.$md$);

  perform seed.tr_lesson(c, 'A tour of the editor', 'uz', 'Muharrir boʻylab sayohat',
    'Unreal Editor’da yoʻlingizni toping: koʻrinish maydoni, Outliner, Details, Content Drawer, oʻyinni ishga tushirish va saqlash.',
$md$## Muharrirning asosiy qismlari

Loyihangiz ochilganda **Level Editor** (daraja muharriri) ni koʻrasiz. Uning standart joylashuvida nomini bilib olish kerak boʻlgan oltita qism bor:

1. **Asosiy asboblar paneli** (yuqorida) — saqlash, tahrirlash rejimini tanlash, obyekt joylashtirish uchun **Quickly add to the project** tugmasi va **Play** boshqaruvlari.
2. **Level Viewport** (koʻrinish maydoni, markazda) — darajaga ochilgan oynangiz. Bu yerda atrofni koʻzdan kechirasiz, obyektlarni tanlaysiz va siljitasiz.
3. **Outliner** (oʻng yuqorida) — darajadagi barcha **aktorlar** (obyektlar) roʻyxati, xuddi mundarija kabi.
4. **Details paneli** (oʻngda, Outliner ostida) — tanlangan narsaning xususiyatlari: joylashuvi, burilishi va masshtabi (**Transform**), komponentlari va sozlamalari.
5. **Content Drawer** (pastda yoki **Ctrl + Space**) — loyihangizdagi barcha **resurslar** (*assets*): meshlar, materiallar, teksturalar, tovushlar va Blueprint’lar papkalarga ajratilgan holda.
6. **Pastki asboblar paneli** — Output Log (jurnal) va murakkab buyruqlar uchun konsol.

> [!TIP]
> Har bir panelni yopish, koʻchirish va biriktirish mumkin. Biror panelni yoʻqotib qoʻysangiz, uni **Window** menyusidan qayta oching. **Window → Load Layout → Default Editor Layout** dastlabki joylashuvni tiklaydi.

## Koʻrinish maydonida harakatlanish

| Harakat | Qanday qilinadi |
| --- | --- |
| Daraja boʻylab uchish | **Sichqonchaning oʻng tugmasini** bosib turib, **W A S D** dan foydalaning (Q va E pastga va yuqoriga siljitadi) |
| Uchish tezligini oʻzgartirish | Oʻng tugmani bosib turgan holda sichqoncha gʻildiragini aylantiring |
| Tanlangan aktorga eʼtibor qaratish | **F** ni bosing |
| Diqqat nuqtasi atrofida aylanish | **Alt + sichqonchaning chap tugmasi** bilan torting |
| Yaqinlashtirish | Sichqoncha gʻildiragini aylantiring |

Agar Blenderni bilsangiz, farqqa eʼtibor bering: Blender oʻrta tugma bilan aylantiradi, Unreal esa oʻyin kamerasi kabi uchishga asoslangan.

## Aktorlarni tanlash va transformatsiya qilish

- Aktorni tanlash uchun uni **bosing**; **Ctrl + bosish** tanlovga aktor qoʻshadi yoki undan olib tashlaydi.
- **W** siljitishga, **E** aylantirishga, **R** masshtablashga oʻtkazadi. **Gizmo**ning rangli dastaklarini torting: qizil — X, yashil — Y, koʻk — Z. Unreal’da **Z oʻqi yuqoriga qaragan**.
- **End** tanlangan aktorni ostidagi sirtga tushiradi.
- **Ctrl + D** tanlovni nusxalaydi, **Delete** esa oʻchiradi.
- Koʻrinish maydoni panelida **global** (*world*) va **lokal** (*local*) oʻqlar orasida almashish hamda siljitish, aylantirish va masshtablash uchun **toʻrga yopishish**ni (*grid snapping*) yoqish yoki oʻchirish mumkin.

## Aktorlarni joylashtirish

Darajaga biror narsa qoʻshishning ikkita kundalik usuli bor:

- Asosiy asboblar panelidagi **Quickly add to the project** tugmasini bosing va, masalan, **Shapes → Cube** ni tanlang.
- **Content Drawer** dan resursni koʻrinish maydoniga torting. Starter Content papkalarida stullar, stollar, chiroqlar va materiallar bor.

## Play va Simulate

- **Play** (**Alt + P**) oʻyinni koʻrinish maydonida ishga tushiradi va oʻyinchini siz boshqarasiz. Toʻxtatish uchun **Esc** ni bosing.
- **Simulate** (**Alt + S**) muharrir kamerasi sizda qolgan holda fizika va mantiqni ishga tushiradi — jarayonlarni kuzatish uchun qulay.

> [!WARNING]
> Oʻyin **ishlab turgan paytda** darajaga kiritgan oʻzgarishlaringiz toʻxtatganingizda bekor boʻladi. Tahrirlashdan oldin har doim oʻyinni toʻxtating.

## Ishingizni saqlash

- **Ctrl + S** joriy darajani saqlaydi. **Ctrl + Shift + S** (**Save All**) oʻzgargan barcha resurslarni saqlaydi.
- Darajalar `.umap` fayllari, boshqa resurslar esa loyihaning `Content` papkasida `.uasset` fayllari sifatida saqlanadi.

> [!WARNING]
> Resurs fayllarini hech qachon Windows Explorer yoki Finder orqali koʻchirmang va qayta nomlamang. Unreal resurslar orasidagi bogʻlanishlarni saqlaydi; fayllarni muharrirdan tashqarida koʻchirish bu bogʻlanishlarni buzadi. Resurslarni har doim Content Drawer ichida qayta nomlang va koʻchiring.

## Loyihani tartibli saqlash

Professional jamoalar resurslarni tez topish uchun ularga qisqa prefiksli nomlar beradi:

| Prefiks | Resurs turi |
| --- | --- |
| `SM_` | Statik mesh |
| `M_` | Material |
| `MI_` | Material nusxasi (*material instance*) |
| `T_` | Tekstura |
| `BP_` | Blueprint |

Ishingiz Starter Content bilan aralashib ketmasligi uchun oʻz papkangizni yarating (masalan, `Content/MyFirstProject`).

## Oʻzingiz sinab koʻring: oʻn qadamli sayohat

1. **Ctrl + Space** bilan Content Drawer ni oching.
2. Starter Content’ning `Props` papkasidan stul toping.
3. Uni darajaga torting.
4. Unga eʼtibor qaratish uchun **F** ni bosing.
5. Uni **W** yordamida faqat X oʻqi boʻylab siljiting.
6. Toʻrga yopishish yoqilgan holda **E** bilan 90° ga aylantiring.
7. **Ctrl + D** bilan nusxalang va nusxani stol yoniga qoʻying.
8. Ikkala stulni Outliner’dan toping va ulardan birini qayta nomlang.
9. **Alt + P** ni bosing, stullar yoniga boring va **Esc** bilan toʻxtating.
10. Hammasini **Ctrl + Shift + S** bilan saqlang.

## Keng tarqalgan xatolar

- Oʻyin ishlab turganda tahrirlash — toʻxtatganingizda oʻzgarishlar yoʻqoladi.
- Koʻrinishni yoʻqotib qoʻyish — biror narsani tanlab **F** ni bosing yoki koʻrinishni tiklash uchun **Perspective** menyusidan foydalaning.
- Fayllarni muharrirdan tashqarida koʻchirish — bogʻlanishlar buziladi va resurslar yoʻqoladi.

## Asosiy atamalar

- **Aktor** (*actor*) — darajaga joylashtirilgan har qanday narsa: mesh, yorugʻlik manbai, kamera, personaj.
- **Resurs** (*asset*) — Content Drawer dagi, aktorlar foydalanishi mumkin boʻlgan fayl, masalan, mesh yoki material.
- **Transform** — aktorning joylashuvi, burilishi va masshtabi.
- **Daraja** (*level*) — aktorlarni oʻz ichiga olgan xarita; `.umap` fayli sifatida saqlanadi.$md$);

  perform seed.tr_lesson(c, 'Check your understanding', 'uz', 'Bilimingizni tekshiring',
    'Dvigatellar, oʻrnatish va muharrir boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Getting started check', 'uz', 'Ishni boshlash boʻyicha test');
  perform seed.tr_question(c, 'Getting started check', 0, 'uz',
    'Nega oʻyin jamoalari hamma narsani oʻzlari yozish oʻrniga Unreal kabi dvigateldan foydalanadi?',
    'Dvigatel rendering, fizika, kiritish, audio, skriptlash va vositalarni taqdim etadi, shuning uchun jamoalar oʻz oʻyiniga eʼtibor qarata oladi.',
    array['U rendering, fizika va kiritish kabi tayyor tizimlarni taqdim etadi', 'U oʻyinni avtomatik loyihalaydi', 'Ilova doʻkonlari buni talab qiladi'],
    array[null, 'Dvigatel — tizimlar va vositalardan iborat poydevor; oʻyinni baribir odamlar loyihalaydi va yaratadi.', 'Doʻkonlar biror muayyan dvigatelni talab qilmaydi.']);
  perform seed.tr_question(c, 'Getting started check', 1, 'uz',
    'Unreal Engine’ni qayerdan yuklab olish kerak?',
    'Faqat Epic Games’dan — rasmiy Epic Games Launcher orqali.',
    array['Epic’ning rasmiy saytidagi Epic Games Launcher orqali', 'Bepul yuklab olishni taklif qiladigan istalgan saytdan', 'Chat guruhida ulashilgan fayldan'],
    array[null, 'Norasmiy yuklamalar zararli dasturlarni tarqatishning keng tarqalgan usuli.', 'Chatlardagi fayllar oʻzgartirilgan yoki zararlangan boʻlishi mumkin.']);
  perform seed.tr_question(c, 'Getting started check', 2, 'uz',
    'Birinchi ishga tushirishda uzoq davom etadigan “preparing shaders” hisoblagichi koʻrinadi. Bu nimani bildiradi?',
    'Unreal sheyderlarni birinchi marta kompilyatsiya qiladi; bu odatiy hol va asosan har bir versiya yoki loyiha uchun bir marta sodir boʻladi.',
    array['Unreal sheyderlarni kompilyatsiya qilmoqda — birinchi marta bu odatiy hol', 'Oʻrnatish buzilgan', 'Litsenziyangiz tekshirilmoqda'],
    array[null, 'Birinchi ishga tushirishda sheyder kompilyatsiyasi kutilgan jarayon.', 'Sheyder kompilyatsiyasining litsenziyaga aloqasi yoʻq.']);
  perform seed.tr_question(c, 'Getting started check', 3, 'uz',
    'Qaysi panel joriy darajadagi barcha aktorlarni roʻyxat qilib koʻrsatadi?',
    'Outliner darajadagi aktorlar roʻyxatini koʻrsatadi; Details paneli esa tanlangan aktorning xususiyatlarini koʻrsatadi.',
    array['Outliner', 'Details', 'Content Drawer'],
    array[null, 'Details paneli tanlangan aktorning xususiyatlarini koʻrsatadi.', 'Content Drawer darajadagi aktorlarni emas, loyihadagi resurslarni koʻrsatadi.']);
  perform seed.tr_question(c, 'Getting started check', 4, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: oʻyin ishlab turgan paytda darajaga kiritilgan oʻzgarishlar toʻxtatilgandan keyin ham saqlanib qoladi.',
    'Notoʻgʻri — Play paytida kiritilgan oʻzgarishlar toʻxtatilganda bekor boʻladi. Tahrirlashdan oldin oʻyinni toʻxtating.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Oʻyin toʻxtatilganda ular bekor boʻladi.', null]);

  perform seed.tr_lesson(c, 'Project: your first scene', 'uz', 'Loyiha: birinchi sahnangiz',
    'Loyiha yarating va muharrir vositalari yordamida Starter Content’dan kichik, tartibli sahna yasang.',
$md$## Birinchi Unreal loyihangiz

Ushbu modulda oʻrganganlaringizdan foydalanib, **Starter Content** buyumlaridan kichik xona yoki ochiq maydon burchagini yarating. Hozircha maqsad chiroyli sanʼat asari emas — muharrirdan ishonch bilan va tartibli foydalanish.

### Talablar

1. Shablondan yaratilgan va xatosiz ochiladigan loyiha.
2. Darajaga joylashtirilgan kamida **10 ta** Starter Content buyumi.
3. Uchala transformatsiya vositasidan (**W**, **E**, **R**) va toʻrga yopishishdan foydalanilgan; buyumlar sirtlarda turibdi (**End** dan foydalaning).
4. Joylashtirilgan har bir aktorning Outliner’da mazmunli nomi bor (masalan, `Chair_Kitchen_01`).
5. Siz yaratgan yoki nusxalagan narsalar uchun Content Drawer’da oʻz papkangiz.
6. Daraja va barcha resurslar saqlangan.

### Qanday topshiriladi

**Uchta skrinshot** yuklang — ikkitasi muharrirdagi turli nuqtalardan, bittasi **Play** rejimidan — va nima yaratganingiz hamda qaysi vositalardan foydalanganingiz haqida ikki-uch gap yozing. Qisqa ekran yozuviga havola ham joylashingiz mumkin.

> [!NOTE]
> Tekshiruvchi ishingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Sahnangizni yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Your first scene'), 'uz',
    jsonb_build_object(
      'title', 'Birinchi sahnangiz',
      'brief_md', 'Starter Content’dan kichik, tartibli sahna yarating va qisqa tavsif bilan uchta skrinshot topshiring.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Loyiha shablondan yaratilgan, saqlangan va xatosiz ochiladi | 15 |
| Siljitish, aylantirish va masshtablash bilan kamida 10 ta Starter Content buyumi joylashtirilgan | 25 |
| Puxta joylashuv: toʻrga yopishish va sirtda turgan buyumlar | 20 |
| Outliner’da mazmunli aktor nomlari va oʻz Content papkasi | 20 |
| Qisqa tavsif bilan uchta skrinshot (ikki nuqtadan, bittasi Play rejimida) | 20 |$r$),
    c || ' / Your first scene');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Unreal Engine Fundamentals — final assessment', 'uz', 'Unreal Engine asoslari — yakuniy imtihon');
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 0, 'uz',
    'Qaysi shablon darajangizni darhol sinab koʻrishingiz uchun boshqariladigan personaj beradi?',
    'Third Person shablonida Play orqali boshqarish mumkin boʻlgan personaj bor.',
    array['Blank', 'Third Person', 'Film/Video & Live Events'],
    array['Blank boʻsh loyiha bilan boshlanadi, unda personaj yoʻq.', null, 'Bu toifa boshqariladigan personaj uchun emas, kino va virtual ishlab chiqarish uchun.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 1, 'uz',
    'Siz hali C++ ni oʻrganmagansiz. Qaysi loyiha turini tanlashingiz kerak?',
    'Blueprint loyihalari C++ talab qilmaydi; C++ ni keyinroq qoʻshish mumkin.',
    array['Blueprint', 'C++'],
    array[null, 'C++ loyihalari kompilyator va C++ bilimini talab qiladi; Blueprint’dan boshlang.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 2, 'uz',
    'Koʻrinish maydonida daraja boʻylab qanday uchiladi?',
    'Sichqonchaning oʻng tugmasini bosib turib, xuddi oʻyin kamerasidagi kabi W A S D dan foydalaning.',
    array['Sichqonchaning oʻng tugmasini bosib turib, W A S D dan foydalanish', 'Sichqonchaning oʻrta tugmasini bosib turib tortish', 'Faqat strelka tugmalarini bosish'],
    array[null, 'Blender shu tarzda aylantiradi; Unreal’da esa oʻng tugma bilan uchiladi.', 'Strelka tugmalarining oʻzi kamerani toʻliq boshqarish imkonini bermaydi.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 3, 'uz',
    'Qaysi tugma koʻrinish maydonini tanlangan aktorga qaratadi?',
    '**F** tanlangan aktorni ekranga sigʻdiradi.',
    array['F', 'G', 'Home'],
    array[null, 'G koʻrinish maydonida oʻyin koʻrinishini yoqadi yoki oʻchiradi.', 'Unreal’da Home tanlovni ekranga sigʻdirmaydi.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 4, 'uz',
    'Qaysi tugmalar gizmoni siljitish, aylantirish va masshtablash rejimlari orasida almashtiradi?',
    '**W** siljitadi, **E** aylantiradi, **R** masshtablaydi.',
    array['W, E, R', 'G, R, S', 'M, R, S'],
    array[null, 'G, R va S — Blender’ning tezkor tugmalari.', 'Bular Unreal’ning tezkor tugmalari emas.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 5, 'uz',
    'Unreal Engine’da qaysi oʻq yuqoriga qaragan?',
    'Unreal’da, xuddi Blenderdagi kabi, Z oʻqi yuqoriga qaragan.',
    array['X', 'Y', 'Z']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 6, 'uz',
    'Tekstura resursini qayta nomlamoqchisiz. Buni qayerda qilasiz?',
    'Resurslar orasidagi bogʻlanishlar buzilmasligi uchun ularni Content Drawer ichida qayta nomlang va koʻchiring.',
    array['Content Drawer’da', 'Windows Explorer yoki Finder’da', 'Farqi yoʻq — ikkalasida ham boʻladi'],
    array[null, 'Muharrirdan tashqarida qayta nomlash resurslar orasidagi bogʻlanishlarni buzadi.', 'Farqi bor: bogʻlanishlarni faqat muharrir yangilaydi.']);
  perform seed.tr_question(c, 'Unreal Engine Fundamentals — final assessment', 7, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: Unreal Engine’ni oʻrganish bepul, ammo tijoriy mahsulotlar Epic litsenziya shartlariga boʻysunadi.',
    'Toʻgʻri. Tijoriy mahsulot chiqarishdan oldin amaldagi EULA ni oʻqing.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array[null, 'Tijoriy relizlar Epic litsenziyasi bilan tartibga solinadi, unga royalti ham kirishi mumkin.']);
end $tr$;
