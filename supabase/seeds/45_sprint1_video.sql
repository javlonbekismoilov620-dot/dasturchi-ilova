-- Sprint 1 · Video Editing Fundamentals (English + Oʻzbekcha). Idempotent.
do $content$
declare
  c constant text := 'video-editing-fundamentals';
  q uuid;
begin
  perform seed.ensure_module(c, 'Pictures and sound', 'The shots you cut with and the sound that holds them together.');
  perform seed.ensure_module(c, 'Your first edit', 'Edit, finish and export a short film from your own footage.');

  perform seed.ensure_lesson(c, 'Pictures and sound', 'Shots, composition and continuity', 'article', 11,
    'Shot sizes, framing and the continuity rules that make cuts feel natural.',
$md$## The vocabulary of pictures

Editors choose between shots all day, so they need words for them. In this lesson you will learn to name shots, judge their framing and keep the action continuous across cuts.

| Shot size | What it shows | Typical use |
| --- | --- | --- |
| **Extreme wide** | A whole landscape or city | Establishing where we are |
| **Wide** | A person from head to toe in their surroundings | Showing action and place |
| **Medium** | A person from the waist up | Conversations, presenting |
| **Close-up** | A face or an important object | Emotion and detail |
| **Extreme close-up** | Eyes, hands, a tiny detail | Tension and emphasis |
| **Insert** | A detail of the action, such as a hand pressing a button | Clarifying what happens |

A classic sequence moves from wide to close: first where, then who, then how they feel.

## Camera angle

- **Eye level** feels neutral and honest.
- **High angle** (looking down) makes a subject look smaller or vulnerable.
- **Low angle** (looking up) makes a subject look powerful.
- **Over-the-shoulder** shows a conversation from one person's point of view.

## Composition

- **Rule of thirds:** imagine the frame divided into three both ways; place important things on the lines or where they cross.
- **Headroom:** leave a little space above a person's head — not too much, not none.
- **Lead room:** leave space in the direction a person is looking or moving.
- **Leading lines:** roads, rails or walls that guide the eye to the subject.

## Continuity: cuts that feel invisible

Continuity rules help the audience understand space and time without noticing the edit.

- **The 180° rule:** imagine a line between two people talking. Keep the camera on one side of it; crossing the line makes them seem to swap places.
- **The 30° rule:** when cutting between two shots of the same subject, change the angle by at least 30° (or change the shot size). Otherwise the cut looks like a mistake — a jump cut.
- **Match on action:** cut in the middle of a movement, such as a door opening, so the movement carries the viewer across the cut.
- **Eyeline match:** if a person looks off-screen to the right, the next shot should show what they see.

> [!TIP]
> Breaking continuity on purpose is a style — vloggers use jump cuts to remove pauses. Know the rules first, then break them deliberately.

## Try it

Watch two minutes of a film or series you like. For each shot, write its size and angle. Mark one place where a cut follows the 180° rule and one match on action.

## Common mistakes

- Only filming medium shots, leaving nothing to cut to.
- Cutting between two almost identical angles of the same person.
- Crossing the 180° line in a conversation, confusing the viewer.

## Key terms

- **Shot size** — how much of the subject the frame shows.
- **Rule of thirds** — a composition guide using a 3 × 3 grid.
- **180° rule** — keeping the camera on one side of the line of action.
- **Match on action** — cutting during a movement to hide the edit.$md$);

  perform seed.ensure_lesson(c, 'Pictures and sound', 'Sound for editors', 'article', 10,
    'Dialogue, music, effects and levels — the half of the film people notice only when it is wrong.',
$md$## Sound is half the film

Viewers forgive slightly imperfect pictures, but they leave quickly when the sound is bad. In this lesson you will learn the layers of a soundtrack and how to balance them.

## The four layers

1. **Dialogue** — the people speaking. Usually the most important layer.
2. **Music** — sets mood and rhythm.
3. **Sound effects** — door slams, footsteps, clicks.
4. **Ambience** — the background sound of a place: traffic, birds, a room's hum (called **room tone** indoors).

Put each layer on its own audio track, so you can adjust them separately.

## Reading levels

Editing apps show audio levels in **decibels relative to full scale (dBFS)**. 0 dBFS is the absolute maximum.

| Level | What it means |
| --- | --- |
| Peaks reaching 0 dBFS | **Clipping** — harsh distortion that cannot be repaired |
| Dialogue peaks around −12 to −6 dBFS | A safe, clear level for speech |
| Music under speech around −20 dBFS or lower | Background that does not fight the voice |

> [!WARNING]
> Clipped audio is permanently damaged. If a recording clips, turning it down later does not remove the distortion — record at a safer level next time.

## Balancing the mix

- **Duck the music** — lower the music whenever someone speaks, then bring it back up in the pauses.
- **Fade** — add short fades at the start and end of clips to avoid clicks.
- **Fill gaps with room tone** — a few seconds of the room's natural sound covers cuts, because complete silence sounds unnatural.
- **Use J-cuts and L-cuts** — letting sound start early or continue late makes scenes flow.

## Music and copyright

Most commercial songs are protected by copyright. Using them in your videos can get the videos muted or removed, or bring legal trouble. Use music you have a licence for: royalty-free libraries, music with a Creative Commons licence that allows your use, or music made for you.

## Try it

Record yourself speaking for 30 seconds on your phone in a quiet room, then again near an open window. In any editor, compare the waveforms and levels. Add soft music under the quiet recording and lower it until the voice is clearly understandable.

## Common mistakes

- Music louder than the voice.
- Peaks at 0 dBFS, causing distortion.
- Abrupt cuts in sound, leaving clicks and sudden silences.

## Key terms

- **dBFS** — the scale for digital audio levels; 0 is the maximum.
- **Clipping** — distortion caused by a level that is too high.
- **Room tone** — the natural background sound of a location.
- **Ducking** — lowering music automatically or by hand under speech.$md$);

  perform seed.ensure_lesson(c, 'Pictures and sound', 'Pictures and sound: check', 'quiz', 5,
    'Five questions on shots, continuity and sound.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Pictures and sound: check', 'Pictures and sound check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which shot is best for showing a person''s emotion?',
    'A close-up shows the face and its expressions.',
    array['Close-up', 'Extreme wide', 'Wide'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'Two people talk. In the next shot they seem to have swapped sides. Which rule was broken?',
    'The 180° rule keeps the camera on one side of the line between them.',
    array['The 180° rule', 'The rule of thirds', 'The 30° rule'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'Your dialogue peaks hit 0 dBFS. What happens?',
    'At 0 dBFS the audio clips and distorts permanently.',
    array['The audio clips and distorts', 'The audio becomes clearer', 'Nothing — 0 dBFS is ideal'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'Why fill silent gaps with room tone?',
    'Complete digital silence sounds unnatural; room tone keeps the space believable.',
    array['Complete silence sounds unnatural', 'It makes the file smaller', 'It hides the music'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'true_false', 'True or false: you may use any popular song in your video as long as you credit the artist.',
    'False — credit is not permission. You need a licence that covers your use.',
    array['True', 'False'], array[false, true], null);

  perform seed.ensure_lesson(c, 'Your first edit', 'Your first edit', 'exercise', 25,
    'Shoot ten short clips on your phone and edit them into a 30-second sequence.',
$md$## From clips to a story

Time to edit. In this exercise you will turn your own phone clips into a short sequence, using the workflow from this course. Any editor works: **DaVinci Resolve** (free, for computers) and **CapCut** (free, for phones and computers) are good choices. Menu names differ between apps, so the steps describe what to do rather than exact buttons.

## 1. Shoot your material

Choose a simple activity with a beginning, middle and end — making tea, packing a bag, cooking a dish. Film **10–15 short clips** of 5–10 seconds each:

- a wide shot to show where you are,
- medium shots of the main steps,
- close-ups and inserts of hands and details,
- a final shot that shows the result.

Hold the phone steady with both hands, film in landscape (or vertical if your final video is for a vertical platform), and keep each shot still for a few seconds before and after the action.

## 2. Set up the project

Create a new project with the same resolution and frame rate as your clips, for example 1920 × 1080 at 30 fps. Import the clips into a folder (bin) called `Footage`.

## 3. Assemble

Place the clips on the timeline in story order. Do not worry about timing yet — the goal is a complete rough sequence.

## 4. Trim and tighten

- Cut away the start and end of each clip where nothing happens.
- Use close-ups to cover moments that are slow in the wide shot.
- Aim for about **30 seconds** in total.

## 5. Add sound

Add one piece of licensed music on its own track. Lower it so it supports the pictures, and add short fades at the start and end.

> [!TIP]
> Play the sequence without looking at the screen. If the music alone does not feel finished, check that it starts and ends cleanly.

## 6. Review

Watch the whole sequence twice: once for the story (is every step clear?) and once for details (jumps, sudden sound changes, black frames between clips).

## Try it

Complete steps 1–6 and save your project. You will export it in the next lesson and use the same skills in the course project.

## Common mistakes

- Filming one long clip instead of separate shots.
- Mixing vertical and horizontal clips in one project.
- Leaving dead time at the start of every clip.

## Key terms

- **Bin** — a folder for media inside an editing project.
- **Assembly** — the first, rough arrangement of clips.
- **Trim** — shortening a clip from its start or end.
- **Coverage** — the set of different shots that lets you edit a scene.$md$, 'published', false, 25);

  perform seed.ensure_lesson(c, 'Your first edit', 'Exporting your video', 'article', 9,
    'Containers, codecs and settings that give you a good-looking file of a sensible size.',
$md$## Turning a project into a file

Your edit lives inside the editing app as a project. **Exporting** (also called rendering or delivering) creates a single video file that anyone can play. In this lesson you will choose settings that look good and upload quickly.

## Container and codec

- The **container** is the file type, such as `.mp4` or `.mov`. It holds video, audio and information about them.
- The **codec** is the method used to compress the video, such as **H.264** or **H.265 (HEVC)**.

For almost every online use, **MP4 with H.264** is the safe choice: every phone, computer and platform can play it.

## The main settings

| Setting | Recommendation |
| --- | --- |
| Resolution | The same as your project, such as 1920 × 1080 or 1080 × 1920 for vertical |
| Frame rate | The same as your project, such as 25 or 30 fps |
| Codec | H.264 (or H.265 for smaller files on modern devices) |
| Bitrate / quality | The app's “high” or the platform preset |
| Audio | AAC, 48 kHz, stereo |

**Bitrate** is how much data is used per second of video. Higher bitrate means better quality and a bigger file. Platform presets (for YouTube, Instagram and others) choose sensible values for you.

> [!WARNING]
> Never export at a different frame rate from your project unless you know why. Converting 30 fps to 25 fps makes motion stutter.

## Name and check the file

Use clear names such as `tea-routine_v02_2026-11-15.mp4`. After exporting, **watch the whole file** on the device where it will be seen. Exports sometimes reveal problems you did not notice in the editor: a missing clip, a black frame or music that is too loud on phone speakers.

## Keep the project

Keep the project and the original clips until the video is finished and published. You may need to change something after feedback, and re-exporting from the project is quick.

## Try it

Export the sequence from the previous lesson as an MP4 with H.264 at the project's resolution and frame rate. Note the file size, then watch it on your phone from start to finish.

## Common mistakes

- Exporting at a lower resolution than the project by accident.
- Changing the frame rate during export.
- Deleting the project as soon as the file is exported.

## Key terms

- **Export** — creating a finished video file from a project.
- **Container** — the file format, such as MP4.
- **Codec** — the compression method, such as H.264.
- **Bitrate** — the amount of data per second of video.$md$);

  perform seed.ensure_lesson(c, 'Your first edit', 'Project: a day-in-the-life edit', 'project', 60,
    'Shoot and edit a 60-second film about one day or one routine.',
$md$## Your project

Make a **60-second “day in the life” film** about yourself, a family member, a shop owner or a place — with permission from anyone who appears in it. Shoot it on a phone and edit it in any app.

### Requirements

1. **Length:** 50–70 seconds.
2. **Story:** a clear beginning, middle and end — for example morning, work, evening.
3. **Coverage:** at least three shot sizes (wide, medium, close-up) and at least two inserts.
4. **Continuity:** cuts that respect the 180° rule and the 30° rule, unless a jump cut is clearly intentional.
5. **Sound:** licensed music balanced under any speech or natural sound; no clipping; fades at the start and end.
6. **Export:** MP4 (H.264) at the project's resolution and frame rate.
7. **Notes:** three or four sentences on your choices and where the music comes from.

### How to submit

Upload the MP4 or share a link (for example, an unlisted video), and paste your notes in the text box.

> [!NOTE]
> A reviewer watches your film against the rubric and leaves feedback. You can re-edit and resubmit.$md$, 'published', false, 60);
  perform seed.ensure_assignment(c, 'Project: a day-in-the-life edit', 'Day-in-the-life film',
    'Shoot and edit a 60-second film with a clear story, varied coverage, clean sound and a correct export.',
$r$| Criterion | Points |
| --- | --- |
| Clear beginning, middle and end within 50–70 seconds | 20 |
| Coverage: three shot sizes and inserts used purposefully | 20 |
| Continuity and pacing of the cuts | 20 |
| Sound: balanced levels, no clipping, licensed music | 20 |
| Correct export settings and notes on choices | 20 |$r$);

  perform seed.ensure_lesson(c, 'Your first edit', 'Final assessment', 'quiz', 8,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'Video Editing Fundamentals — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'What is most of video editing about?',
    'Editing is mostly choosing what to keep and what to leave out.',
    array['Choosing what to leave out', 'Adding as many effects as possible', 'Making every video longer'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which aspect ratio is standard for vertical phone video?',
    '9:16 is vertical; 16:9 is landscape.',
    array['9:16', '16:9', '4:3'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'The audio of the next shot starts before its picture. What is this called?',
    'A J-cut — the audio leads the picture.',
    array['J-cut', 'L-cut', 'Jump cut'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'Why cut in the middle of a movement, such as a door opening?',
    'Match on action lets the movement carry the viewer across the cut, hiding it.',
    array['The movement hides the cut', 'It makes the file smaller', 'Platforms require it'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'single_choice', 'Which export format is the safest choice for most online platforms?',
    'MP4 with H.264 plays almost everywhere.',
    array['MP4 with H.264', 'A sequence of PNG images', 'An uncompressed AVI file'], array[true, false, false], null);
  perform seed.ensure_question(q, 5, 'single_choice', 'Your project is 30 fps. Which frame rate should the export use?',
    'Keep the project''s frame rate to avoid stuttering motion.',
    array['30 fps', '25 fps', '60 fps'], array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'single_choice', 'Where should background music sit when someone is speaking?',
    'Lower the music under speech so the voice stays clear.',
    array['Clearly below the voice', 'Louder than the voice', 'At 0 dBFS'], array[true, false, false], null);
  perform seed.ensure_question(q, 7, 'multiple_choice', 'Which belong in a professional editing workflow? Select **all** that apply.',
    'Organise, assemble, cut finely, finish colour and sound, then export and check.',
    array['Organising footage in bins', 'A rough cut before the fine cut', 'Watching the exported file before publishing', 'Deleting the project right after export'],
    array[true, true, true, false],
    array[null, null, null, 'Keep the project until the video is finished; you may need changes.']);

  perform seed.order_modules(c, array['The craft of editing', 'Pictures and sound', 'Your first edit']);
  perform seed.order_lessons(c, 'Pictures and sound', array['Shots, composition and continuity', 'Sound for editors', 'Pictures and sound: check']);
  perform seed.order_lessons(c, 'Your first edit', array['Your first edit', 'Exporting your video', 'Project: a day-in-the-life edit', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'video-editing-fundamentals';
begin
  perform seed.tr_module(c, 'Pictures and sound', 'uz', 'Tasvir va ovoz',
    'Montaj qilinadigan lavhalar va ularni bir butunga bogʻlaydigan ovoz.');
  perform seed.tr_module(c, 'Your first edit', 'uz', 'Birinchi montajingiz',
    'Oʻz materialingizdan qisqa filmni montaj qiling, yakunlang va eksport qiling.');

  perform seed.tr_lesson(c, 'Shots, composition and continuity', 'uz', 'Lavhalar, kompozitsiya va uzluksizlik',
    'Lavha oʻlchamlari, kadrga olish va kesishlarni tabiiy his qildiradigan uzluksizlik qoidalari.',
$md$## Tasvir tili

Montajchilar kun boʻyi lavhalar orasidan tanlov qiladi, shuning uchun ularga nom berish kerak. Bu darsda lavhalarni nomlashni, ularning kadrga olinishini baholashni va harakatni kesishlar orqali uzluksiz saqlashni oʻrganasiz.

| Lavha oʻlchami | Nimani koʻrsatadi | Odatdagi qoʻllanilishi |
| --- | --- | --- |
| **Juda umumiy plan** | Butun manzara yoki shahar | Voqea qayerda boʻlayotganini koʻrsatish |
| **Umumiy plan** | Insonni boshdan oyoq atrof-muhiti bilan | Harakat va joyni koʻrsatish |
| **Oʻrta plan** | Insonni beldan yuqorisi | Suhbatlar, taqdimotlar |
| **Yirik plan** | Yuz yoki muhim buyum | Hissiyot va tafsilot |
| **Juda yirik plan** | Koʻzlar, qoʻllar, mayda detal | Taranglik va urgʻu |
| **Insert** (detal) | Harakatning tafsiloti, masalan, tugmani bosayotgan qoʻl | Nima boʻlayotganini aniqlashtirish |

Klassik ketma-ketlik umumiydan yirikka qarab boradi: avval qayerda, keyin kim, soʻngra u nimani his qilmoqda.

## Kamera burchagi

- **Koʻz darajasi** neytral va samimiy tuyuladi.
- **Yuqori burchak** (pastga qarab) obyektni kichikroq yoki himoyasiz koʻrsatadi.
- **Past burchak** (yuqoriga qarab) obyektni kuchli koʻrsatadi.
- **Yelka ortidan** suhbatni bir kishining nigohidan koʻrsatadi.

## Kompozitsiya

- **Uchdan bir qoidasi:** kadrni har ikki yoʻnalishda uchga boʻlingan deb tasavvur qiling; muhim narsalarni chiziqlar ustiga yoki ular kesishgan joyga joylang.
- **Bosh ustidagi joy:** inson boshi ustida biroz joy qoldiring — juda koʻp ham emas, umuman yoʻq ham emas.
- **Harakat yoʻnalishidagi joy:** inson qarayotgan yoki harakatlanayotgan tomonda joy qoldiring.
- **Yoʻnaltiruvchi chiziqlar:** nigohni obyektga olib boradigan yoʻllar, relslar yoki devorlar.

## Uzluksizlik: sezilmaydigan kesishlar

Uzluksizlik qoidalari tomoshabinga montajni payqamasdan makon va vaqtni tushunishga yordam beradi.

- **180° qoidasi:** suhbatlashayotgan ikki kishi orasida chiziq borligini tasavvur qiling. Kamerani uning bir tomonida saqlang; chiziqni kesib oʻtish ularni oʻrin almashtirgandek koʻrsatadi.
- **30° qoidasi:** bitta obyektning ikki lavhasi orasida kesishda burchakni kamida 30° ga oʻzgartiring (yoki lavha oʻlchamini oʻzgartiring). Aks holda kesish xatodek — jump cut kabi koʻrinadi.
- **Harakat ustida kesish:** eshik ochilishi kabi harakatning oʻrtasida kesing — harakat tomoshabinni kesish orqali olib oʻtadi.
- **Nigoh mosligi:** agar inson kadr tashqarisiga oʻngga qarasa, keyingi lavha u koʻrayotgan narsani koʻrsatishi kerak.

> [!TIP]
> Uzluksizlikni ataylab buzish — bu uslub: vlogerlar pauzalarni olib tashlash uchun jump cut dan foydalanadi. Avval qoidalarni biling, soʻngra ularni ongli ravishda buzing.

## Oʻzingiz sinab koʻring

Yoqtirgan film yoki serialingizdan ikki daqiqa tomosha qiling. Har bir lavhaning oʻlchami va burchagini yozib boring. 180° qoidasiga amal qilingan bitta kesishni va harakat ustidagi bitta kesishni belgilang.

## Keng tarqalgan xatolar

- Faqat oʻrta planlarni suratga olish — montaj uchun boshqa lavha qolmaydi.
- Bitta odamning deyarli bir xil ikki burchagi orasida kesish.
- Suhbatda 180° chizigʻini kesib oʻtib, tomoshabinni chalgʻitish.

## Asosiy atamalar

- **Lavha oʻlchami (plan)** — kadr obyektning qancha qismini koʻrsatishi.
- **Uchdan bir qoidasi** — 3 × 3 toʻrdan foydalanadigan kompozitsiya qoʻllanmasi.
- **180° qoidasi** — kamerani harakat chizigʻining bir tomonida saqlash.
- **Harakat ustida kesish** — montajni yashirish uchun harakat paytida kesish.$md$);

  perform seed.tr_lesson(c, 'Sound for editors', 'uz', 'Montajchilar uchun ovoz',
    'Dialog, musiqa, effektlar va daraja — film yarmi, uni odamlar faqat notoʻgʻri boʻlganda payqaydi.',
$md$## Ovoz — filmning yarmi

Tomoshabinlar biroz nomukammal tasvirni kechiradi, ammo ovoz yomon boʻlsa, tezda ketib qoladi. Bu darsda saundtrek qatlamlarini va ularni qanday muvozanatlashni oʻrganasiz.

## Toʻrt qatlam

1. **Dialog** — gapirayotgan odamlar. Odatda eng muhim qatlam.
2. **Musiqa** — kayfiyat va ritmni belgilaydi.
3. **Ovoz effektlari** — eshik taqillashi, qadam tovushlari, chertishlar.
4. **Muhit ovozi** — joyning fon ovozi: transport, qushlar, xonaning gʻuvillashi (yopiq joyda **xona ovozi**, *room tone*, deb ataladi).

Har bir qatlamni alohida audio trekka qoʻying, shunda ularni alohida sozlay olasiz.

## Darajalarni oʻqish

Montaj dasturlari audio darajalarini **toʻliq shkalaga nisbatan detsibellarda (dBFS)** koʻrsatadi. 0 dBFS — mutlaq maksimum.

| Daraja | Nimani bildiradi |
| --- | --- |
| Choʻqqilar 0 dBFS ga yetadi | **Kliping** — tuzatib boʻlmaydigan keskin buzilish |
| Dialog choʻqqilari taxminan −12 dan −6 dBFS gacha | Nutq uchun xavfsiz, aniq daraja |
| Nutq ostidagi musiqa taxminan −20 dBFS yoki undan past | Ovoz bilan bellashmaydigan fon |

> [!WARNING]
> Kliping boʻlgan audio butunlay buziladi. Agar yozuvda kliping boʻlsa, keyinchalik ovozni pasaytirish buzilishni yoʻqotmaydi — keyingi safar xavfsizroq darajada yozing.

## Miksni muvozanatlash

- **Musiqani pasaytiring** — kimdir gapirganda musiqani pasaytiring va pauzalarda qayta oshiring.
- **Silliq kirish va chiqish qiling** — chertish tovushlari boʻlmasligi uchun kliplar boshi va oxiriga qisqa fade qoʻshing.
- **Boʻshliqlarni xona ovozi bilan toʻldiring** — xonaning tabiiy ovozidan bir necha soniya kesishlarni yashiradi, chunki toʻliq jimjitlik gʻayritabiiy eshitiladi.
- **J-cut va L-cut dan foydalaning** — ovozning ertaroq boshlanishi yoki kechroq davom etishi sahnalarni ravon qiladi.

## Musiqa va mualliflik huquqi

Aksariyat tijoriy qoʻshiqlar mualliflik huquqi bilan himoyalangan. Ulardan videolaringizda foydalansangiz, videolar ovozsiz qilinishi yoki oʻchirilishi, hatto huquqiy muammo kelib chiqishi mumkin. Litsenziyasi bor musiqadan foydalaning: royaltisiz kutubxonalar, sizning foydalanishingizga ruxsat beruvchi Creative Commons litsenziyali musiqa yoki siz uchun yaratilgan musiqa.

## Oʻzingiz sinab koʻring

Telefoningizda oʻzingizning 30 soniyalik nutqingizni jimjit xonada, soʻngra ochiq deraza yonida yozib oling. Istalgan dasturda toʻlqin shakllari va darajalarni solishtiring. Jimjit xonadagi yozuv ostiga yengil musiqa qoʻshing va ovoz aniq tushunarli boʻlguncha uni pasaytiring.

## Keng tarqalgan xatolar

- Musiqaning ovozdan baland boʻlishi.
- Choʻqqilarning 0 dBFS ga yetishi va buzilish paydo boʻlishi.
- Ovozdagi keskin kesishlar — chertishlar va toʻsatdan jimjitlik qoladi.

## Asosiy atamalar

- **dBFS** — raqamli audio darajalari shkalasi; 0 — maksimum.
- **Kliping** — haddan tashqari yuqori daraja tufayli yuzaga keladigan buzilish.
- **Xona ovozi** (*room tone*) — joyning tabiiy fon ovozi.
- **Ducking** — nutq ostida musiqani avtomatik yoki qoʻlda pasaytirish.$md$);

  perform seed.tr_lesson(c, 'Pictures and sound: check', 'uz', 'Tasvir va ovoz: bilimni tekshirish',
    'Lavhalar, uzluksizlik va ovoz boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Pictures and sound check', 'uz', '“Tasvir va ovoz” moduli boʻyicha test');
  perform seed.tr_question(c, 'Pictures and sound check', 0, 'uz', 'Insonning hissiyotini koʻrsatish uchun qaysi lavha eng yaxshi?',
    'Yirik plan yuzni va uning ifodalarini koʻrsatadi.',
    array['Yirik plan', 'Juda umumiy plan', 'Umumiy plan']);
  perform seed.tr_question(c, 'Pictures and sound check', 1, 'uz', 'Ikki kishi suhbatlashmoqda. Keyingi lavhada ular oʻrin almashgandek koʻrinadi. Qaysi qoida buzilgan?',
    '180° qoidasi kamerani ular orasidagi chiziqning bir tomonida saqlaydi.',
    array['180° qoidasi', 'Uchdan bir qoidasi', '30° qoidasi']);
  perform seed.tr_question(c, 'Pictures and sound check', 2, 'uz', 'Dialog choʻqqilari 0 dBFS ga yetdi. Nima sodir boʻladi?',
    '0 dBFS da audio kliping boʻladi va butunlay buziladi.',
    array['Audio kliping boʻlib, buziladi', 'Audio aniqroq boʻladi', 'Hech narsa — 0 dBFS ideal daraja']);
  perform seed.tr_question(c, 'Pictures and sound check', 3, 'uz', 'Nega jimjit boʻshliqlarni xona ovozi bilan toʻldirish kerak?',
    'Toʻliq raqamli jimjitlik gʻayritabiiy eshitiladi; xona ovozi muhitni ishonarli saqlaydi.',
    array['Toʻliq jimjitlik gʻayritabiiy eshitiladi', 'U faylni kichraytiradi', 'U musiqani yashiradi']);
  perform seed.tr_question(c, 'Pictures and sound check', 4, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: ijrochini koʻrsatib qoʻysangiz, videongizda istalgan mashhur qoʻshiqdan foydalanishingiz mumkin.',
    'Notoʻgʻri — muallifni koʻrsatish ruxsat degani emas. Sizga foydalanishingizni qamrab oladigan litsenziya kerak.',
    array['Toʻgʻri', 'Notoʻgʻri']);

  perform seed.tr_lesson(c, 'Your first edit', 'uz', 'Birinchi montajingiz',
    'Telefoningizda oʻnta qisqa klip suratga oling va ularni 30 soniyalik ketma-ketlikka montaj qiling.',
$md$## Kliplardan hikoyaga

Montaj vaqti keldi. Bu mashqda oʻz telefon kliplaringizni ushbu kursdagi ish jarayoni asosida qisqa ketma-ketlikka aylantirasiz. Istalgan dastur mos keladi: **DaVinci Resolve** (bepul, kompyuterlar uchun) va **CapCut** (bepul, telefon va kompyuterlar uchun) — yaxshi tanlov. Menyu nomlari dasturlarda farq qiladi, shuning uchun qadamlarda aniq tugmalar emas, nima qilish kerakligi tasvirlangan.

## 1. Materialingizni suratga oling

Boshlanishi, oʻrtasi va oxiri bor oddiy ishni tanlang — choy damlash, sumka yigʻish, taom tayyorlash. Har biri 5–10 soniyalik **10–15 ta qisqa klip** suratga oling:

- qayerda ekaningizni koʻrsatadigan umumiy plan,
- asosiy qadamlarning oʻrta planlari,
- qoʻllar va tafsilotlarning yirik planlari va insertlari,
- natijani koʻrsatadigan yakuniy lavha.

Telefonni ikki qoʻlda barqaror ushlang, gorizontal holatda suratga oling (yakuniy video vertikal platforma uchun boʻlsa, vertikal holatda) va har bir lavhani harakatdan oldin va keyin bir necha soniya qimirlatmay turing.

## 2. Loyihani sozlang

Kliplaringiz bilan bir xil ruxsat va kadrlar chastotasiga ega yangi loyiha yarating, masalan, 1920 × 1080, 30 fps. Kliplarni `Footage` deb nomlangan papkaga (bin) import qiling.

## 3. Yigʻing

Kliplarni vaqt shkalasiga hikoya tartibida joylashtiring. Hozircha vaqtga eʼtibor bermang — maqsad toʻliq qoralama ketma-ketlik.

## 4. Qirqing va ixchamlang

- Har bir klipning hech narsa sodir boʻlmaydigan boshi va oxirini qirqib tashlang.
- Umumiy plandagi sekin lahzalarni yirik planlar bilan yoping.
- Jami taxminan **30 soniya**ga intiling.

## 5. Ovoz qoʻshing

Alohida trekka litsenziyasi bor bitta musiqa qoʻshing. Tasvirni qoʻllab-quvvatlaydigan darajada pasaytiring va boshi hamda oxiriga qisqa fade qoʻshing.

> [!TIP]
> Ketma-ketlikni ekranga qaramasdan ijro eting. Agar musiqaning oʻzi tugallangandek tuyulmasa, u toza boshlanib, toza tugashini tekshiring.

## 6. Koʻrib chiqing

Butun ketma-ketlikni ikki marta tomosha qiling: bir marta hikoya uchun (har bir qadam tushunarlimi?) va bir marta tafsilotlar uchun (sakrashlar, ovozning keskin oʻzgarishi, kliplar orasidagi qora kadrlar).

## Mashq

1–6-qadamlarni bajaring va loyihangizni saqlang. Keyingi darsda uni eksport qilasiz, xuddi shu koʻnikmalardan esa kurs loyihasida foydalanasiz.

## Keng tarqalgan xatolar

- Alohida lavhalar oʻrniga bitta uzun klip suratga olish.
- Bitta loyihada vertikal va gorizontal kliplarni aralashtirish.
- Har bir klip boshida harakatsiz vaqt qoldirish.

## Asosiy atamalar

- **Bin** — montaj loyihasi ichidagi media papkasi.
- **Yigʻish** (*assembly*) — kliplarning birinchi, qoralama joylashuvi.
- **Qirqish** (*trim*) — klipni boshidan yoki oxiridan qisqartirish.
- **Qamrov** (*coverage*) — sahnani montaj qilish imkonini beradigan turli lavhalar toʻplami.$md$);

  perform seed.tr_lesson(c, 'Exporting your video', 'uz', 'Videongizni eksport qilish',
    'Yaxshi koʻrinadigan va hajmi oqilona boʻlgan fayl beradigan konteynerlar, kodeklar va sozlamalar.',
$md$## Loyihani faylga aylantirish

Montajingiz montaj dasturi ichida loyiha sifatida saqlanadi. **Eksport** (render yoki yetkazib berish deb ham ataladi) istalgan kishi ijro eta oladigan yagona video faylni yaratadi. Bu darsda yaxshi koʻrinadigan va tez yuklanadigan sozlamalarni tanlaysiz.

## Konteyner va kodek

- **Konteyner** — `.mp4` yoki `.mov` kabi fayl turi. U video, audio va ular haqidagi maʼlumotlarni oʻz ichiga oladi.
- **Kodek** — videoni siqish usuli, masalan, **H.264** yoki **H.265 (HEVC)**.

Deyarli har qanday onlayn foydalanish uchun **H.264 kodekli MP4** xavfsiz tanlov: uni har qanday telefon, kompyuter va platforma ijro eta oladi.

## Asosiy sozlamalar

| Sozlama | Tavsiya |
| --- | --- |
| Ruxsat | Loyihangiz bilan bir xil, masalan, 1920 × 1080 yoki vertikal uchun 1080 × 1920 |
| Kadrlar chastotasi | Loyihangiz bilan bir xil, masalan, 25 yoki 30 fps |
| Kodek | H.264 (yoki zamonaviy qurilmalarda kichikroq fayl uchun H.265) |
| Bitreyt / sifat | Dasturdagi “high” (yuqori) yoki platforma preseti |
| Audio | AAC, 48 kHz, stereo |

**Bitreyt** — videoning har bir soniyasi uchun ishlatiladigan maʼlumot miqdori. Bitreyt qanchalik yuqori boʻlsa, sifat shunchalik yaxshi va fayl shunchalik katta boʻladi. Platforma presetlari (YouTube, Instagram va boshqalar uchun) oqilona qiymatlarni siz uchun tanlaydi.

> [!WARNING]
> Nima uchunligini bilmasangiz, hech qachon loyihadan farqli kadrlar chastotasida eksport qilmang. 30 fps ni 25 fps ga aylantirish harakatni “sakraydigan” qiladi.

## Faylni nomlang va tekshiring

`tea-routine_v02_2026-11-15.mp4` kabi aniq nomlardan foydalaning. Eksportdan keyin faylni u tomosha qilinadigan qurilmada **boshidan oxirigacha koʻring**. Eksport baʼzan montaj dasturida payqamagan muammolarni koʻrsatadi: yoʻqolgan klip, qora kadr yoki telefon karnayida juda baland eshitiladigan musiqa.

## Loyihani saqlang

Video tugallanib, eʼlon qilinmaguncha loyihani va asl kliplarni saqlang. Fikr-mulohazadan keyin biror narsani oʻzgartirishingiz kerak boʻlishi mumkin, loyihadan qayta eksport qilish esa tez.

## Oʻzingiz sinab koʻring

Oldingi darsdagi ketma-ketlikni loyiha ruxsati va kadrlar chastotasida H.264 kodekli MP4 sifatida eksport qiling. Fayl hajmini yozib oling va uni telefoningizda boshidan oxirigacha tomosha qiling.

## Keng tarqalgan xatolar

- Bilmasdan loyihadan pastroq ruxsatda eksport qilish.
- Eksport paytida kadrlar chastotasini oʻzgartirish.
- Fayl eksport qilinishi bilanoq loyihani oʻchirib yuborish.

## Asosiy atamalar

- **Eksport** — loyihadan tayyor video fayl yaratish.
- **Konteyner** — MP4 kabi fayl formati.
- **Kodek** — H.264 kabi siqish usuli.
- **Bitreyt** — videoning har bir soniyasidagi maʼlumot miqdori.$md$);

  perform seed.tr_lesson(c, 'Project: a day-in-the-life edit', 'uz', 'Loyiha: “Bir kun” filmi',
    'Bir kun yoki bitta kundalik odat haqida 60 soniyalik film suratga oling va montaj qiling.',
$md$## Loyihangiz

Oʻzingiz, oila aʼzongiz, doʻkon egasi yoki biror joy haqida **60 soniyalik “bir kun” filmi**ni yarating — unda ishtirok etadigan har bir kishidan ruxsat oling. Uni telefonda suratga oling va istalgan dasturda montaj qiling.

### Talablar

1. **Davomiyligi:** 50–70 soniya.
2. **Hikoya:** aniq boshlanish, oʻrta va yakun — masalan, ertalab, ish, kechqurun.
3. **Qamrov:** kamida uchta lavha oʻlchami (umumiy, oʻrta, yirik) va kamida ikkita insert.
4. **Uzluksizlik:** jump cut ataylab qilingani aniq boʻlmasa, kesishlar 180° va 30° qoidalariga amal qiladi.
5. **Ovoz:** litsenziyasi bor musiqa nutq yoki tabiiy ovoz ostida muvozanatlangan; kliping yoʻq; boshi va oxirida fade bor.
6. **Eksport:** loyiha ruxsati va kadrlar chastotasida MP4 (H.264).
7. **Izohlar:** tanlovlaringiz va musiqa qayerdan olingani haqida uch-toʻrt gap.

### Qanday topshiriladi

MP4 faylni yuklang yoki havola ulashing (masalan, roʻyxatda koʻrinmaydigan video) va izohlaringizni matn maydoniga joylang.

> [!NOTE]
> Tekshiruvchi filmingizni baholash mezonlari asosida tomosha qiladi va fikr-mulohaza qoldiradi. Qayta montaj qilib, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Day-in-the-life film'), 'uz',
    jsonb_build_object(
      'title', '“Bir kun” filmi',
      'brief_md', 'Aniq hikoyasi, xilma-xil lavhalari, toza ovozi va toʻgʻri eksporti bor 60 soniyalik film suratga oling va montaj qiling.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| 50–70 soniya ichida aniq boshlanish, oʻrta va yakun | 20 |
| Qamrov: uchta lavha oʻlchami va insertlardan maqsadli foydalanilgan | 20 |
| Kesishlarning uzluksizligi va ritmi | 20 |
| Ovoz: muvozanatli daraja, kliping yoʻq, litsenziyali musiqa | 20 |
| Toʻgʻri eksport sozlamalari va tanlovlar haqida izohlar | 20 |$r$),
    c || ' / Day-in-the-life film');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Video Editing Fundamentals — final assessment', 'uz', 'Video montaj asoslari — yakuniy imtihon');
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 0, 'uz', 'Video montajning katta qismi nimadan iborat?',
    'Montajning katta qismi — nimani qoldirish va nimani tashlab yuborishni tanlash.',
    array['Nimani tashlab yuborishni tanlash', 'Iloji boricha koʻp effekt qoʻshish', 'Har bir videoni uzunroq qilish']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 1, 'uz', 'Telefondagi vertikal video uchun qaysi tomonlar nisbati standart?',
    '9:16 — vertikal; 16:9 — gorizontal.',
    array['9:16', '16:9', '4:3']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 2, 'uz', 'Keyingi lavhaning ovozi uning tasviridan oldin boshlanadi. Bu nima deb ataladi?',
    'J-cut — ovoz tasvirdan oldin keladi.',
    array['J-cut', 'L-cut', 'Jump cut']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 3, 'uz', 'Nega eshik ochilishi kabi harakatning oʻrtasida kesish kerak?',
    'Harakat ustida kesish harakatga tomoshabinni kesish orqali olib oʻtish va uni yashirish imkonini beradi.',
    array['Harakat kesishni yashiradi', 'U faylni kichraytiradi', 'Platformalar buni talab qiladi']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 4, 'uz', 'Aksariyat onlayn platformalar uchun qaysi eksport formati eng xavfsiz tanlov?',
    'H.264 kodekli MP4 deyarli hamma joyda ijro etiladi.',
    array['H.264 kodekli MP4', 'PNG tasvirlar ketma-ketligi', 'Siqilmagan AVI fayl']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 5, 'uz', 'Loyihangiz 30 fps. Eksport qaysi kadrlar chastotasida boʻlishi kerak?',
    'Harakat sakramasligi uchun loyihaning kadrlar chastotasini saqlang.',
    array['30 fps', '25 fps', '60 fps']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 6, 'uz', 'Kimdir gapirayotganda fon musiqasi qanday darajada boʻlishi kerak?',
    'Ovoz aniq qolishi uchun nutq ostida musiqani pasaytiring.',
    array['Ovozdan aniq pastroq', 'Ovozdan balandroq', '0 dBFS da']);
  perform seed.tr_question(c, 'Video Editing Fundamentals — final assessment', 7, 'uz', 'Quyidagilardan qaysilari professional montaj jarayoniga tegishli? Mos keladigan **barcha** variantlarni belgilang.',
    'Tartiblash, yigʻish, nozik montaj, rang va ovozni yakunlash, soʻngra eksport qilish va tekshirish.',
    array['Materialni binlarga tartiblash', 'Yakuniy montajdan oldin qoralama montaj', 'Eʼlon qilishdan oldin eksport qilingan faylni tomosha qilish', 'Eksportdan keyin darhol loyihani oʻchirish'],
    array[null, null, null, 'Video tugaguncha loyihani saqlang; oʻzgartirish kerak boʻlishi mumkin.']);
end $tr$;
