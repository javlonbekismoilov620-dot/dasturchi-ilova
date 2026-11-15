-- Sprint 1 · Blender: Your First Steps in 3D (English + Oʻzbekcha). Idempotent.
do $content$
declare
  c constant text := 'blender-first-steps-in-3d';
  q uuid;
begin
  perform seed.ensure_module(c, 'Your first render', 'Materials, a light and a camera.');
  perform seed.ensure_module(c, 'Final project and assessment', 'Build, light and render a scene of your own.');

  perform seed.ensure_lesson(c, 'Understanding 3D', 'Understanding 3D: check', 'quiz', 5,
    'Five questions on 3D space, meshes and Blender.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Understanding 3D: check', 'Understanding 3D check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'What does 3D add compared with a flat 2D drawing?',
    '3D adds depth: positions need X, Y and Z.',
    array['Depth', 'Colour', 'Movement'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'What is a single point of a mesh called?',
    'A vertex is a point; edges join vertices; faces fill the space between edges.',
    array['Vertex', 'Edge', 'Face'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'In which order does a typical 3D image get made?',
    'Model, give it materials, light it, place a camera, then render.',
    array['Modeling → materials → lighting → camera → rendering', 'Rendering → modeling → camera → lighting', 'Camera → rendering → modeling → materials'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'Which Blender render engine is physically accurate but slower?',
    'Cycles traces light physically; EEVEE is fast and real-time.',
    array['Cycles', 'EEVEE', 'Workbench'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'true_false', 'True or false: Blender is free to use, even for commercial work.',
    'True — Blender is free and open source, for personal and commercial use.',
    array['True', 'False'], array[true, false], null);

  perform seed.ensure_lesson(c, 'Moving around and basic objects', 'Object mode, Edit mode and the origin', 'article', 10,
    'Switch between moving whole objects and editing their shape, and keep scale and origins tidy.',
$md$## Two ways of working

So far you have moved, rotated and scaled whole objects. To change an object's **shape** you need another mode. In this lesson you will switch between Object Mode and Edit Mode, edit vertices, edges and faces, and keep objects' scale and origin tidy.

| Mode | What you change | Example |
| --- | --- | --- |
| **Object Mode** | Whole objects | Moving a chair across the room |
| **Edit Mode** | The vertices, edges and faces inside one object | Making the chair's legs longer |

Press **Tab** with an object selected to switch between the two modes. The mode is also shown in the menu at the top left of the 3D Viewport.

## Selecting in Edit Mode

- Press **1**, **2** or **3** on the main keyboard to select **vertices**, **edges** or **faces**.
- Click to select; **Shift + click** adds to the selection.
- **A** selects everything; **Alt + A** deselects everything.

The tools you already know — **G**, **R**, **S** and the axis keys — work on the selected vertices, edges or faces too.

## Two first modeling tools

- **E** (Extrude) pulls new geometry out of the selection. Select the top face of a cube, press **E**, then **Z**, and move the mouse: the cube grows a new section upward.
- **Ctrl + R** (Loop Cut) adds a ring of edges around the object, giving you more geometry to shape.

## The origin

Every object has an **origin** — the small orange dot. It is the point the object rotates and scales around, and the point its position is measured from. After editing, the origin can end up far from the geometry.

To fix it, in Object Mode choose **Object → Set Origin → Origin to Geometry**.

## Apply the scale

When you scale an object in Object Mode, Blender remembers the scale factor (for example 2.5) instead of changing the mesh itself. Many tools, such as bevels and modifiers, then behave unevenly.

> [!WARNING]
> Before beveling or adding modifiers, apply the scale: in Object Mode press **Ctrl + A → Scale**. The object looks the same, but its scale returns to 1.

## Try it

1. Add a cube, press **Tab** and select the top face with **3**.
2. Extrude it upward twice with **E** and **Z**, scaling the top section smaller each time with **S**, to make a simple tower.
3. Return to Object Mode, set the origin to the geometry and apply the scale.

## Common mistakes

- Trying to edit the shape while still in Object Mode.
- Forgetting which selection mode (vertex, edge, face) is active.
- Leaving unapplied scale, which makes bevels and modifiers uneven.

## Key terms

- **Object Mode** — the mode for working with whole objects.
- **Edit Mode** — the mode for editing an object's vertices, edges and faces.
- **Extrude** — pulling new geometry out of a selection.
- **Origin** — the reference point an object moves, rotates and scales around.$md$);

  perform seed.ensure_lesson(c, 'Your first render', 'Giving objects a material', 'article', 10,
    'Base colour, roughness and metallic: describe what a surface is made of.',
$md$## What is a material?

A **material** describes what a surface is made of — painted wood, shiny metal, rough clay — by telling the render engine how light bounces off it. In this lesson you will create materials with Blender's main shader and preview them in the viewport.

## Seeing materials in the viewport

The viewport normally shows plain grey **Solid** shading. To see materials, switch to **Material Preview**: press **Z** in the viewport and choose it from the pie menu, or click the third of the round shading buttons at the top right of the viewport.

## Creating a material

1. Select an object.
2. In the **Properties Editor**, open the **Material** tab (the red sphere icon).
3. Click **New**. Blender creates a material using the **Principled BSDF** shader.

Rename the material straight away (for example `Clay_Red`) so you can find it later.

## The three settings that matter most

| Setting | What it controls | Try |
| --- | --- | --- |
| **Base Color** | The colour of the surface | Any colour you like |
| **Metallic** | Whether the surface behaves like metal | 0 for plastic, wood or skin; 1 for metal |
| **Roughness** | How blurred reflections are | 0.1 for polished, 0.8 for matte |

Real materials are usually either fully metallic or not metallic at all, so keep **Metallic** at 0 or 1 most of the time and use **Roughness** to vary the look.

> [!TIP]
> Make small test materials before your main scene: a red plastic ball (Metallic 0, Roughness 0.4), a gold coin (Metallic 1, Roughness 0.2) and a clay pot (Metallic 0, Roughness 0.9). Seeing them side by side teaches the settings faster than reading.

## Glowing surfaces

**Emission** makes a surface give off light, like a screen or a lamp. In the Principled BSDF, set an **Emission Color** and raise the **Emission Strength** above 0.

## Several materials on one object

One object can have several materials, such as a mug with a white outside and a dark inside:

1. Add a second **material slot** with the **+** button in the Material tab and give it a new material.
2. In Edit Mode, select the faces that should use it.
3. Click **Assign**.

## Try it

Give the snowman from the earlier lesson materials: white matte snow, a shiny black material for the eyes and an orange material for the nose.

## Common mistakes

- Looking for materials in Solid shading, where they are not shown.
- Setting Metallic to 0.5 for everyday objects, which looks unrealistic.
- Leaving materials with default names such as `Material.003`.

## Key terms

- **Material** — the description of a surface used by the render engine.
- **Principled BSDF** — Blender's main all-purpose shader.
- **Roughness** — how sharp or blurred reflections are.
- **Material Preview** — a viewport shading mode that shows materials.$md$);

  perform seed.ensure_lesson(c, 'Your first render', 'Lighting and rendering your first image', 'article', 12,
    'Lights, the camera, EEVEE versus Cycles and saving a PNG image.',
$md$## From scene to picture

**Rendering** turns your scene into a finished image as seen through the camera. In this lesson you will light a scene, frame it with the camera, choose a render engine and save the image.

## Adding lights

Press **Shift + A → Light** and choose a type:

| Light | Behaves like | Good for |
| --- | --- | --- |
| **Point** | A bare bulb shining in all directions | Small lamps, candles |
| **Sun** | Distant sunlight with parallel rays | Outdoor scenes |
| **Spot** | A cone of light | Stage lights, torches |
| **Area** | A glowing panel | Soft studio light |

Select a light and adjust its **Power** (in watts) and colour in the Properties Editor's light tab. A classic setup is **three-point lighting**: a strong **key light** at one side, a weaker **fill light** on the other side and a **rim light** behind the subject to outline it.

## Framing with the camera

- Press **Numpad 0** (or use the camera icon in the navigation gizmo) to look through the camera.
- To move the camera to your current view, press **Ctrl + Alt + Numpad 0**.
- Fine-tune with **G** and **R** while looking through the camera, or adjust its position in the sidebar (**N**).

## Choosing a render engine

Open the **Render Properties** tab (the back of a camera icon):

- **EEVEE** — real-time and fast. Great for previews, stylised images and animation on modest computers.
- **Cycles** — traces light physically. Realistic shadows and reflections, but slower. If you have a supported GPU, choose it under **Preferences → System**.

In Cycles, the **Samples** value controls quality: more samples mean less grain but longer renders. Keep **Denoise** on to remove most of the remaining grain.

## Rendering and saving

1. Press **F12** to render. A new window shows the image as it is calculated.
2. In that window, choose **Image → Save As** (**Shift + Alt + S**).
3. Choose **PNG** as the format and save.

> [!WARNING]
> A render is not saved automatically. Closing the render window without saving loses the image (but not your scene).

## Saving your scene

Save the `.blend` file with **Ctrl + S**, and save often. If Blender closes unexpectedly, **File → Recover → Auto Save** can bring back a recent automatic copy.

## Try it

Light your snowman with three-point lighting, frame it with the camera, render it once in EEVEE and once in Cycles, and save both images as PNG files. Compare the shadows and render times.

## Common mistakes

- Rendering without a camera in the scene, or with the camera pointing away from the subject.
- Lights so weak that the render looks black, or so strong that everything is white.
- Closing the render window without saving the image.

## Key terms

- **Rendering** — calculating the final image from the scene.
- **Key, fill and rim light** — the three lights of a classic studio setup.
- **EEVEE / Cycles** — Blender's real-time and physically accurate render engines.
- **Samples** — the number of light calculations per pixel in Cycles.$md$);

  perform seed.ensure_lesson(c, 'Your first render', 'First render: check', 'quiz', 5,
    'Five questions on materials, lights and rendering.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'First render: check', 'First render check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'Your material changes do not show in the viewport. What is the most likely reason?',
    'Solid shading does not show materials; switch to Material Preview.',
    array['The viewport is in Solid shading, not Material Preview', 'The material is too dark', 'The camera is off'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which setting makes a surface look polished instead of matte?',
    'Low Roughness gives sharp reflections; high Roughness looks matte.',
    array['A low Roughness value', 'A high Roughness value', 'A Metallic value of 0.5'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'Which shortcut renders the image?',
    '**F12** renders the current frame through the active camera.',
    array['F12', 'Ctrl + S', 'Tab'], array[true, false, false],
    array[null, 'Ctrl + S saves the .blend file.', 'Tab switches between Object and Edit Mode.']);
  perform seed.ensure_question(q, 3, 'single_choice', 'How do you move the camera to match your current view?',
    '**Ctrl + Alt + Numpad 0** aligns the active camera to the view.',
    array['Ctrl + Alt + Numpad 0', 'Numpad 0', 'Shift + A'], array[true, false, false],
    array[null, 'Numpad 0 looks through the camera without moving it.', 'Shift + A opens the Add menu.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'In three-point lighting, which light outlines the subject from behind?',
    'The rim light separates the subject from the background.',
    array['Rim light', 'Key light', 'Fill light'], array[true, false, false], null);

  perform seed.ensure_lesson(c, 'Final project and assessment', 'Project: a still-life scene', 'project', 60,
    'Model, texture, light and render a still-life scene from simple shapes.',
$md$## Your project

Create a **still-life scene** — a table with a few everyday objects, such as a cup, a bowl of fruit and a book — using only the tools from this course. Light it, frame it and render a finished image.

### Requirements

1. At least **five objects** built from primitives and edited in Edit Mode (extrude, loop cut, scale).
2. Tidy objects: sensible origins, applied scale and meaningful names in the Outliner.
3. At least **four materials** with different Base Color, Metallic and Roughness values, including one metal and one matte material.
4. **Three-point lighting** (or a clearly described alternative) and a camera that frames the scene well.
5. A final render in **Cycles or EEVEE**, saved as PNG at 1920 × 1080.
6. A short note (three or four sentences) on your lighting and material choices.

### How to submit

Upload the PNG render and, if you like, the `.blend` file. Paste your note in the text box.

> [!NOTE]
> A reviewer checks your render against the rubric and leaves feedback. You can improve the scene and resubmit.$md$, 'published', false, 60);
  perform seed.ensure_assignment(c, 'Project: a still-life scene', 'Still-life scene',
    'Model, texture, light and render a still-life scene of five or more objects, with a short note on your choices.',
$r$| Criterion | Points |
| --- | --- |
| Five or more objects shaped in Edit Mode | 20 |
| Tidy scene: origins, applied scale, clear names | 15 |
| Four or more convincing materials (including metal and matte) | 20 |
| Lighting and camera framing | 25 |
| Final PNG render at 1920 × 1080 with a note on choices | 20 |$r$);

  perform seed.ensure_lesson(c, 'Final project and assessment', 'Final assessment', 'quiz', 8,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'Blender: Your First Steps in 3D — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which axis points up in Blender?',
    'Blender is Z-up.',
    array['Z', 'Y', 'X'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'How many edges does a cube have?',
    'A cube has 8 vertices, 12 edges and 6 faces.',
    array['12', '8', '6'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'Which key switches between Object Mode and Edit Mode?',
    '**Tab** toggles the two modes.',
    array['Tab', 'G', 'N'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'What should you do before beveling an object you scaled in Object Mode?',
    'Apply the scale with Ctrl + A → Scale so tools work evenly.',
    array['Apply the scale (Ctrl + A → Scale)', 'Delete the object and start again', 'Switch to Cycles'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'single_choice', 'You type **R X 90**. What happens?',
    'R rotates, X limits it to the X axis, 90 is the angle in degrees.',
    array['The object rotates 90° around the X axis', 'The object moves 90 metres along X', 'The object scales to 90%'], array[true, false, false], null);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which material settings suit a gold coin?',
    'Metal: Metallic 1, with a low Roughness for a polished look.',
    array['Metallic 1, low Roughness', 'Metallic 0, high Roughness', 'Metallic 0.5, Roughness 0.5'], array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'single_choice', 'Which render engine is real-time and fast?',
    'EEVEE renders in real time; Cycles is physically accurate but slower.',
    array['EEVEE', 'Cycles'], array[true, false], null);
  perform seed.ensure_question(q, 7, 'true_false', 'True or false: a render is saved automatically when it finishes.',
    'False — save it with Image → Save As before closing the render window.',
    array['True', 'False'], array[false, true], null);

  perform seed.order_modules(c, array['Understanding 3D', 'Moving around and basic objects', 'Your first render', 'Final project and assessment']);
  perform seed.order_lessons(c, 'Understanding 3D', array['What is 3D?', 'What is Blender?', 'Installing Blender and the interface', 'Understanding 3D: check']);
  perform seed.order_lessons(c, 'Moving around and basic objects', array['Navigating the 3D viewport', 'Basic objects: add, move, rotate, scale', 'Object mode, Edit mode and the origin', 'Module quiz']);
  perform seed.order_lessons(c, 'Your first render', array['Giving objects a material', 'Lighting and rendering your first image', 'First render: check']);
  perform seed.order_lessons(c, 'Final project and assessment', array['Project: a still-life scene', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'blender-first-steps-in-3d';
begin
  perform seed.tr_module(c, 'Final project and assessment', 'uz', 'Yakuniy loyiha va imtihon',
    'Oʻz sahnangizni yarating, yoriting va render qiling.');

  perform seed.tr_lesson(c, 'Understanding 3D: check', 'uz', '3D ni tushunish: bilimni tekshirish',
    '3D fazo, meshlar va Blender boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Understanding 3D check', 'uz', '“3D ni tushunish” moduli boʻyicha test');
  perform seed.tr_question(c, 'Understanding 3D check', 0, 'uz', 'Tekis 2D rasmga nisbatan 3D nimani qoʻshadi?',
    '3D chuqurlikni qoʻshadi: joylashuv uchun X, Y va Z kerak.',
    array['Chuqurlik', 'Rang', 'Harakat']);
  perform seed.tr_question(c, 'Understanding 3D check', 1, 'uz', 'Meshning bitta nuqtasi nima deb ataladi?',
    'Uch — nuqta; qirralar uchlarni tutashtiradi; yoqlar qirralar orasidagi joyni toʻldiradi.',
    array['Uch (vertex)', 'Qirra (edge)', 'Yoq (face)']);
  perform seed.tr_question(c, 'Understanding 3D check', 2, 'uz', 'Odatiy 3D tasvir qanday tartibda yaratiladi?',
    'Modellashtirish, material berish, yoritish, kamera joylashtirish, soʻngra render qilish.',
    array['Modellashtirish → materiallar → yoritish → kamera → rendering', 'Rendering → modellashtirish → kamera → yoritish', 'Kamera → rendering → modellashtirish → materiallar']);
  perform seed.tr_question(c, 'Understanding 3D check', 3, 'uz', 'Blenderning qaysi render dvigateli fizik jihatdan aniq, ammo sekinroq?',
    'Cycles yorugʻlikni fizik qonunlarga koʻra hisoblaydi; EEVEE esa tez va real vaqtda ishlaydi.',
    array['Cycles', 'EEVEE', 'Workbench']);
  perform seed.tr_question(c, 'Understanding 3D check', 4, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: Blenderdan, hatto tijoriy ishlar uchun ham, bepul foydalanish mumkin.',
    'Toʻgʻri — Blender bepul va ochiq kodli, shaxsiy va tijoriy foydalanish uchun.',
    array['Toʻgʻri', 'Notoʻgʻri']);

  perform seed.tr_lesson(c, 'Object mode, Edit mode and the origin', 'uz', 'Object Mode, Edit Mode va origin nuqtasi',
    'Butun obyektlarni siljitish va ularning shaklini tahrirlash oʻrtasida almashing hamda masshtab va origin nuqtalarini tartibli saqlang.',
$md$## Ishlashning ikki usuli

Hozirgacha butun obyektlarni siljitdingiz, aylantirdingiz va masshtabladingiz. Obyektning **shaklini** oʻzgartirish uchun boshqa rejim kerak. Bu darsda Object Mode va Edit Mode orasida almashasiz, uchlar, qirralar va yoqlarni tahrirlaysiz hamda obyektlarning masshtabi va origin nuqtasini tartibli saqlaysiz.

| Rejim | Nimani oʻzgartirasiz | Misol |
| --- | --- | --- |
| **Object Mode** (obyekt rejimi) | Butun obyektlarni | Stulni xona boʻylab siljitish |
| **Edit Mode** (tahrirlash rejimi) | Bitta obyekt ichidagi uchlar, qirralar va yoqlarni | Stul oyoqlarini uzunroq qilish |

Ikki rejim orasida almashish uchun obyekt tanlangan holda **Tab** ni bosing. Joriy rejim 3D Viewport’ning yuqori chap qismidagi menyuda ham koʻrsatiladi.

## Edit Mode’da tanlash

- **Uchlar**, **qirralar** yoki **yoqlarni** tanlash uchun asosiy klaviaturadagi **1**, **2** yoki **3** ni bosing.
- Tanlash uchun bosing; **Shift + bosish** tanlovga qoʻshadi.
- **A** hammasini tanlaydi; **Alt + A** tanlovni bekor qiladi.

Siz allaqachon biladigan vositalar — **G**, **R**, **S** va oʻq tugmalari — tanlangan uchlar, qirralar yoki yoqlar bilan ham ishlaydi.

## Dastlabki ikki modellashtirish vositasi

- **E** (Extrude — chiqarish) tanlovdan yangi geometriyani tortib chiqaradi. Kubning yuqori yogʻini tanlang, **E** ni, soʻngra **Z** ni bosing va sichqonchani harakatlantiring: kub yuqoriga qarab yangi qism bilan oʻsadi.
- **Ctrl + R** (Loop Cut — halqa kesim) obyekt atrofiga qirralar halqasini qoʻshadi va shakl berish uchun koʻproq geometriya beradi.

## Origin nuqtasi

Har bir obyektning **origin** nuqtasi bor — kichik toʻq sariq nuqta. Obyekt shu nuqta atrofida aylanadi va masshtablanadi, uning joylashuvi ham shu nuqtadan oʻlchanadi. Tahrirlashdan keyin origin nuqtasi geometriyadan ancha uzoqda qolib ketishi mumkin.

Buni tuzatish uchun Object Mode’da **Object → Set Origin → Origin to Geometry** ni tanlang.

## Masshtabni qoʻllang

Object Mode’da obyektni masshtablaganingizda Blender meshning oʻzini oʻzgartirish oʻrniga masshtab koeffitsiyentini (masalan, 2.5) eslab qoladi. Shundan soʻng bevel va modifikatorlar kabi koʻplab vositalar notekis ishlaydi.

> [!WARNING]
> Bevel yoki modifikator qoʻshishdan oldin masshtabni qoʻllang: Object Mode’da **Ctrl + A → Scale** ni bosing. Obyekt avvalgidek koʻrinadi, ammo uning masshtabi 1 ga qaytadi.

## Oʻzingiz sinab koʻring

1. Kub qoʻshing, **Tab** ni bosing va **3** bilan yuqori yoqni tanlang.
2. Oddiy minora yasash uchun uni **E** va **Z** bilan ikki marta yuqoriga chiqaring va har safar yuqori qismni **S** bilan kichraytiring.
3. Object Mode’ga qayting, origin nuqtasini geometriyaga oʻrnating va masshtabni qoʻllang.

## Keng tarqalgan xatolar

- Object Mode’da turib shaklni tahrirlashga urinish.
- Qaysi tanlash rejimi (uch, qirra, yoq) faol ekanini unutish.
- Masshtabni qoʻllamay qoldirish — bevel va modifikatorlar notekis boʻladi.

## Asosiy atamalar

- **Object Mode** — butun obyektlar bilan ishlash rejimi.
- **Edit Mode** — obyektning uchlari, qirralari va yoqlarini tahrirlash rejimi.
- **Extrude** (chiqarish) — tanlovdan yangi geometriyani tortib chiqarish.
- **Origin** — obyekt siljiydigan, aylanadigan va masshtablanadigan tayanch nuqta.$md$);

  perform seed.tr_lesson(c, 'Giving objects a material', 'uz', 'Obyektlarga material berish',
    'Asosiy rang, gʻadir-budurlik va metallik: sirt nimadan yasalganini tavsiflang.',
$md$## Material nima?

**Material** sirt nimadan yasalganini — boʻyalgan yogʻoch, yaltiroq metall, gʻadir-budur loy — render dvigateliga yorugʻlik undan qanday qaytishini aytish orqali tavsiflaydi. Bu darsda Blenderning asosiy sheyderi bilan materiallar yaratasiz va ularni koʻrinish maydonida koʻrib chiqasiz.

## Materiallarni koʻrinish maydonida koʻrish

Koʻrinish maydoni odatda oddiy kulrang **Solid** (bir rangli) rejimda boʻladi. Materiallarni koʻrish uchun **Material Preview** rejimiga oʻting: koʻrinish maydonida **Z** ni bosib, uni doiraviy menyudan tanlang yoki koʻrinish maydonining oʻng yuqori qismidagi dumaloq rejim tugmalarining uchinchisini bosing.

## Material yaratish

1. Obyektni tanlang.
2. **Properties Editor** da **Material** yorligʻini (qizil shar belgisi) oching.
3. **New** ni bosing. Blender **Principled BSDF** sheyderidan foydalanadigan material yaratadi.

Keyinroq topish oson boʻlishi uchun materialni darhol qayta nomlang (masalan, `Clay_Red`).

## Eng muhim uchta sozlama

| Sozlama | Nimani boshqaradi | Sinab koʻring |
| --- | --- | --- |
| **Base Color** (asosiy rang) | Sirtning rangi | Oʻzingiz yoqtirgan istalgan rang |
| **Metallic** (metallik) | Sirt metalldek oʻzini tutishi | Plastmassa, yogʻoch yoki teri uchun 0; metall uchun 1 |
| **Roughness** (gʻadir-budurlik) | Aksning qanchalik xira ekani | Sayqallangan uchun 0.1, xira uchun 0.8 |

Haqiqiy materiallar odatda yo butunlay metall, yo umuman metall emas, shuning uchun koʻp hollarda **Metallic** ni 0 yoki 1 da saqlang, koʻrinishni esa **Roughness** bilan oʻzgartiring.

> [!TIP]
> Asosiy sahnadan oldin kichik sinov materiallarini yarating: qizil plastmassa shar (Metallic 0, Roughness 0.4), oltin tanga (Metallic 1, Roughness 0.2) va loy koʻza (Metallic 0, Roughness 0.9). Ularni yonma-yon koʻrish sozlamalarni oʻqishdan koʻra tezroq oʻrgatadi.

## Yorugʻlik taratuvchi sirtlar

**Emission** (nurlanish) sirtni ekran yoki chiroq kabi yorugʻlik taratadigan qiladi. Principled BSDF da **Emission Color** ni belgilang va **Emission Strength** ni 0 dan yuqori qiling.

## Bitta obyektda bir nechta material

Bitta obyektda bir nechta material boʻlishi mumkin, masalan, tashqarisi oq, ichi toʻq rangli krujka:

1. Material yorligʻidagi **+** tugmasi bilan ikkinchi **material slotini** qoʻshing va unga yangi material bering.
2. Edit Mode’da shu materialdan foydalanishi kerak boʻlgan yoqlarni tanlang.
3. **Assign** ni bosing.

## Oʻzingiz sinab koʻring

Oldingi darsdagi qorboboga materiallar bering: oq xira qor, koʻzlar uchun yaltiroq qora material va burun uchun toʻq sariq material.

## Keng tarqalgan xatolar

- Materiallar koʻrsatilmaydigan Solid rejimida ularni qidirish.
- Kundalik buyumlar uchun Metallic ni 0.5 qilib qoʻyish — natija gʻayritabiiy koʻrinadi.
- Materiallarni `Material.003` kabi standart nomlar bilan qoldirish.

## Asosiy atamalar

- **Material** — render dvigateli foydalanadigan sirt tavsifi.
- **Principled BSDF** — Blenderning asosiy universal sheyderi.
- **Roughness** (gʻadir-budurlik) — akslar qanchalik aniq yoki xira ekani.
- **Material Preview** — materiallarni koʻrsatadigan koʻrinish rejimi.$md$);

  perform seed.tr_lesson(c, 'Lighting and rendering your first image', 'uz', 'Yoritish va birinchi tasviringizni render qilish',
    'Yorugʻlik manbalari, kamera, EEVEE va Cycles farqi hamda PNG tasvirni saqlash.',
$md$## Sahnadan tasvirga

**Rendering** sahnangizni kamera orqali koʻrinadigan tayyor tasvirga aylantiradi. Bu darsda sahnani yoritasiz, uni kamera bilan kadrga olasiz, render dvigatelini tanlaysiz va tasvirni saqlaysiz.

## Yorugʻlik manbalarini qoʻshish

**Shift + A → Light** ni bosing va turini tanlang:

| Yorugʻlik | Nimaga oʻxshaydi | Nima uchun qulay |
| --- | --- | --- |
| **Point** (nuqtali) | Har tomonga nur sochadigan ochiq lampochka | Kichik chiroqlar, shamlar |
| **Sun** (quyosh) | Nurlari parallel boʻlgan uzoqdagi quyosh | Ochiq havodagi sahnalar |
| **Spot** (projektor) | Konussimon yorugʻlik | Sahna chiroqlari, fonarlar |
| **Area** (maydonli) | Nur taratuvchi panel | Yumshoq studiya yorugʻligi |

Yorugʻlik manbaini tanlab, Properties Editor’ning yorugʻlik yorligʻida uning **Power** (quvvat, vattlarda) va rangini sozlang. Klassik usul — **uch nuqtali yoritish**: bir tomonda kuchli **asosiy yorugʻlik** (*key light*), boshqa tomonda kuchsizroq **toʻldiruvchi yorugʻlik** (*fill light*) va obyektni chiziq bilan ajratib koʻrsatish uchun uning ortida **kontur yorugʻligi** (*rim light*).

## Kamera bilan kadrga olish

- Kamera orqali qarash uchun **Numpad 0** ni bosing (yoki navigatsiya gizmosidagi kamera belgisidan foydalaning).
- Kamerani joriy koʻrinishingizga koʻchirish uchun **Ctrl + Alt + Numpad 0** ni bosing.
- Kamera orqali qarab turib **G** va **R** bilan aniq sozlang yoki uning joylashuvini yon panelda (**N**) oʻzgartiring.

## Render dvigatelini tanlash

**Render Properties** yorligʻini (kamera orqa tomoni belgisi) oching:

- **EEVEE** — real vaqtda ishlaydigan va tez. Oldindan koʻrish, stilizatsiya qilingan tasvirlar va oddiy kompyuterlarda animatsiya uchun juda yaxshi.
- **Cycles** — yorugʻlikni fizik qonunlarga koʻra hisoblaydi. Soyalar va akslar realistik, lekin sekinroq. Qoʻllab-quvvatlanadigan videokartangiz boʻlsa, uni **Preferences → System** boʻlimida tanlang.

Cycles’da **Samples** (namunalar) qiymati sifatni boshqaradi: namunalar qancha koʻp boʻlsa, donadorlik shuncha kam, render esa shuncha uzoq boʻladi. Qolgan donadorlikning katta qismini yoʻqotish uchun **Denoise** ni yoqilgan holda qoldiring.

## Render qilish va saqlash

1. Render qilish uchun **F12** ni bosing. Yangi oynada tasvir hisoblanayotgani koʻrinadi.
2. Oʻsha oynada **Image → Save As** (**Shift + Alt + S**) ni tanlang.
3. Format sifatida **PNG** ni tanlab, saqlang.

> [!WARNING]
> Render avtomatik saqlanmaydi. Render oynasini saqlamasdan yopsangiz, tasvir yoʻqoladi (sahnangiz esa saqlanib qoladi).

## Sahnangizni saqlash

`.blend` faylini **Ctrl + S** bilan saqlang va tez-tez saqlab turing. Agar Blender kutilmaganda yopilsa, **File → Recover → Auto Save** yaqinda avtomatik saqlangan nusxani qaytarishi mumkin.

## Oʻzingiz sinab koʻring

Qorbobongizni uch nuqtali yoritish bilan yoriting, kamera bilan kadrga oling, bir marta EEVEE’da va bir marta Cycles’da render qiling hamda ikkala tasvirni PNG fayl sifatida saqlang. Soyalar va render vaqtini solishtiring.

## Keng tarqalgan xatolar

- Sahnada kamera boʻlmasa yoki kamera obyektga qaramasa ham render qilish.
- Yorugʻlik juda kuchsiz boʻlib, render qop-qora chiqishi yoki juda kuchli boʻlib, hamma narsa oppoq chiqishi.
- Tasvirni saqlamasdan render oynasini yopish.

## Asosiy atamalar

- **Rendering** — sahnadan yakuniy tasvirni hisoblash.
- **Asosiy, toʻldiruvchi va kontur yorugʻligi** — klassik studiya yoritishining uchta manbai.
- **EEVEE / Cycles** — Blenderning real vaqtdagi va fizik jihatdan aniq render dvigatellari.
- **Samples** (namunalar) — Cycles’da har bir piksel uchun yorugʻlik hisob-kitoblari soni.$md$);

  perform seed.tr_lesson(c, 'First render: check', 'uz', 'Birinchi render: bilimni tekshirish',
    'Materiallar, yorugʻlik va render boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'First render check', 'uz', '“Birinchi renderingiz” moduli boʻyicha test');
  perform seed.tr_question(c, 'First render check', 0, 'uz', 'Material oʻzgarishlaringiz koʻrinish maydonida koʻrinmayapti. Eng ehtimoliy sababi nima?',
    'Solid rejimi materiallarni koʻrsatmaydi; Material Preview ga oʻting.',
    array['Koʻrinish maydoni Material Preview emas, Solid rejimida', 'Material juda toʻq', 'Kamera oʻchirilgan']);
  perform seed.tr_question(c, 'First render check', 1, 'uz', 'Qaysi sozlama sirtni xira emas, sayqallangan koʻrsatadi?',
    'Past Roughness aniq akslar beradi; yuqori Roughness xira koʻrinadi.',
    array['Past Roughness qiymati', 'Yuqori Roughness qiymati', 'Metallic qiymati 0.5']);
  perform seed.tr_question(c, 'First render check', 2, 'uz', 'Qaysi tezkor tugma tasvirni render qiladi?',
    '**F12** joriy kadrni faol kamera orqali render qiladi.',
    array['F12', 'Ctrl + S', 'Tab'],
    array[null, 'Ctrl + S .blend faylini saqlaydi.', 'Tab Object va Edit Mode orasida almashtiradi.']);
  perform seed.tr_question(c, 'First render check', 3, 'uz', 'Kamerani joriy koʻrinishingizga qanday moslashtirasiz?',
    '**Ctrl + Alt + Numpad 0** faol kamerani koʻrinishga moslaydi.',
    array['Ctrl + Alt + Numpad 0', 'Numpad 0', 'Shift + A'],
    array[null, 'Numpad 0 kamerani siljitmasdan u orqali qaraydi.', 'Shift + A Add menyusini ochadi.']);
  perform seed.tr_question(c, 'First render check', 4, 'uz', 'Uch nuqtali yoritishda qaysi yorugʻlik obyektni orqadan chiziq bilan ajratib koʻrsatadi?',
    'Kontur yorugʻligi obyektni fondan ajratadi.',
    array['Kontur yorugʻligi', 'Asosiy yorugʻlik', 'Toʻldiruvchi yorugʻlik']);

  perform seed.tr_lesson(c, 'Project: a still-life scene', 'uz', 'Loyiha: natyurmort sahnasi',
    'Oddiy shakllardan natyurmort sahnasini modellashtiring, material bering, yoriting va render qiling.',
$md$## Loyihangiz

Faqat ushbu kursdagi vositalardan foydalanib, **natyurmort sahnasi**ni — ustida bir nechta kundalik buyum, masalan, piyola, bir idish meva va kitob turgan stolni yarating. Uni yoriting, kadrga oling va tayyor tasvirni render qiling.

### Talablar

1. Primitivlardan qurilgan va Edit Mode’da tahrirlangan (extrude, loop cut, masshtab) kamida **beshta obyekt**.
2. Tartibli obyektlar: oqilona origin nuqtalari, qoʻllangan masshtab va Outliner’da mazmunli nomlar.
3. Base Color, Metallic va Roughness qiymatlari har xil boʻlgan, jumladan, bitta metall va bitta xira material bilan kamida **toʻrtta material**.
4. **Uch nuqtali yoritish** (yoki aniq tasvirlangan muqobil usul) va sahnani yaxshi kadrga oladigan kamera.
5. **Cycles yoki EEVEE** da yakuniy render, 1920 × 1080 oʻlchamdagi PNG sifatida saqlangan.
6. Yoritish va material tanlovlaringiz haqida qisqa izoh (uch-toʻrt gap).

### Qanday topshiriladi

PNG renderni va, xohlasangiz, `.blend` faylini yuklang. Izohingizni matn maydoniga joylang.

> [!NOTE]
> Tekshiruvchi renderingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Sahnani yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Still-life scene'), 'uz',
    jsonb_build_object(
      'title', 'Natyurmort sahnasi',
      'brief_md', 'Besh va undan ortiq obyektdan iborat natyurmort sahnasini modellashtiring, material bering, yoriting va render qiling hamda tanlovlaringiz haqida qisqa izoh yozing.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Edit Mode’da shakl berilgan besh va undan ortiq obyekt | 20 |
| Tartibli sahna: origin nuqtalari, qoʻllangan masshtab, aniq nomlar | 15 |
| Toʻrt va undan ortiq ishonarli material (metall va xira material bilan) | 20 |
| Yoritish va kamera bilan kadrga olish | 25 |
| 1920 × 1080 oʻlchamdagi yakuniy PNG render va tanlovlar haqida izoh | 20 |$r$),
    c || ' / Still-life scene');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Blender: Your First Steps in 3D — final assessment', 'uz', 'Blender: 3D olamidagi ilk qadamlar — yakuniy imtihon');
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 0, 'uz', 'Blenderda qaysi oʻq yuqoriga qaragan?',
    'Blenderda Z oʻqi yuqoriga qaragan.',
    array['Z', 'Y', 'X']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 1, 'uz', 'Kubning nechta qirrasi bor?',
    'Kubning 8 ta uchi, 12 ta qirrasi va 6 ta yogʻi bor.',
    array['12', '8', '6']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 2, 'uz', 'Qaysi tugma Object Mode va Edit Mode orasida almashtiradi?',
    '**Tab** ikki rejim orasida almashtiradi.',
    array['Tab', 'G', 'N']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 3, 'uz', 'Object Mode’da masshtablagan obyektga bevel berishdan oldin nima qilish kerak?',
    'Vositalar tekis ishlashi uchun masshtabni Ctrl + A → Scale bilan qoʻllang.',
    array['Masshtabni qoʻllash (Ctrl + A → Scale)', 'Obyektni oʻchirib, qaytadan boshlash', 'Cycles’ga oʻtish']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 4, 'uz', 'Siz **R X 90** deb yozasiz. Nima sodir boʻladi?',
    'R aylantiradi, X uni X oʻqi bilan cheklaydi, 90 — gradusdagi burchak.',
    array['Obyekt X oʻqi atrofida 90° ga aylanadi', 'Obyekt X boʻylab 90 metr siljiydi', 'Obyekt 90% gacha masshtablanadi']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 5, 'uz', 'Oltin tanga uchun qaysi material sozlamalari mos keladi?',
    'Metall: Metallic 1, sayqallangan koʻrinish uchun past Roughness.',
    array['Metallic 1, past Roughness', 'Metallic 0, yuqori Roughness', 'Metallic 0.5, Roughness 0.5']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 6, 'uz', 'Qaysi render dvigateli real vaqtda ishlaydi va tez?',
    'EEVEE real vaqtda render qiladi; Cycles fizik jihatdan aniq, ammo sekinroq.',
    array['EEVEE', 'Cycles']);
  perform seed.tr_question(c, 'Blender: Your First Steps in 3D — final assessment', 7, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: render tugagach, u avtomatik saqlanadi.',
    'Notoʻgʻri — render oynasini yopishdan oldin uni Image → Save As bilan saqlang.',
    array['Toʻgʻri', 'Notoʻgʻri']);
end $tr$;
